# Gemma 4 E4B Coding Edition — Release & Publishing Notes

## What this release is

`gemma4-e4b-code` is a coding-oriented Ollama derivative built on the user's existing local `gemma4:e4b` model.

The Modelfile keeps the base weights unchanged and adds:

- A coding-focused system instruction.
- 32K default context for a practical 16 GB unified-memory baseline.
- 16,384 maximum generated tokens.
- Gemma 4's recommended sampling defaults: `temperature 1.0`, `top_p 0.95`, `top_k 64`.
- `min_p 0.05` for modest output filtering.
- Thinking enabled through Gemma 4's `<|think|>` system control token.

Gemma 4 E4B itself supports a 128K context window. The 32K Modelfile default is deliberate: context size has a direct memory cost, so a portable public model should not force 128K on every computer.
## Download from ollama:
```
ollama pull mukunthpr/gemma4-e4b-code
```
**Then skip to the adaptive runtime section**

## Build fromGemma 4 E4B



```bash
ollama pull gemma4:e4b
ollama create gemma4-e4b-code -f Modelfile
ollama run gemma4-e4b-code
```

Verify the model:

```bash
ollama show gemma4-e4b-code
ollama ps
```

## Adaptive macOS runtime

The included `run-gemma4-code-mac.sh` is a runtime launcher for the **single canonical model**. It does not create a second `-auto` model.

Run it locally with:

```bash
./run-gemma4-code-mac.sh
```

Or point the same launcher at the published model:

```bash
./run-gemma4-code-mac.sh YOUR_USERNAME/gemma4-e4b-code
```

The script detects installed physical memory, starts a temporary local Ollama server with the selected runtime settings, and launches the same model through that server. The model name remains unchanged across machines.

Context profiles:

| Installed RAM | Selected context |
|---:|---:|
| <16 GiB | 16K |
| 16–23 GiB | 32K |
| 24–31 GiB | 48K |
| 32–47 GiB | 64K |
| 48–63 GiB | 96K |
| 64+ GiB | 128K |

These are conservative operating profiles, not hard hardware limits. Heavy applications, large projects, multimodal inputs, and multiple simultaneously loaded models can require lowering the context size.

Optional overrides:

```bash
OLLAMA_CODE_CTX=65536 ./run-gemma4-code-mac.sh YOUR_USERNAME/gemma4-e4b-code
OLLAMA_CODE_MAX_OUTPUT=8192 ./run-gemma4-code-mac.sh YOUR_USERNAME/gemma4-e4b-code
```

The runner uses a dedicated local port so that the adaptive settings apply to the runtime it starts without changing the user's normal Ollama server configuration.

## Ollama memory tuning

The runner enables:

```bash
OLLAMA_FLASH_ATTENTION=1
OLLAMA_KV_CACHE_TYPE=q8_0
OLLAMA_NUM_PARALLEL=1
```

Flash Attention can significantly reduce memory use as context grows. Ollama documents `q8_0` KV cache as using approximately half the memory of `f16` with a small precision impact. `OLLAMA_NUM_PARALLEL=1` prevents concurrent requests from multiplying the effective context allocation.

There is no supported "hidden RAM" switch for Apple Silicon. Mac unified memory is shared by macOS, applications, CPU, and GPU workloads; Ollama cannot reserve an invisible extra pool.

## Recommended 16 GB Mac profile

For a 16 GB MacBook Pro, the intended starting point is:

- 32K context.
- 16K maximum output.
- Flash Attention enabled.
- `q8_0` KV cache.
- One parallel request.

The model can still be pushed toward 128K manually, but that is a workload-specific choice rather than a safe universal default.

## Why the runner creates another model name

Ollama's persistent model parameters are defined by the Modelfile. A static published Modelfile cannot inspect each user's free memory and rewrite `num_ctx` at runtime.

The runner therefore creates a lightweight local profile called `gemma4-e4b-code-auto` from the already-built coder model and gives that profile the context size selected for the current Mac.

This does not require downloading Gemma 4 again.

## Publishing to the Ollama model library

Before publishing, replace any placeholder author/description metadata with your chosen public model name and README text. The public description should clearly say that the model is an Ollama derivative of Gemma 4 E4B and should retain the applicable upstream Gemma terms/attribution.

Recommended public positioning:

> Gemma 4 E4B optimized as a local coding assistant for Ollama, with coding-focused instructions, long-context defaults, and a macOS adaptive runner for unified-memory systems.

Do not claim that the model has been fine-tuned unless you actually performed a weight-level fine-tune. This release is a prompt/parameter derivative of the existing Gemma 4 E4B model.

For reproducibility, publish the exact Modelfile alongside the model description. Keep the adaptive shell runner as an optional companion; the published model itself should remain portable.

## Suggested release checklist

- [ ] Build `gemma4-e4b-code` locally from the exact released Modelfile.
- [ ] Test coding, debugging, refactoring, test-writing, and long-file tasks.
- [ ] Test a 16 GB Mac with the adaptive runner.
- [ ] Verify `ollama ps` and confirm the intended processor placement.
- [ ] Confirm the runner works with the published model name.
- [ ] State clearly that this is an instruction/parameter derivative, not a fine-tuned weight release.
- [ ] Include Gemma attribution/license requirements applicable to the release.
- [ ] Publish the exact Modelfile and release notes used to build the model.

## Important performance note

Longer context does not automatically mean better coding performance. For an E4B edge model, a smaller context can be faster and leave more memory headroom, while larger context is valuable for whole-repository reasoning, logs, long specifications, and large refactors. The adaptive runner is designed to balance those tradeoffs instead of forcing the maximum context on every machine.
