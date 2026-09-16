---
name: local-llm-serving
description: "Use for local llama.cpp LLMs on this machine."
version: 1.0.0
metadata:
  hermes:
    tags: [llama.cpp, local-llm, gguf, gpu]
---

# Local LLM Serving (llama.cpp)

## Environment
- Model zoo: /home/madhatter/models/<family>/*.gguf — qwen38, qwen36, qwen35, qwen25-7b/14b, gemma3/gemma4, phi35-mini, qwen3-coder; flux2-klein and ltx-2.3 are image/video models (different runtimes, not llama.cpp).
- GPU: RTX 5070 Ti, 16 GB VRAM. Host: 32 GB RAM, 16 cores.
- llama-cli / llama-server on PATH.

## Procedure
1. Before launching anything, check whether the model is already served:
   - `nvidia-smi` — process list shows llama-server + VRAM usage.
   - `ss -tlnp | grep LISTEN` — find the server's port.
   If it is up, query it. Never launch a second load of the same model.
2. Query a running server (OpenAI-compatible):
   - `curl -s http://localhost:<port>/health` → `{"status":"ok"}`
   - POST /v1/chat/completions with `{"messages":[...]}`; the "model" field is the path passed to --model.
3. Launch a new server only if nothing serves the model (background, then verify via /health). Known-good shape from this machine:
   `llama-server -m <gguf> --host 0.0.0.0 --port <p> -ngl 999 --ctx-size 102400 -t 12 --temp 0.3 --top-p 0.9 --repeat-penalty 1.05 --cache-type-k q8_0 --cache-type-v q4_0 --flash-attn on --jinja`

## Pitfalls
- CUDA OOM at model load usually means the model is already resident in another process, not that it doesn't fit — a second load fails before the real size question arises. Check nvidia-smi before concluding "too big" or relaunching.
- llama-cli one-shot loads the full model into VRAM too; same OOM applies. For quick questions prefer querying a running server over spawning a new load.
- Size check: Q3_K_XL 27B ≈ 13.4 GB file → fits 16 GB VRAM with modest context. Bigger quant or long ctx → reduce -ngl (offload to CPU) or pick a smaller model.
- Making the server survive reboot is the local-services skill's job (systemd unit llama.cpp.service + /etc/conf.d/llama.cpp) — don't hand-roll a new unit; that one ships disabled with empty LLAMA_ARGS.
