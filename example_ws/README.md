example_ws
=========

シンプルな ROS 2 Python ノード（talker）を含むサンプルワークスペースです。

ビルド（コンテナ内）
--------------------

```
cd /root/example_ws
source /opt/ros/$ROS_DISTRO/setup.bash
colcon build --symlink-install
```

実行（コンテナ内）
------------------

```
source /opt/ros/$ROS_DISTRO/setup.bash
source /root/example_ws/install/setup.bash
ros2 run py_talker talker
```

