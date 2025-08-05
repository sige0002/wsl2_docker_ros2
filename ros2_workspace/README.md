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
