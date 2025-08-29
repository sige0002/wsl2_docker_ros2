#!/usr/bin/env bash
set -euo pipefail

echo "簡易デバッグCLI（例）: 目的に応じて拡張してください"
cat <<'EOS'
利用例:
  # コンテナ内でros2トピック列挙
  docker exec -it rosfleet_base ros2 topic list

  # ログの確認
  ls -la workspace/logs
EOS

