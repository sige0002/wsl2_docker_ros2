#!/bin/bash

# ==========================================================================
# Docker ROS2 環境起動スクリプト
# - ROS ディストリ選択、コンテナ名の一意化/固定化、DRY RUN をサポート
# ==========================================================================

set -euo pipefail

echo "=== Docker ROS2 環境を起動（準備） ==="

# プロジェクトルートディレクトリに移動
cd "$(dirname "$0")"

# 基本の Ctrl+C ハンドラ（確認待ち/ビルド中などで中断した場合に安全に終了）
trap 'echo; echo "Ctrl+C でキャンセルしました"; exit 130' INT

#--------------------------------------
# 引数パース
#--------------------------------------
ROS_ARG=""
NAME_ARG=""
FIXED_NAME="0"
DRY_RUN="0"
DO_UP="0"
DO_START="0"
COMPOSE_FILE="docker-compose.yml"
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      cat <<USAGE
Usage: $(basename "$0") [options]
  -h, --help          このヘルプを表示
  --ros <distro>      humble | iron | jazzy など
  --name <name>       コンテナ名を明示指定（最優先）
  --fixed             ランダム接尾辞を付けず固定名で起動（ros-<distro>-docker）
  --dry-run           変数解決のみ行い docker は実行しない
  -up,  --up          docker compose up -d を実行（確認プロンプトあり）
  -start, --start     docker compose start を実行（確認プロンプトあり）

ヒント:
  - 引数なしで実行すると、確認後に up -d し、ログ追従。Ctrl+C で停止/削除メニューを表示。
USAGE
      exit 0;;
    --ros)
      ROS_ARG="$2"; shift 2;;
    --name)
      NAME_ARG="$2"; shift 2;;
    --fixed)
      FIXED_NAME="1"; shift;;
    --dry-run)
      DRY_RUN="1"; shift;;
    -up|--up)
      DO_UP="1"; shift;;
    -start|--start)
      DO_START="1"; shift;;
    --compose)
      COMPOSE_FILE="$2"; shift 2;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

# .envファイルが存在しない場合は.env.exampleからコピー
if [ ! -f ".env" ]; then
    if [ -f "environment/.env.example" ]; then
        echo ".envファイルが見つかりません。environment/.env.exampleからコピー中..."
        cp environment/.env.example .env
        echo ".envファイルを作成しました。必要に応じて設定を確認してください。"
    else
        echo "警告: .envファイルと.env.exampleファイルの両方が見つかりません。"
        echo "環境変数が正しく設定されていない可能性があります。"
    fi
fi

# .env を取り込み（docker compose と同じディレクトリにあるため）
if [ -f .env ]; then
  set -a
  # shellcheck disable=SC1091
  . ./.env
  set +a
fi

# CLI の --ros があれば上書き
if [ -n "$ROS_ARG" ]; then
  export ROS_DISTRO_NAME="$ROS_ARG"
fi

if [ -z "${ROS_DISTRO_NAME:-}" ]; then
  echo "エラー: ROS_DISTRO_NAME が未設定です（--ros または .env）" >&2
  exit 1
fi

# ROS ディストリに基づき IMAGE_NAME を自動補完（未設定時のみ）
if [ -z "${IMAGE_NAME:-}" ]; then
  case "$ROS_DISTRO_NAME" in
    humble|iron)
      export IMAGE_NAME="ubuntu:22.04";;
    jazzy)
      export IMAGE_NAME="ubuntu:24.04";;
    *)
      echo "警告: 未対応の ROS_DISTRO_NAME=$ROS_DISTRO_NAME。IMAGE_NAME を自動設定できません。" >&2
      ;;
  esac
fi

# WSL2 の場合などで DISPLAY が未設定なら自動推定
if [ -z "${DISPLAY:-}" ]; then
  if grep -qi microsoft /proc/version 2>/dev/null; then
    gw=$(grep -m1 nameserver /etc/resolv.conf | awk '{print $2}')
    if [ -n "$gw" ]; then
      export DISPLAY="$gw:0"
    fi
  fi
fi

# コンテナ名の決定ロジック
# 優先度: --name > CONTAINER_NAME(.env/環境) > 固定/ランダム方針
if [ -n "$NAME_ARG" ]; then
  export CONTAINER_NAME="$NAME_ARG"
fi

