# 目次

- [目次](#目次)
- [WSL2とDocker EngineでROS2環境を構築する ](#wsl2とdocker-engineでros2環境を構築する-)
- [はじめに](#はじめに)
  - [概要](#概要)
  - [本ドキュメントの目的](#本ドキュメントの目的)
  - [なぜ Docker Desktop ではなく Docker Engine？](#なぜ-docker-desktop-ではなく-docker-engine)
  - [この手順で得られること](#この手順で得られること)
- [1. WSL2とDocker EngineでROS2環境を構築する](#1-wsl2とdocker-engineでros2環境を構築する)
  - [1.1 WSL2のインストール](#11-wsl2のインストール)
  - [1.2 WSL2のバージョン確認とアップグレード（任意）](#12-wsl2のバージョン確認とアップグレード任意)
  - [1.3 Docker Engineのインストール](#13-docker-engineのインストール)
- [2. 実行](#2-実行)
  - [インストール手順](#インストール手順)
- [3. Tips](#3-tips)
  - [3.1 Gitのインストール](#31-gitのインストール)
  - [3.2 Git 初期化からGitHubへの初回アップロード手順](#32-git-初期化からgithubへの初回アップロード手順)

---

# WSL2とDocker EngineでROS2環境を構築する <!-- TOC -->

# はじめに

このドキュメントでは、**WSL2** と **Docker Engine** を用いて **ROS2 環境を構築する手順**を解説します。  
この構成を覚えることで

---

## 概要

- **WSL2（Windows Subsystem for Linux v2）**  
  Windows 上で Linux 環境を実行できる機能です。
- **Docker Engine**  
  コンテナ化されたアプリケーションを実行するためのプラットフォームです。
- **ROS2（Robot Operating System 2）**  
  ロボットアプリケーションの開発に広く使われるオープンソースミドルウェアです。

---

## 本ドキュメントの目的

このドキュメントは、ROS2のインストールおよび開発を行う前に、  
**WSL2とDocker Engineのセットアップを完了させること**を目的としています。

---

## なぜ Docker Desktop ではなく Docker Engine？

- Docker Desktop は **商用利用が有料**です。
- 一方で、**WSL2 + Docker Engine の構成は無料で利用可能**です。
- よって、コストを抑えて ROS2 開発環境を構築することができます。

---

## この手順で得られること

このセットアップを完了することで：

- Docker 上で ROS2 環境が動作する
- Windows 上で安定した ROS2 開発ができる
- GUI アプリケーション（RViz など）も表示可能

---

# 1. WSL2とDocker EngineでROS2環境を構築する
- すでにwslとdocker engineがある場合は，2. 「実行まで」から始める．

## 1.1 WSL2のインストール

- **前提条件**
  - Windows 11を使用していること
  - WSL2が未インストールであること

> すでにインストール済みの場合はこの手順を省略してください。

1. 検索ボックスに「コントロールパネル」と入力し，表示されたアプリをクリックする．
2. 「プログラム」をクリックし，「プログラムと機能」内の「Windows の機能の有効化または無効化」を選択する．
3. 「仮想化マシン プラットフォーム」と「Linux用Windowsサブシステム」を有効にし，PCを再起動する．
4. コマンドプロンプトで以下を実行し，WSL2をインストールする（規定ではUbuntuがインストールされる）．

  ```sh
  wsl --install
  ```

  - 参考: [Microsoft公式ドキュメント](https://learn.microsoft.com/ja-jp/windows/wsl/install#install-wsl-command)

5. Linuxユーザー情報を設定する．WSLのインストール後，初回接続時にLinuxディストリビューションのユーザーアカウントとパスワードを作成する．インストールが完了すると，スタートメニューにUbuntuが追加されるので，そこからインストールしたディストリビューションに接続する．

    - ここで作成されるアカウントが規定のユーザーとして設定され，接続時に自動的にサインインされる．
    - このユーザーはWindows側のユーザーとは関係なく，インストールするディストリビューションごとに固有となる．また，このユーザーはLinux管理者として`sudo`コマンドが実行できる．

---

## 1.2 WSL2のバージョン確認とアップグレード（任意）

WSL2のバージョンを確認するには，WSL内で以下のコマンドを実行する．

  ```sh
  cat /etc/os-release
  ```

  **出力例**
  ```
  PRETTY_NAME="Ubuntu 22.04.2 LTS"
  NAME="Ubuntu"
  VERSION_ID="22.04"
  VERSION="22.04.2 LTS (Jammy Jellyfish)"
  VERSION_CODENAME=jammy
  ...
  ```

システムをアップデートする．

  ```sh
  sudo apt update
  sudo apt upgrade
  ```

WSLをシャットダウンする．

  ```sh
  wsl --shutdown
  ```

再度WSLに入り，アップグレード可能なバージョンを確認する．

  ```sh
  do-release-upgrade -c
  ```

  **出力例**
  ```
  Checking for a new Ubuntu release
  New release '24.04.2 LTS' available.
  Run 'do-release-upgrade' to upgrade to it.
  ```

アップグレードする場合は以下を実行する．

  ```sh
  sudo do-release-upgrade
  ```

---

## 1.3 Docker Engineのインストール

- **前提条件**：WSL2がインストールされていること

1. WSL内に入り，GUI表示用のLinuxウィンドウシステム「X11」アプリケーションをインストールする．

  ```sh
  sudo apt install x11-apps
  ```

    `xeyes`と入力し，目玉が表示されれば成功と判断する．

2. Docker Engineをインストールするために必要なパッケージをインストールする．

3. Dockerの古いバージョンの削除  
   Docker Engineをインストールする前に、競合するパッケージをアンインストールします。  
   参考: [Docker公式ドキュメント](https://docs.docker.com/engine/install/ubuntu/)

  ```sh
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
  ```

4. Docker Engineのリポジトリを追加する．

  ```sh
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  ```

5. 最新バージョンをインストールするには，次のコマンドを実行する（特定のバージョンを入れたい場合は参考2を参照）．

  ```sh
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  ```

6. イメージを実行してインストールが成功したことを確認する．

  ```sh
  sudo docker run hello-world
  ```

7. 実行権限がない場合は以下のコマンドを実行する．

  ```sh
  sudo usermod -aG docker $USER
  ```

    その後，WSLを再起動する．

# 2. 実行まで
## インストール
- git clone でリポジトリをクローンする．
```sh
git clone https://github.com/your-username/your-repo.git
```

# 3. Tips

## 3.1 Gitのインストール

Gitのインストール方法は公式ドキュメント等を参照する．  
ユーザ設定例：

  ```sh
  git config --global user.name "your_name"
  git config --global user.email "your_email@example.com"
  ```

---

## 3.2 Git 初期化からGitHubへの初回アップロード手順

ここでは，ローカルフォルダをGitHub上のリモートリポジトリにアップロードするための一連の操作を説明する．

```sh
# 1. 対象のプロジェクトディレクトリへ移動
cd /path/to/your/project

# 例（Windows の場合）
cd C:\Users\YourName\your_project_folder

# 2. Gitリポジトリを初期化
git init

# 3. すべてのファイルをステージング（インデックスに追加）
git add .

# 4. 最初のコミットを作成
git commit -m "Initial commit"

# 5. リモートリポジトリを登録（すでに origin がある場合は set-url で上書き）

# まだリモートリポジトリを登録していない場合
git remote add origin <リモートリポジトリURL>

# 例
git remote add origin https://github.com/your-username/your-repo.git

# すでに origin が存在する場合はURLを上書き
git remote set-url origin <リモートリポジトリURL>

# 例
git remote set-url origin https://github.com/your-username/your-repo.git

# ブランチ名を main に変更（GitHub のデフォルトに合わせる）
git branch -M main

# リモートリポジトリへ push（初回）
git push -u origin main
```
