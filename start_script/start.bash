#!/bin/bash

# ==========================================================================
# Docker ROS2 環境起動スクリプト
# ==========================================================================

set -e  # エラー時に停止

echo "=== Docker ROS2 環境を起動中 ==="

# プロジェクトルートディレクトリに移動
cd "$(dirname "$0")/.."

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

# 現在の.env設定を表示
if [ -f ".env" ]; then
    echo ""
    echo "=== 現在の.env設定 ==="
    cat .env
    echo "========================"
    echo ""
else
    echo "警告: .envファイルが見つかりません。"
fi

# 10桁の乱数IDを生成し、環境変数に設定
export RANDOM_ID=$(date +%s%N | sha256sum | head -c 10)
echo "RANDOM_ID=$RANDOM_ID"

# イメージをビルド
echo "Dockerイメージをビルド中..."
docker compose build

# コンテナを起動
echo "コンテナを起動中..."
docker compose up -d

# 未使用イメージのクリーンアップ
echo "未使用イメージをクリーンアップ中..."
docker image prune -f

echo "=== 起動完了 ==="
echo "コンテナに接続するには以下のコマンドを実行してください:"
echo "docker compose exec ros bash"