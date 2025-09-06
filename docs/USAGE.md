# 使用方法 / 起動パターン（ROS2 on WSL2 + Docker Engine）

このドキュメントは、本リポジトリの現状構成と、状況に合わせた起動方法を網羅的にまとめたものです。

---

## 現状の構成

- devcontainer: `.devcontainer/devcontainer.json`
  - Compose の `service: ros` を開く VS Code 用設定。`workspaceFolder: /root`、初回に `colcon build` を実行。
- Dockerfile: `.devcontainer/Dockerfile`
  - ビルド引数 `IMAGE_NAME`（Ubuntu ベース）と `ROS_DISTRO_NAME` を受け取り、`ros-${ROS_DISTRO_NAME}-desktop` を APT からインストールする構成。
  - 代理設定（`http_proxy` など）、ロケール、共通ツール、`rosdep init/update` までを含む。
- Compose: `docker-compose.yml`
  - `build.args` に `.env` の値を渡し、`image: ros-${ROS_DISTRO_NAME}-docker` を作成。
  - `container_name: ${CONTAINER_NAME:-ros-${ROS_DISTRO_NAME}-docker}`（固定名が未指定ならディストリ名ベース）。
  - X11/USB マウント、`privileged: true`、`working_dir: /root`。
- 起動スクリプト: `./start.bash`
  - `.env` 自動作成/読込、`--ros/--name/--fixed/--dry-run` に対応。
  - `IMAGE_NAME` が未設定なら `ROS_DISTRO_NAME` から Ubuntu を自動補完（humble/iron → 22.04、jazzy → 24.04）。
  - WSL2 を検知した場合、`DISPLAY` 未設定なら自動推定。
- 環境テンプレート: `environment/.env.example`
  - `ROS_DISTRO_NAME` の例、プロキシ変数、`CONTAINER_NAME`/`COMPOSE_PROJECT_NAME` の使い方を記載。

---

## 前提条件

- WSL2 + Ubuntu（推奨: LTS）
- Docker Engine（WSL2 側にインストール）
- X を用いた GUI を表示したい場合はホスト側の X サーバ（例: Windows の X410, VcXsrv 等）

---

## .env の準備

1. 初回は `.env` がなければ自動で `environment/.env.example` からコピーされます。
2. 編集する主な項目
   - `ROS_DISTRO_NAME`: `humble` / `iron` / `jazzy` など
   - `IMAGE_NAME`: 空なら起動スクリプトが自動補完します
   - `http_proxy`/`https_proxy`/`HTTP_PROXY`/`HTTPS_PROXY`: 必要な場合のみ
   - （任意）`CONTAINER_NAME`: 固定名で運用したい場合
   - （任意）`COMPOSE_PROJECT_NAME`: ディストリごとにネットワーク等を分離したい場合

---

## 起動方法（状況別）

以下のコマンドは、すべてリポジトリのルート（`wsl2_docker_ros2/`）から実行します。スクリプトは `./start.bash` に移動しました。

### 1) 標準（上書きされないユニーク名）

- ランダム接尾辞付きのコンテナ名で起動（既存と衝突しません）

```
./start.bash
```

例: `ros-jazzy-docker-xxxxxxxxxx`

### 2) 固定名で起動（上書き運用）

- 同じ名前で差し替えたい場合は `--fixed` を付けるか、`.env` で `CONTAINER_NAME` を指定します。

```
./start.bash --fixed
# または
CONTAINER_NAME=ros-jazzy-docker ./start.bash
# または .env に CONTAINER_NAME=ros-${ROS_DISTRO_NAME}-docker を追記
```

### 3) 任意のコンテナ名を指定

```
./start.bash --name custom-ros
```

### 4) ROS バージョンの切り替え

- 起動時に `--ros` で切替できます。
- `.env` の `IMAGE_NAME` が空なら Ubuntu ベースを自動補完します。

```
./start.bash --ros humble    # → IMAGE_NAME=ubuntu:22.04 を自動補完
./start.bash --ros iron      # → IMAGE_NAME=ubuntu:22.04 を自動補完
./start.bash --ros jazzy     # → IMAGE_NAME=ubuntu:24.04 を自動補完
```

> 注意: `.env` に `IMAGE_NAME` を明示設定している場合は、補完は行われません。

### 5) 代理（プロキシ）を通す

