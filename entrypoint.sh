#!/bin/sh
set -e

echo "[JUMP] Starting OpenCode SSH jump server..."

# Generate host keys (fresh container each deploy)
ssh-keygen -A 2>/dev/null || true

# Write sshd config
# GatewayPorts yes  — makes -R tunnels bind on 0.0.0.0, not just 127.0.0.1
# AllowTcpForwarding yes — required for reverse tunnels
cat > /etc/ssh/sshd_config << 'SSHD'
Port 22
PermitRootLogin yes
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile /root/.ssh/authorized_keys
GatewayPorts yes
AllowTcpForwarding yes
ClientAliveInterval 30
ClientAliveCountMax 6
X11Forwarding no
PrintMotd no
SSHD

# Write authorized key from secret so HF Space can authenticate
mkdir -p /root/.ssh && chmod 700 /root/.ssh
if [ -n "${JUMP_AUTHORIZED_KEY:-}" ]; then
    echo "${JUMP_AUTHORIZED_KEY}" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    echo "[JUMP] Authorized public key written."
else
    echo "[JUMP] WARNING: JUMP_AUTHORIZED_KEY not set — no client can connect."
fi

# Start sshd
/usr/sbin/sshd -e
echo "[JUMP] sshd listening on port 22."
echo "[JUMP] GatewayPorts=yes: reverse tunnel will bind port 2222 on 0.0.0.0."
echo "[JUMP] Termius connects to: <this-app>.fly.dev:2222"

# HTTP health endpoint on port 8080 — keeps Fly.io app alive
# UptimeRobot should ping http://<app>.fly.dev/ every 5 minutes
echo "[JUMP] Health endpoint on :8080 (for UptimeRobot)."
while true; do
    printf 'HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 2\r\n\r\nOK' \
        | nc -l -p 8080 2>/dev/null || true
done
