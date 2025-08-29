#!/usr/bin/env bash
set -euo pipefail

source /opt/ros/$ROS_DISTRO/setup.bash || true
source /opt/rosfleet/helpers.sh || true

apply_proxy_env || true
setup_x11 || true
setup_dds || true

# ログディレクトリ初期化（プラットフォーム名が未指定ならtemplate_platform）
PLATFORM_NAME=${PLATFORM:-template_platform}
export ROS_LOG_DIR=/workspace/logs/${PLATFORM_NAME}
mkdir -p "$ROS_LOG_DIR"

# CycloneDDS設定（composeからCYCLONEDDS_URIを渡す想定）
if [[ -z "${CYCLONEDDS_URI:-}" && -f /cyclonedds/cyclonedds.xml ]]; then
  export CYCLONEDDS_URI=file:///cyclonedds/cyclonedds.xml
fi

exec "$@"

