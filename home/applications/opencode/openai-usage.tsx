/** @jsxImportSource @opentui/solid */
import type { TuiPlugin, TuiPluginModule } from "@opencode-ai/plugin/tui"
import type { AssistantMessage } from "@opencode-ai/sdk/v2"
import { Buffer } from "node:buffer"
import { readFile } from "node:fs/promises"
import path from "node:path"
import { createMemo, createSignal, For } from "solid-js"

const CLIENT_ID = "app_EMoamEEZ73f0CkXaXp7hrann"
const TOKEN_ENDPOINT = "https://auth.openai.com/oauth/token"
const USAGE_ENDPOINT = "https://chatgpt.com/backend-api/wham/usage"
const REFRESH_INTERVAL_MS = 60_000
const MIN_REFRESH_GAP_MS = 10_000

const dataHome = process.env.XDG_DATA_HOME ?? (process.env.HOME ? path.join(process.env.HOME, ".local/share") : undefined)

type OAuthAuth = {
  type: "oauth"
  refresh: string
  access: string
  expires: number
  accountId?: string
}

type TokenResponse = {
  access_token?: string
  refresh_token?: string
  expires_in?: number
  id_token?: string
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

const tui: TuiPlugin = async (api) => {
  const [state, setState] = createSignal<State>({ status: "loading" })
  let lastRefresh = 0
  let pending: Promise<void> | undefined

  async function readAuth(): Promise<OAuthAuth> {
    if (!dataHome) throw new Error("cannot locate OpenCode data directory")
    const content = JSON.parse(await readFile(path.join(dataHome, "opencode/auth.json"), "utf8")) as {
      openai?: Partial<OAuthAuth>
    }
    const auth = content.openai
    if (
      auth?.type !== "oauth" ||
      typeof auth.refresh !== "string" ||
      typeof auth.access !== "string" ||
      typeof auth.expires !== "number"
    ) {
      throw new Error("connect ChatGPT with /connect")
    }
    return auth as OAuthAuth
  }

  async function refreshAuth(auth: OAuthAuth) {
    const response = await fetch(TOKEN_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        grant_type: "refresh_token",
        refresh_token: auth.refresh,
        client_id: CLIENT_ID,
      }),
    })
    if (!response.ok) throw new Error(`OAuth refresh failed (${response.status})`)

    const tokens = (await response.json()) as TokenResponse
    if (!tokens.access_token) throw new Error("OAuth refresh returned no access token")
    const next: OAuthAuth = {
      type: "oauth",
      refresh: tokens.refresh_token ?? auth.refresh,
      access: tokens.access_token,
      expires: Date.now() + (tokens.expires_in ?? 3600) * 1000,
      accountId: accountIdFromToken(tokens.id_token ?? tokens.access_token) ?? auth.accountId,
    }
    await api.client.auth.set({ providerID: "openai", auth: next })
    return next
  }

  async function credentials(force = false) {
    const auth = await readAuth()
    if (!force && auth.access && auth.expires > Date.now() + 30_000) return auth
    return refreshAuth(auth)
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
        let auth = await credentials()
        let response = await requestUsage(auth)
        if (response.status === 401) {
          auth = await credentials(true)
          response = await requestUsage(auth)
        }
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

  api.slots.register({
    order: 100,
    slots: {
      sidebar_content(ctx, props) {
        const context = createMemo(() => {
          const last = api.state.session
            .messages(props.session_id)
            .findLast((item): item is AssistantMessage => item.role === "assistant" && item.tokens.output > 0)
          if (!last) return { tokens: 0, percent: 0 }
          const tokens =
            last.tokens.input +
            last.tokens.output +
            last.tokens.reasoning +
            last.tokens.cache.read +
            last.tokens.cache.write
          const model = api.state.provider.find((item) => item.id === last.providerID)?.models[last.modelID]
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
            <text fg={ctx.theme.current.text}>
              <b>Context</b>
            </text>
            <text fg={ctx.theme.current.textMuted}>{context().tokens.toLocaleString()} tokens</text>
            <text fg={ctx.theme.current.textMuted}>{context().percent}% used</text>
            <For each={usage()}>
              {(limit) => (
                <text fg={state().status === "error" ? ctx.theme.current.error : ctx.theme.current.textMuted}>
                  {limit}
                </text>
              )}
            </For>
          </box>
        )
      },
    },
  })

  api.keymap.registerLayer({
    commands: [
      {
        name: "openai.usage.refresh",
        title: "Refresh OpenAI subscription usage",
        category: "Provider",
        namespace: "palette",
        slashName: "openai-usage",
        run: () => void update(true),
      },
    ],
  })

  api.event.on("session.idle", () => void update())
  const refreshTimer = setInterval(() => void update(), REFRESH_INTERVAL_MS)
  api.lifecycle.onDispose(() => {
    clearInterval(refreshTimer)
  })

  void update(true)
}

export default {
  id: "openai-subscription-usage",
  tui,
} satisfies TuiPluginModule & { id: string }
