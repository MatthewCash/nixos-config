import { Plugin } from "@opencode/plugin/tui"
import { spawn } from "node:child_process"

type FocusState = "unknown" | "focused" | "blurred"
type RendererOutput = {
  writeOut(data: string): boolean
}

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
  const renderer = api.renderer as unknown as RendererOutput
  if (process.env.KONSOLE_VERSION) {
    renderer.writeOut("\u001b[?1004h")
    return () => { renderer.writeOut("\u001b[?1004l") }
  }
  if (process.env.TERM_PROGRAM !== "kgx") return

  let focus: FocusState = "unknown"
  const active = new Set<string>()
  const errored = new Set<string>()
  const questions = new Set<string>()
  const permissions = new Set<string>()
  const dispose: Array<() => void> = []

  const onFocus = () => {
    focus = "focused"
  }
  const onBlur = () => {
    focus = "blurred"
  }

  api.renderer.on("focus", onFocus)
  api.renderer.on("blur", onBlur)

  function notify(sessionID: string | undefined, message: string) {
    const session = sessionID ? api.data.session.get(sessionID) : undefined
    if (session?.parentID !== undefined) return

    const title = cleanText(session?.title, "OpenCode", 80)
    const text = cleanText(message, "OpenCode needs attention", 240)
    if (focus !== "blurred") return

    const child = spawn(
      "notify-send",
      [
        "--app-name=OpenCode",
        "--urgency=normal",
        title,
        text,
      ],
      { stdio: "ignore" },
    )
    child.on("error", (error) => console.debug("failed to send desktop notification", { error }))
    child.unref()
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
    api.renderer.off("focus", onFocus)
    api.renderer.off("blur", onBlur)
    for (const stop of dispose) stop()
  }
}

export default Plugin.define({
  id: "desktop-notifications",
  setup,
})
