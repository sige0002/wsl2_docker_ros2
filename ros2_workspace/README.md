# ROS2 Workspace

このディレクトリはROS2ワークスペースです。

## 構造
- `src/` - ROS2パッケージのソースコード
- `build/` - ビルド成果物（自動生成）
- `install/` - インストールされたパッケージ（自動生成）
- `log/` - ビルドログ（自動生成）

## 使用方法

コンテナ内で以下のコマンドを実行してワークスペースをビルドします：

```bash
cd /root/ros2_ws
colcon build
source install/setup.bash
```

## 必要なSDKについて

カメラSDKなどの大きなファイルは、GitHubのファイルサイズ制限により、このリポジトリには含まれていません。
必要に応じて以下から取得してください：

- **Linux CameraSDK**: メーカーの公式サイトまたは開発者に確認してください
  - ファイル名例: `Linux_CameraSDK-2.0.2-build1_MediaSDK-3.0.5-build1.zip`
  - 配置場所: `src/` ディレクトリ内

取得したSDKファイルは `src/` ディレクトリに配置してご利用ください。
