---
name: local-services
description: "Start and persist local services on this machine."
version: 1.0.0
metadata:
  hermes:
    tags: [systemd, docker, llama.cpp, searxng, hermes-gateway, daemon]
---

# Local Services (this machine)

Goal state: everything auto-starts at boot; no manual `llama-server` or `docker compose up` needed.

## Service map
| Service | Runtime | Persistence mechanism |
|---|---|---|
| LLM serving (Qwen3.8-27B, port 8082) | systemd **user** service `llm-orchestrator` (unit in ~/code/llm-local/systemd/) | enabled; needs linger for boot start |
| llama.cpp.service (legacy, port 8086) | system unit /usr/lib/systemd/system/ | **disabled — superseded by the orchestrator; leave it off** |
| searxng (port 8888) | Docker container from compose at /home/madhatter/code/llm-local/docker/docker-compose.yaml | `restart: unless-stopped`; docker enabled |
| hermes gateway | systemd user service via `hermes gateway install` | installer enables linger itself; verify with `loginctl show-user $USER --property=Linger` |

## Procedure
1. Establish ground truth before starting anything: `nvidia-smi` (llama-server already running?), `systemctl --user status llm-orchestrator`, `docker ps --filter name=searxng`, `hermes gateway status`. A manually started server is invisible to systemd — check both layers.
2. LLM serving is owned by the orchestrator (see local-llm-stack skill): `systemctl --user enable --now llm-orchestrator`. The legacy `llama.cpp.service` stays disabled — re-enabling it means two servers fighting over the 16 GB GPU (OOM).
3. searxng: usually nothing to do — verify container restart policy and `systemctl is-enabled docker`; only `docker compose up -d` if the container is stopped.
4. hermes gateway: `hermes gateway install` (user service). The installer enables linger itself (verified on v0.21.1) — still confirm with `loginctl show-user $USER --property=Linger`.
5. Verify end-to-end: llama-server `/health`, searxng HTTP 200 on :8888, `hermes gateway status`.

## Access channels (after daemonization)
- CLI always works independent of the gateway: `hermes` / `hermes --continue`.
- Web dashboard: `hermes dashboard` → http://127.0.0.1:9119 (auth-gated).
- Messenger platforms via the gateway — required for cron-job delivery; a CLI-only session does not deliver cron output to the user.

## Pitfalls
- No passwordless sudo on this machine: hand the user exact sudo commands (tee into /etc/conf.d/llama.cpp, `systemctl enable`, `loginctl enable-linger`) instead of trying to run them yourself.
- "Unit exists" ≠ "unit configured": llama.cpp.service ships disabled with empty LLAMA_ARGS; enabling it as-is starts a server with no model.
- Port 8086 conflict: kill the manual llama-server before `systemctl start llama.cpp`.
- Gateway without linger only runs while the user is logged in — for "always on when the PC is on", linger is mandatory.
- The gateway tolerates a down LLM at runtime: connection errors become a per-message reply ("model server is not responding") and the process keeps running. Its `Restart=always` is therefore not a crash-loop risk when the model is missing — don't "fix" it to on-failure.
- CLI clarify timeout: the CLI's built-in defaults hardcode `clarify.timeout` (120 s on v0.21.1), which takes precedence over `agent.clarify_timeout` (3600) in the resolution order — set `clarify.timeout` explicitly in config.yaml to change the effective CLI timeout.

## Related
- local-llm-serving — model paths, known-good llama-server args, OOM diagnosis.
- hermes-agent (bundled) — gateway setup, messaging platforms, dashboard details.
