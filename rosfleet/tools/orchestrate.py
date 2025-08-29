#!/usr/bin/env python3
"""
system.json と 各 platform.json を解釈して、起動対象や環境を決める最小の雛形。

現状は起動仕様の検査と概要出力のみ。実行系（docker compose生成等）は今後拡張。
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict


ROOT = Path(__file__).resolve().parents[1]


def load_json(path: Path) -> Dict[str, Any]:
    with open(path, 'r') as f:
        return json.load(f)


def main() -> None:
    system_path = ROOT / 'system.json'
    if not system_path.exists():
        raise FileNotFoundError(f"system.json が見つかりません: {system_path}")

    system = load_json(system_path)
    platform_name = system.get('platform')
    if not platform_name:
        raise ValueError("system.json の 'platform' が未設定です")

    platform_dir = ROOT / 'platforms' / platform_name
    platform_json = platform_dir / 'platform.json'
    if not platform_json.exists():
        raise FileNotFoundError(f"platform.json が見つかりません: {platform_json}")

    platform = load_json(platform_json)

    print("=== rosfleet orchestrate preview ===")
    print(f"platform: {platform.get('name')} (ROS: {platform.get('ros_distro')})")
    print(f"launch:   {platform.get('launch_file')}")
    env_files = platform.get('env_files', [])
    if env_files:
        print("env_files:")
        for ef in env_files:
            print(f"  - {ef}")
    modules = platform.get('modules', [])
    print("modules:")
    for m in modules:
        print(f"  - {m.get('name')} (path={m.get('path')}, params={m.get('params')})")

    print("\n次のステップ（提案）:")
    print("  1) baseイメージのビルド: docker build -f tools/docker/Dockerfile.base -t rosfleet/base:latest .")
    print("  2) 各moduleのビルド: platforms/<platform>/modules/<module>/build.bash")
    print("  3) ROS 2起動: docker run または compose を生成して起動（今後の拡張）")


if __name__ == '__main__':
    main()

