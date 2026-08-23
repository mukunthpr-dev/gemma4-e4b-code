#!/bin/bash
set -euo pipefail

MODEL="${OLLAMA_CODE_MODEL:-gemma4-e4b-code}"

TOTAL_BYTES="$(sysctl -n hw.memsize)"
TOTAL_GB=$(( TOTAL_BYTES / 1024 / 1024 / 1024 ))

case "$TOTAL_GB" in
  0-15) CTX=16384 ;;
  16-23) CTX=32768 ;;
  24-31) CTX=49152 ;;
  32-47) CTX=65536 ;;
  48-63) CTX=98304 ;;
  *) CTX=131072 ;;
esac

export OLLAMA_FLASH_ATTENTION="${OLLAMA_FLASH_ATTENTION:-1}"
export OLLAMA_KV_CACHE_TYPE="${OLLAMA_KV_CACHE_TYPE:-q8_0}"
export OLLAMA_NUM_PARALLEL="${OLLAMA_NUM_PARALLEL:-1}"

echo "Gemma 4 E4B Coding Edition"
echo "Detected physical memory: ${TOTAL_GB} GiB"
echo "Recommended context: ${CTX} tokens"
echo "KV cache: ${OLLAMA_KV_CACHE_TYPE}"
echo "Flash Attention: ${OLLAMA_FLASH_ATTENTION}"
echo "Parallel requests: ${OLLAMA_NUM_PARALLEL}"
echo

echo "Starting Ollama model. Inside the session, set the adaptive context with:"
echo "  /set parameter num_ctx ${CTX}"
echo

# Ollama's interactive /set command is session-local. The Modelfile's 32K baseline
# remains the portable default; this wrapper selects a safer/higher context profile
# for the detected Mac once the interactive session starts.
exec ollama run "$MODEL"
