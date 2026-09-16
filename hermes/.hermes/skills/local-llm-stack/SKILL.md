---
name: local-llm-stack
description: "Use for local llama.cpp/orchestrator/searxng ops."
version: 1.0.0
---

# Local LLM Stack (llama.cpp + orchestrator)

`~/code/llm-local` is the single source of truth — read it before touching anything:
- `models.yaml` — every model: HF repo, include glob, local_dir, serve args (port, ctx, cache types, threads…). Never hardcode model facts elsewhere; derive them from this file.
- `scripts/serve.sh [name]` — one-shot llama-server for a model (manual use only).
- `scripts/llm_orchestrator.go` / `llm_orchestrator` — router daemon (below).
- `docker/docker-compose.yaml` — searxng (:8888), open-webui (:3000), mcpo (:8000).

## Service topology
- **llm-orchestrator** (systemd user unit, enabled): listens on **:8082**, routes `/<model>/v1/*` to a single llama-server child on :18888. Models start lazily on first request; only one model resident at a time — the card has 16 GB VRAM and that is the whole point of the design.
- **searxng** runs in Docker with `restart: unless-stopped` and Docker is enabled → auto-starts at boot. No manual `compose up` needed.

## Switching models (the workflow the user cares about)
1. `curl -s localhost:8082/status` — see current model.
2. `curl -X POST localhost:8082/switch/<model-name>` — name from models.yaml; blocks until the server is ready (model load can take a while).
3. Verify with `/status` plus a small chat completion against `http://localhost:8082/<name>/v1/chat/completions`.

## Adding a model
1. Add an entry to `models.yaml` (name, repo, include, local_dir, serve block).
2. `./scripts/download.sh <name>`.
3. `systemctl --user restart llm-orchestrator` — config is read once at startup; new models are invisible until the unit restarts.

## Pitfalls
- Only one llama-server fits in VRAM. Before switching or starting anything, check `nvidia-smi` for a stray manually-started llama-server holding VRAM and kill it first — otherwise the load dies with cudaMalloc OOM and the switch looks broken.
- When modifying `llm_orchestrator.go`, keep config path resolution via `os.Executable()`, never argv[0]/CWD-relative — systemd invokes the binary by absolute path from a different working directory, and argv-relative paths break silently. Test the rebuilt binary from an unrelated CWD (e.g. /tmp) before re-enabling the unit.
- `systemctl --user` units only start at boot when linger is on (`loginctl enable-linger <user>`); without it they need an active login session.
- Hermes' model config (`~/.hermes/config.yaml`) pins a concrete base_url/model — pointing Hermes at a different local model means editing that config (via `hermes config set`), and the running session keeps the old endpoint until restarted. The orchestrator only serves what clients ask for; it does not push anything to Hermes.

## Ops commands
- `systemctl --user status|restart llm-orchestrator`
- `journalctl --user -u llm-orchestrator -n 50` (llama-server child output lands here too)
