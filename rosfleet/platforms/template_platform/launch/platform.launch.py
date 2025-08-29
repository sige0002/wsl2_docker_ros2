#!/usr/bin/env python3
from pathlib import Path
from launch import LaunchDescription
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.actions import IncludeLaunchDescription


def generate_launch_description() -> LaunchDescription:
    base = Path(__file__).resolve().parent.parent
    module_launch = base / "modules" / "template_module" / "launch" / "module.launch.py"

    return LaunchDescription([
        IncludeLaunchDescription(
            PythonLaunchDescriptionSource(str(module_launch))
        )
    ])

