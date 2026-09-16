---
name: llm-local-stack
description: "Use for Arvid's local LLM stack: llm-local, model switches."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [llama.cpp, local-llm, orchestrator, systemd, hermes]
---

# Local LLM Stack (~/code/llm-local)

Arvid's local inference setup. Everything is driven by one Go orchestrator; never start `llama-server` manually while it runs.

## Topology

- `models.yaml` — single source of truth: per-model HuggingFace source and all `llama-server` serve params (port, ctx, quant cache types, etc.).
- `scripts/llm_orchestrator` — Go binary, runs as user service `llm-orchestrator`, listens on **:8082**. Routes `/<model>/v1/*` to a single shared `llama-server` on :18888, lazily starting it per model and stopping the previous one first (frees VRAM). Endpoints: `GET /status`, `POST /switch/<model>`.
- Models live in `~/models/<dir>/*.gguf`; download with `scripts/download.sh <name>`.
- `docker/` — searxng (:8888), open-webui, mcpo. SearXNG has `restart: unless-stopped` and Docker is enabled, so it starts at boot on its own; no manual start needed.
- `systemd/` — user units for this stack (see systemd-user-services skill for unit authoring rules).

## Operations

Switch model (no service restart needed):
```bash
curl -X POST localhost:8082/switch/<model-name>
curl localhost:8082/status   # verify current_model
```

Add a model: add entry to `models.yaml` → `scripts/download.sh <name>` → **restart the orchestrator** (`systemctl --user restart llm-orchestrator`) — it reads models.yaml once at startup, so edits are not picked up live.

Rebuild the orchestrator after Go source changes: `cd scripts && go build -o llm_orchestrator .` (then restart the service).

Hermes wiring (in `~/.hermes/config.yaml`, via `hermes config set`):
```
model.provider: custom
model.base_url: http://nostromo:8082/<model-name>/v1
model.default: <model-name>
```
Point Hermes at the orchestrator path, never at a raw llama-server port — the orchestrator is what survives model switches.

## Pitfalls

- **Never kill or restart the backend serving the current Hermes session mid-turn** — the agent's own inference runs through it and the turn dies. Cutover procedure: (1) update Hermes config to the new endpoint, (2) user kills the old process / restarts the service while no turn is active, (3) `hermes --continue` — the resumed session reads the new config and the orchestrator lazily loads the model on first request.
- **No manual `scripts/serve.sh` while the orchestrator owns a model** — port conflict and GPU OOM; one 27B Q3 already fills the 16 GB VRAM, so a second server cannot load.
- **models.yaml changes are startup-only** for the orchestrator — forgetting the restart means new models fail as "unknown model".
- The orchestrator resolves its config relative to the binary's own location (`os.Executable()`), so it works from any CWD including systemd; don't reintroduce `os.Args[0]`-relative pathing, which breaks under absolute-path invocation.
