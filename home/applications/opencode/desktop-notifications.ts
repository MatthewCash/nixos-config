import type { Event } from "@opencode-ai/sdk/v2"
import type { TuiPlugin, TuiPluginModule } from "@opencode-ai/plugin/tui"
import { spawn } from "node:child_process"

type FocusState = "unknown" | "focused" | "blurred"
type SessionError = Extract<Event, { type: "session.error" }>["properties"]["error"]

function cleanText(value: string | undefined, fallback: string, limit: number) {
  const text = (value ?? "")
    .replace(/\u001b\[[0-?]*[ -/]*[@-~]/g, "")
    .replace(/[ \t]*[\r\n]+[ \t]*/g, " ")
    .replace(/[\u0000-\u001f\u007f-\u009f]/g, "")
    .trim()
  return Array.from(text || fallback).slice(0, limit).join("")
}

function sessionErrorMessage(error: SessionError) {
  if (error?.name === "MessageAbortedError") return "Session aborted"
  const data = error?.data
  if (data && typeof data === "object" && "message" in data && data.message === "SSE read timed out") {
    return "Model stopped responding"
  }
  return "Session error"
}

const tui: TuiPlugin = async (api) => {
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
    if (focus !== "blurred") return
    const session = sessionID ? api.state.session.get(sessionID) : undefined
    if (session?.parentID !== undefined) return

    const child = spawn(
      "notify-send",
      [
        "--app-name=OpenCode",
        "--urgency=normal",
        cleanText(session?.title, "OpenCode", 80),
        cleanText(message, "OpenCode needs attention", 240),
      ],
      { stdio: "ignore" },
    )
    child.on("error", (error) => console.debug("failed to send desktop notification", { error }))
    child.unref()
  }

  dispose.push(
    api.event.on("question.asked", (event) => {
      if (questions.has(event.properties.id)) return
      questions.add(event.properties.id)
      notify(event.properties.sessionID, "Question needs input")
    }),
    api.event.on("question.replied", (event) => {
      questions.delete(event.properties.requestID)
    }),
    api.event.on("question.rejected", (event) => {
      questions.delete(event.properties.requestID)
    }),
    api.event.on("permission.asked", (event) => {
      if (permissions.has(event.properties.id)) return
      permissions.add(event.properties.id)
      notify(event.properties.sessionID, "Permission needs input")
    }),
    api.event.on("permission.replied", (event) => {
      permissions.delete(event.properties.requestID)
    }),
    api.event.on("session.status", (event) => {
      const sessionID = event.properties.sessionID
      if (event.properties.status.type === "busy" || event.properties.status.type === "retry") {
        active.add(sessionID)
        errored.delete(sessionID)
        return
      }
      if (event.properties.status.type !== "idle" || !active.has(sessionID)) return

      active.delete(sessionID)
      if (errored.delete(sessionID)) return
      notify(sessionID, "Session done")
    }),
    api.event.on("session.error", (event) => {
      const sessionID = event.properties.sessionID
      if (!sessionID || !active.has(sessionID)) return
      errored.add(sessionID)
      notify(sessionID, sessionErrorMessage(event.properties.error))
    }),
  )

  api.lifecycle.onDispose(() => {
    api.renderer.off("focus", onFocus)
    api.renderer.off("blur", onBlur)
    for (const stop of dispose) stop()
  })
}

export default {
  id: "desktop-notifications",
  tui,
} satisfies TuiPluginModule & { id: string }
