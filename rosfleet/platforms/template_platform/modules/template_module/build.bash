#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/../../../.." && pwd)
cd "$ROOT_DIR"

echo "[build] Build base image rosfleet/base:latest"
docker build -f tools/docker/Dockerfile.base -t rosfleet/base:latest .

echo "[build] Build module image rosfleet/template_module:latest"
docker build \
  -f platforms/template_platform/modules/template_module/Dockerfile.module \
  -t rosfleet/template_module:latest .

echo "[build] done"

