# OpenCode SSH Jump Server

A minimal Fly.io jump server that enables Termius SSH access to a Hugging Face Space via a reverse SSH tunnel.

## Architecture

```
Termius
  │  SSH → <this-app>.fly.dev:2222
  ▼
Fly.io jump server  (GatewayPorts=yes, always-on)
  │  reverse tunnel opened outbound by HF Space on startup
  ▼
sshd on localhost:22 inside HF Space
```

HF Spaces only allow outbound connections — this jump server receives the
reverse tunnel from the Space and exposes it on port 2222 for Termius.

## Deploy to Fly.io

### 1. Install flyctl

```bash
# macOS
brew install flyctl

# Linux / WSL
curl -L https://fly.io/install.sh | sh
```

### 2. Generate SSH keypair (run once on your machine)

```bash
ssh-keygen -t ed25519 -f jump_key -N ""
# jump_key     → private key → HF Space secret JUMP_SSH_KEY
# jump_key.pub → public key  → Fly.io secret  JUMP_AUTHORIZED_KEY
```

### 3. Create and deploy the Fly.io app

```bash
fly auth login
fly launch --no-deploy    # reads fly.toml, creates the app
fly secrets set JUMP_AUTHORIZED_KEY="$(cat jump_key.pub)"
fly deploy
```

Note the app hostname (e.g. `opencode-jump.fly.dev`).

### 4. Add secrets to your HF Space

| Secret | Value |
|--------|-------|
| `SSH_PASSWORD` | Password Termius uses to log in |
| `JUMP_HOST` | `opencode-jump.fly.dev` |
| `JUMP_SSH_KEY` | Full contents of `jump_key` (private, including header/footer lines) |

### 5. Keep Fly.io awake with UptimeRobot

- URL: `http://opencode-jump.fly.dev`
- Interval: every 5 minutes

### 6. Configure Termius

| Field | Value |
|-------|-------|
| Host | `opencode-jump.fly.dev` |
| Port | `2222` |
| Username | `root` |
| Password | your `SSH_PASSWORD` value |

## Fly.io secrets

| Secret | Description |
|--------|-------------|
| `JUMP_AUTHORIZED_KEY` | Public key from `jump_key.pub` — allows HF Space to authenticate |

## Ports

| Port | Purpose |
|------|---------|
| 22 | HF Space dials in to establish reverse tunnel |
| 2222 | Termius connects through to reach HF Space sshd |
| 8080 | HTTP health endpoint (UptimeRobot ping target) |
