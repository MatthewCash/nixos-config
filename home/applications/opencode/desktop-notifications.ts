import { Plugin } from "@opencode/plugin/tui"

function cleanText(value: string | undefined, fallback: string, limit: number) {
  const text = (value ?? "")
    .replace(/\u001b\[[0-?]*[ -/]*[@-~]/g, "")
    .replace(/[ \t]*[\r\n]+[ \t]*/g, " ")
    .replace(/[\u0000-\u001f\u007f-\u009f]/g, "")
    .trim()
  return Array.from(text || fallback).slice(0, limit).join("")
}

function sessionErrorMessage(error: { message: string }) {
  if (error.message === "SSE read timed out") {
    return "Model stopped responding"
  }
  return "Session error"
}

function setup(api: Plugin.Context) {
  if (!process.env.KONSOLE_VERSION && process.env.TERM_PROGRAM !== "kgx") return

  const active = new Set<string>()
  const errored = new Set<string>()
  const questions = new Set<string>()
  const permissions = new Set<string>()
  const dispose: Array<() => void> = []

  function ownsSession(sessionID: string | undefined) {
    if (!sessionID) return false
    const route = api.ui.router.current()
    if (route.type === "session" && route.sessionID === sessionID) return true
    return api.ui.tabs.enabled() && api.ui.tabs.list().some((tab) => tab.sessionID === sessionID)
  }

  function notify(sessionID: string | undefined, message: string) {
    // The shared service broadcasts events to every TUI, including other terminals.
    if (!ownsSession(sessionID)) return
    const session = sessionID ? api.data.session.get(sessionID) : undefined
    if (session?.parentID !== undefined) return

    const title = cleanText(session?.title, "OpenCode", 80)
    const text = cleanText(message, "OpenCode needs attention", 240)
    void api.attention.notify({
      title,
      message: text,
      notification: { when: "blurred" },
    }).catch((error) => console.debug("failed to send desktop notification", { error }))
  }

  dispose.push(
    api.data.on("form.created", (event) => {
      if (questions.has(event.data.form.id)) return
      questions.add(event.data.form.id)
      notify(event.data.form.sessionID, "Question needs input")
    }),
    api.data.on("form.replied", (event) => {
      questions.delete(event.data.id)
    }),
    api.data.on("form.cancelled", (event) => {
      questions.delete(event.data.id)
    }),
    api.data.on("permission.asked", (event) => {
      if (permissions.has(event.data.id)) return
      permissions.add(event.data.id)
      notify(event.data.sessionID, "Permission needs input")
    }),
    api.data.on("permission.replied", (event) => {
      permissions.delete(event.data.requestID)
    }),
    api.data.on("session.execution.started", (event) => {
      if (!ownsSession(event.data.sessionID)) return
      active.add(event.data.sessionID)
      errored.delete(event.data.sessionID)
    }),
    api.data.on("session.execution.succeeded", (event) => {
      const sessionID = event.data.sessionID
      if (!active.has(sessionID)) return
      active.delete(sessionID)
      if (errored.delete(sessionID)) return
      notify(sessionID, "Session done")
    }),
    api.data.on("session.execution.interrupted", (event) => {
      active.delete(event.data.sessionID)
      errored.delete(event.data.sessionID)
    }),
    api.data.on("session.execution.failed", (event) => {
      const sessionID = event.data.sessionID
      if (!active.has(sessionID) || errored.has(sessionID)) return
      errored.add(sessionID)
      notify(sessionID, sessionErrorMessage(event.data.error))
    }),
  )

  return () => {
    for (const stop of dispose) stop()
  }
}

export default Plugin.define({
  id: "desktop-notifications",
  setup,
})