SERVICE_PREFIX="ros"

if [ -z "${CONTAINER_NAME:-}" ]; then
  if [ "$FIXED_NAME" = "1" ]; then
    export CONTAINER_NAME="${SERVICE_PREFIX}-${ROS_DISTRO_NAME}-docker"
  else
    # ランダム接尾辞（10桁）
    suffix="-$(date +%s%N | sha256sum | head -c 10)"
    export NAME_SUFFIX="$suffix"
    export CONTAINER_NAME="${SERVICE_PREFIX}-${ROS_DISTRO_NAME}-docker$suffix"
  fi
fi

echo ""
echo "=== 起動パラメータ（確認） ==="
echo "ROS_DISTRO_NAME = ${ROS_DISTRO_NAME:-}"
echo "IMAGE_NAME      = ${IMAGE_NAME:-}"
echo "CONTAINER_NAME  = ${CONTAINER_NAME:-}"
echo "COMPOSE_FILE    = ${COMPOSE_FILE}"
echo "DISPLAY         = ${DISPLAY:-}"
echo "http_proxy      = ${http_proxy:-}"
echo "https_proxy     = ${https_proxy:-}"
echo "HTTP_PROXY      = ${HTTP_PROXY:-}"
echo "HTTPS_PROXY     = ${HTTPS_PROXY:-}"
echo "COMPOSE_PROJECT_NAME = ${COMPOSE_PROJECT_NAME:-(default)}"
echo "=============================="
echo ""

confirm() {
  local prompt="$1"
  local ans
  read -r -p "$prompt [y/N]: " ans || true
  case "$ans" in
    y|Y|yes|Yes) return 0;;
    *) return 1;;
  esac
}

if [ "$DRY_RUN" = "1" ]; then
  echo "[DRY RUN] docker compose build"
  echo "[DRY RUN] docker compose -f ${COMPOSE_FILE} up -d"
  echo "[DRY RUN] docker image prune -f"
  exit 0
fi

run_logs_and_trap() {
  echo "=== ログを追跡中（Ctrl+C で操作メニュー） ==="
  # ログ追跡中のみ Ctrl+C をメニューに差し替える
  trap 'on_ctrl_c' INT
  docker compose -f "${COMPOSE_FILE}" logs -f || true
  # 既定の Ctrl+C ハンドラへ戻す
  trap 'echo; echo "Ctrl+C でキャンセルしました"; exit 130' INT
}

on_ctrl_c() {
  echo
  echo "--- 操作メニュー ---"
  echo "[s] Stop コンテナを停止"
  echo "[d] Down コンテナを停止して削除"
  echo "[c] Cancel コンテナはそのままでログ（ターミナル）へ戻る"
  read -rsn1 -p "選択してください (s/d/c): " key; echo
  case "$key" in
    s|S)
      if confirm "コンテナを停止しますか？"; then
        docker compose stop || true
      fi
      ;;
    d|D)
      if confirm "コンテナを停止して削除しますか？"; then
        docker compose down || true
      fi
      ;;
    *) ;;
  esac
}

perform_up() {
  echo "=== Docker イメージをビルド中 ==="
  docker compose -f "${COMPOSE_FILE}" build
  echo "=== コンテナを起動中 (up -d) ==="
  docker compose -f "${COMPOSE_FILE}" up -d
  echo "=== 未使用イメージのクリーンアップ ==="
  docker image prune -f
  echo "=== 起動完了 ==="
  echo "コンテナに接続するには: docker exec -it ${CONTAINER_NAME} bash"
}

if [ "$DO_START" = "1" ]; then
  if confirm "docker compose start を実行します。よろしいですか？"; then
    docker compose -f "${COMPOSE_FILE}" start
    # start 後はログ追跡に入り、Ctrl+C メニューを有効化
    run_logs_and_trap
  else
    echo "キャンセルしました"
  fi
  exit 0
fi

if [ "$DO_UP" = "1" ]; then
  if confirm "docker compose up -d を実行します。よろしいですか？"; then
    perform_up
  else
    echo "キャンセルしました"
  fi
  exit 0
fi

# 引数なし: up 実行後にログ追跡、Ctrl+C で stop/down メニュー
if confirm "コンテナを起動しますか？ (up -d)"; then
  perform_up
  run_logs_and_trap
else
  echo "起動をスキップしました"
fi
