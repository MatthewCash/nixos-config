/** @jsxImportSource @opentui/solid */
import { Plugin } from "@opencode/plugin/tui"
import type { SessionMessageAssistant } from "@opencode/client"
import { Buffer } from "node:buffer"
import { createMemo, createSignal, For } from "solid-js"

const USAGE_ENDPOINT = "https://chatgpt.com/backend-api/wham/usage"
const REFRESH_INTERVAL_MS = 60_000
const MIN_REFRESH_GAP_MS = 10_000

type OAuthAuth = {
  type: "oauth"
  refresh: string
  access: string
  expires: number
  accountId?: string
}

type RateLimitWindow = {
  used_percent?: number
  limit_window_seconds?: number
  reset_at?: number
}

type Usage = {
  plan_type?: string
  rate_limit?: {
    primary_window?: RateLimitWindow | null
    secondary_window?: RateLimitWindow | null
  }
}

type State =
  | { status: "loading" }
  | { status: "ready"; usage: Usage }
  | { status: "error"; message: string }

function accountIdFromToken(token: string | undefined) {
  if (!token) return
  const part = token.split(".")[1]
  if (!part) return
  try {
    const claims = JSON.parse(Buffer.from(part, "base64url").toString()) as {
      chatgpt_account_id?: string
      organizations?: Array<{ id?: string }>
      "https://api.openai.com/auth"?: { chatgpt_account_id?: string }
    }
    return (
      claims.chatgpt_account_id ??
      claims["https://api.openai.com/auth"]?.chatgpt_account_id ??
      claims.organizations?.[0]?.id
    )
  } catch {
    return
  }
}

function errorMessage(error: unknown) {
  return error instanceof Error ? error.message : String(error)
}

function windowName(seconds: number | undefined) {
  if (!seconds) return "limit"
  if (seconds % 86_400 === 0) return `${seconds / 86_400}d`
  if (seconds % 3_600 === 0) return `${seconds / 3_600}h`
  return `${Math.round(seconds / 60)}m`
}

function resetText(resetAt: number | undefined) {
  if (!resetAt) return
  const date = new Date(resetAt * 1000)
  const hours = String(date.getHours()).padStart(2, "0")
  const minutes = String(date.getMinutes()).padStart(2, "0")
  return `reset ${date.getMonth() + 1}/${date.getDate()} ${hours}:${minutes}`
}

function windowText(window: RateLimitWindow | null | undefined) {
  if (!window) return
  const remaining = Math.max(0, Math.min(100, Math.round(100 - (window.used_percent ?? 0))))
  const reset = resetText(window.reset_at)
  return `${windowName(window.limit_window_seconds)} ${remaining}% left${reset ? `, ${reset}` : ""}`
}

function setup(api: Plugin.Context) {
  const [state, setState] = createSignal<State>({ status: "loading" })
  let lastRefresh = 0
  let pending: Promise<void> | undefined

  async function readAuth(): Promise<OAuthAuth> {
    // OpenCode 2 owns credential persistence and token refresh; read its active
    // credential rather than rotating refresh tokens from a terminal plugin.
    const response = await api.client.credential.list()
    const entry = response.find((item) => item.integrationID === "openai" && item.active)
    if (entry?.value.type !== "oauth") throw new Error("connect ChatGPT with /connect")
    const auth = entry.value
    return {
      ...auth,
      accountId:
        typeof auth.metadata?.accountId === "string" ? auth.metadata.accountId : accountIdFromToken(auth.access),
    }
  }

  async function requestUsage(auth: OAuthAuth) {
    const headers = new Headers({
      Accept: "application/json",
      Authorization: `Bearer ${auth.access}`,
    })
    if (auth.accountId) headers.set("ChatGPT-Account-Id", auth.accountId)
    return fetch(USAGE_ENDPOINT, { headers })
  }

  async function update(force = false) {
    if (pending) return pending
    if (!force && Date.now() - lastRefresh < MIN_REFRESH_GAP_MS) return
    pending = (async () => {
      try {
        const auth = await readAuth()
        const response = await requestUsage(auth)
        if (!response.ok) throw new Error(`usage request failed (${response.status})`)
        setState({ status: "ready", usage: (await response.json()) as Usage })
        lastRefresh = Date.now()
      } catch (error) {
        setState({ status: "error", message: errorMessage(error) })
      } finally {
        pending = undefined
      }
    })()
    return pending
  }

  api.ui.slot({
    append: "sidebar.content",
    render(props) {
      const context = createMemo(() => {
        const last = api.data.session.message
          .list(props.sessionID)
          .findLast(
            (item): item is SessionMessageAssistant => item.type === "assistant" && (item.tokens?.output ?? 0) > 0,
          )
        if (!last?.tokens) return { tokens: 0, percent: 0 }
        const tokens =
          last.tokens.input +
          last.tokens.output +
          last.tokens.reasoning +
          last.tokens.cache.read +
          last.tokens.cache.write
        const session = api.data.session.get(props.sessionID)
        const model = api.data.location.model
          .list(session?.location)
          ?.find((item) => item.providerID === last.model.providerID && item.id === last.model.id)
        return {
          tokens,
          percent: model?.limit.context ? Math.round((tokens / model.limit.context) * 100) : 0,
        }
      })
      const usage = () => {
        const value = state()
        if (value.status === "loading") return ["OpenAI usage: loading..."]
        if (value.status === "error") return [`OpenAI usage: ${value.message}`]
        const limits = [
          windowText(value.usage.rate_limit?.primary_window),
          windowText(value.usage.rate_limit?.secondary_window),
        ].filter((limit): limit is string => Boolean(limit))
        return limits.length ? limits : ["OpenAI usage unavailable"]
      }

      return (
        <box onMouseUp={() => void update(true)}>
          <text fg={api.theme.text.base}>
            <b>Context</b>
          </text>
          <text fg={api.theme.text.muted}>{context().tokens.toLocaleString()} tokens</text>
          <text fg={api.theme.text.muted}>{context().percent}% used</text>
          <For each={usage()}>
            {(limit) => (
              <text fg={state().status === "error" ? api.theme.text.feedback.error.base : api.theme.text.muted}>
                {limit}
              </text>
            )}
          </For>
        </box>
      )
    },
  })

  api.keymap.layer(() => ({
    commands: [
      {
        id: "openai.usage.refresh",
        title: "Refresh OpenAI subscription usage",
        group: "Provider",
        palette: true,
        slash: { name: "openai-usage" },
        run: () => void update(true),
      },
    ],
  }))

  const stop = api.data.on("session.execution.succeeded", () => void update())
  const refreshTimer = setInterval(() => void update(), REFRESH_INTERVAL_MS)
  void update(true)
  return () => {
    clearInterval(refreshTimer)
    stop()
  }
}

export default Plugin.define({
  id: "openai-subscription-usage",
  setup,
})
