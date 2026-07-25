# OpenCode AI Agent — SSH Access

SSH tunnel setup for reaching the OpenCode HF Space from Termius.

## How it works

```
Termius
  │  SSH → opencode-hf.serveo.net:22
  ▼
serveo.net  (free relay, no account needed)
  │  reverse tunnel opened outbound by HF Space on startup
  ▼
sshd on localhost:22 inside HF Space
```

The HF Space opens an outbound SSH connection to `serveo.net` on startup.
This creates a public tunnel endpoint that Termius connects to.
HF does not block outbound SSH — no third-party binary runs inside the container.

## No external deployment needed

Unlike the Fly.io approach, this requires:
- ✅ No Fly.io account
- ✅ No API tokens
- ✅ No separate server to deploy
- ✅ No extra billing

## HF Space Secrets required

Set these in your HF Space → Settings → Variables and secrets:

| Secret | Value |
|--------|-------|
| `SSH_PASSWORD` | Password Termius uses to log in (already set) |

## Termius configuration

After the Space starts, check Space logs for the `[TUNNEL]` block:

```
[TUNNEL] Termius host     : opencode-hf.serveo.net
[TUNNEL] Termius port     : 22
[TUNNEL] Termius username : root
[TUNNEL] Termius password : your SSH_PASSWORD secret
```

In Termius:
| Field | Value |
|-------|-------|
| Host | `opencode-hf.serveo.net` |
| Port | `22` |
| Username | `root` |
| Password | your `SSH_PASSWORD` value |

## Fallback

If `opencode-hf.serveo.net` is already taken by another user, the Space
falls back to a random port on `serveo.net`. The actual host/port is always
printed to Space logs on startup — check the `[TUNNEL]` section.

## Fly.io jump server (archived)

The files `Dockerfile`, `entrypoint.sh`, and `fly.toml` in this repo
are the original Fly.io jump server approach. They are kept for reference
but are no longer needed — the serveo.net approach replaces them with
zero infrastructure overhead.
