#!/usr/bin/env bash
set -euo pipefail

apply_proxy_env() {
  for v in HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy; do
    if [[ -n "${!v:-}" ]]; then
      export "$v"="${!v}"
    fi
  done
}

setup_x11() {
  if [[ -n "${DISPLAY:-}" ]]; then
    echo "DISPLAY=$DISPLAY"
  fi
}

setup_dds() {
  # peers.envから読み取る場合はcomposeのenv_fileで注入する
  if [[ -n "${CYCLONEDDS_PEERS:-}" ]]; then
    echo "CYCLONEDDS_PEERS=$CYCLONEDDS_PEERS"
  fi
}

