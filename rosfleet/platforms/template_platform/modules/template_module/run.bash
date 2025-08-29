#!/usr/bin/env bash
set -euo pipefail

echo "このモジュールは通常、platformの起動によりorchestrate.pyから起動されます。"
echo "単体検証でコンテナを起動する場合の例を示します。"

docker run --rm -it \
  --name template_module \
  --network host \
  --ipc host \
  --privileged \
  -e RMW_IMPLEMENTATION=rmw_cyclonedds_cpp \
  -e CYCLONEDDS_URI=file:///cyclonedds/cyclonedds.xml \
  -e DISPLAY=${DISPLAY:-:0} \
  -v "$(pwd)/workspace:/workspace" \
  -v "$(pwd)/cyclonedds:/cyclonedds:ro" \
  -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
  rosfleet/template_module:latest