`.env` に以下を設定します。

```
http_proxy=http://proxy.example.com:8080
https_proxy=http://proxy.example.com:8080
HTTP_PROXY=http://proxy.example.com:8080
HTTPS_PROXY=http://proxy.example.com:8080
```

### 6) DISPLAY の自動設定（WSL2）

- WSL2 環境では `DISPLAY` が未設定なら起動スクリプトが自動推定します。
- うまく表示されない場合は、手動で `DISPLAY` を上書きしてください。

```
DISPLAY=192.168.1.10:0 ./start.bash
```

### 7) ドライラン（検証のみ）

- 実際の `docker compose` を実行せず、変数解決結果を確認します。

```
./start.bash --dry-run

---

## 新しいショートカット操作と安全機能

- ヘルプ表示: `./start.bash -h`
- 直起動（確認付きで up -d → ログ追跡 → Ctrl+C でメニュー）: `./start.bash`
- 明示的に up 実行（確認プロンプトあり）: `./start.bash -up`
- 明示的に start 実行（確認プロンプトあり）: `./start.bash -start`（実行後はログ追跡に入り、Ctrl+C メニューが使えます）
- ログ追跡中に Ctrl+C:
  - `s` で Stop（確認あり）
  - `d` で Down（停止して削除。確認あり）
  - `c` でキャンセル（ログへ戻る）

- 確認プロンプトやビルド中の Ctrl+C:
  - 安全にキャンセルして終了（`Ctrl+C でキャンセルしました` と表示）
  - もう一度 `./start.bash` を実行してやり直せます

> 誤操作防止: 破壊的操作（down/stop）は必ず確認プロンプトが出ます。

---

## サンプルワークスペース（example_ws）

- 本リポジトリに `example_ws` を同梱し、コンテナに `/root/example_ws` としてマウントしています。
- Python 製のトーカーノード `py_talker` が含まれます。

コンテナ内でのビルドと実行例:

```
docker exec -it <コンテナ名> bash
cd /root/example_ws
source /opt/ros/$ROS_DISTRO/setup.bash
colcon build --symlink-install
source /root/example_ws/install/setup.bash
ros2 run py_talker talker
```
```

---

## よく使う操作

- コンテナに入る

```
docker exec -it <コンテナ名> bash
```

- ログを確認

```
docker compose logs -f
```

- 停止 / 削除 / 再ビルド

```
docker compose down
docker rm -f <コンテナ名>
docker compose build --no-cache
```

---

## VS Code Dev Containers で開く

- VS Code の「Reopen in Container」で `service: ros` が起動します。
- `container_name` は `ros-${ROS_DISTRO_NAME}-docker`（`.env` で上書き可）。
- 開発中は devcontainer に任せ、通常の `start.bash` は並行して起動しないことを推奨します（名前衝突を避けるため）。

---

## トラブルシュートのヒント

- X11 が表示されない: ホスト側 X サーバが起動しているか確認。`DISPLAY` を手動指定。
- APT/鍵エラー: ネットワーク・プロキシ設定を確認。`ros.key` の取得や `rosdep update` がブロックされていないか確認。
- 既存の同名コンテナが邪魔: `docker rm -f <コンテナ名>` で手動削除してから再起動。

---

## 変更要約（今回の更新点）

- `container_name` を環境変数化（固定名・ユニーク名の両立）
- `start.bash` に `--ros/--name/--fixed/--dry-run` を追加
- `IMAGE_NAME` 自動補完（humble/iron → 22.04、jazzy → 24.04）
- `https_proxy`/`HTTPS_PROXY` の参照ミス修正
### 8) Nav2 学習用コンテナを使う（既存を壊さない）

- Nav2 用の別 compose ファイルを追加しています。既存の `docker-compose.yml` には影響しません。
- 起動例:

```
# Nav2 用 compose を選択して起動
./start.bash --nav2 --fixed          # ファイル: docker-compose.nav2.yml

# または任意の compose を直接指定
./start.bash --compose docker-compose.nav2.yml --fixed
```

- コンテナ名の既定: `nav2-<distro>-docker`（`--name` で上書き可）
- イメージのビルドターゲット: `nav2`（Dockerfile の Nav2 ステージ）
- 既存の ROS コンテナ（`ros-<distro>-docker`）と並存可能です。
