#!/usr/bin/env python3
from pathlib import Path
from launch import LaunchDescription
from launch_ros.actions import Node
import yaml


def _params():
    params_path = Path(__file__).resolve().parent.parent / 'params' / 'example.yaml'
    if params_path.exists():
        with open(params_path, 'r') as f:
            return yaml.safe_load(f)
    return {}


def generate_launch_description() -> LaunchDescription:
    params = _params()
    return LaunchDescription([
        Node(
            package='my_pkg',
            executable='my_node',
            name='my_node',
            output='screen',
            parameters=[params] if params else []
        )
    ])

