# 目次

- [目次](#目次)
- [WSL2とDocker EngineでROS2環境を構築する](#wsl2とdocker-engineでros2環境を構築する)
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

# WSL2とDocker EngineでROS2環境を構築する

---

# はじめに

このドキュメントでは、**WSL2** と **Docker Engine** を用いて **ROS2 環境を構築する手順**を解説します。  
この構成を覚えることでローカル環境に依存せずにROS2の開発環境を構築できるようになります。
> **注意:**  
> GitHubリポジトリに`develop`ブランチが存在する場合、そちらが最新の開発環境となっています。必要に応じて`develop`ブランチを利用してください。

>**issueの投稿:**
>問題が発生した場合はissueに投稿してください.また、その他TipsはWikiに上げていることがあります．

---

## 概要

- **WSL2（Windows Subsystem for Linux v2）**  
  Windows上でLinux環境を実行できる機能です。
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

- Docker Desktopは **商用利用が有料**です。
- 一方で、**WSL2 + Docker Engine の構成は無料で利用可能**です。
- よって、コストを抑えてROS2開発環境を構築することができます。

---

## この手順で得られること

このセットアップを完了することで：

- Docker上でROS2環境が動作する
- Windows上で安定したROS2開発ができる
- GUIアプリケーション（RVizなど）も表示可能

---

# 1. WSL2とDocker EngineでROS2環境を構築する

> すでにWSLとDocker Engineがある場合は、[2. 実行](#2-実行) から始めてください。

## 1.1 WSL2のインストール

**前提条件**

- Windows 11を使用している（10では未検証）
- WSL2が未インストールである
- ホスト（Windows側）にVSCodeがインストールされている（開発環境として推奨）
- VSCodeに必要な拡張機能はTipsを参照（未編集）
- 必須なのは「Remote Development」「Dev Containers」
- 基本UbuntuはLTSバージョンを使用することを推奨、ROSのバージョンに合わせて選択すること

> すでにインストール済みの場合はこの手順を省略してください。

1. 検索ボックスに「コントロールパネル」と入力し、表示されたアプリをクリック。
2. 「プログラム」をクリックし、「プログラムと機能」内の「Windows の機能の有効化または無効化」を選択。
3. 「仮想化マシン プラットフォーム」と「Linux用Windowsサブシステム」を有効にし、PCを再起動。
4. コマンドプロンプトで以下を実行し、WSL2をインストール（規定ではUbuntuがインストールされる）。

    ```sh
    wsl --install
    ```

    - 参考: [Microsoft公式ドキュメント](https://learn.microsoft.com/ja-jp/windows/wsl/install#install-wsl-command)

5. Linuxユーザー情報を設定。WSLのインストール後、初回接続時にLinuxディストリビューションのユーザーアカウント（英数字のみ推奨）とパスワードを作成。インストールが完了すると、スタートメニューにUbuntuが追加されるので、そこからインストールしたディストリビューションに接続。

    - ここで作成されるアカウントが規定のユーザーとして設定され、接続時に自動的にサインインされます。
    - このユーザーはWindows側のユーザーとは関係なく、インストールするディストリビューションごとに固有となります。また、このユーザーはLinux管理者として`sudo`コマンドが実行できます。

---

## 1.2 WSL2のバージョン確認とアップグレード（任意）

WSL2のバージョンを確認するには、WSL内で以下のコマンドを実行します。

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

システムをアップデートします。

```sh
sudo apt update
sudo apt upgrade
```

WSLをシャットダウンします。

```sh
wsl --shutdown
```

再度WSLに入り、アップグレード可能なバージョンを確認します。

```sh
do-release-upgrade -c
```

**出力例**
```
Checking for a new Ubuntu release
New release '24.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.
```

アップグレードする場合は以下を実行します。

```sh
sudo do-release-upgrade
```

---

## 1.3 Docker Engineのインストール

**前提条件**：WSL2がインストールされていること

1. WSL内に入り、GUI表示用のLinuxウィンドウシステム「X11」アプリケーションをインストール。このときupdateもしておく

    ```sh
    sudo apt-get update
    sudo apt install x11-apps
    ```

    `xeyes`と入力し、目玉が表示されれば成功です。

2. Docker Engineをインストールするために必要なパッケージをインストール。

3. Dockerの古いバージョンの削除  
   Docker Engineをインストールする前に、競合するパッケージをアンインストールします。  
   参考: [Docker公式ドキュメント](https://docs.docker.com/engine/install/ubuntu/)

    ```sh
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
    ```

4. Docker Engineのリポジトリを追加。

    ```sh
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    ```

5. 最新バージョンをインストールするには、次のコマンドを実行（特定のバージョンを入れたい場合は参考2を参照）。

    ```sh
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

6. イメージを実行してインストールが成功したことを確認。

    ```sh
    sudo docker run hello-world
    ```

7. 実行権限がない場合は以下のコマンドを実行。

    ```sh
    sudo usermod -aG docker $USER
    ```

    その後、WSLを再起動してください。

---

# 2. 実行

## インストール手順

1. **リポジトリのクローン**  
   Gitでリポジトリを任意のディレクトリでクローンします（Gitの使い方は[3. Tips](#3-tips)を参照、日本語のファイルパスはできるだけ含めない。WSLの場合、`home/ユーザー名/`以下に置けば問題ありません）。

    ```sh
    git clone https://github.com/sige0002/wsl2_docker_ros2.git
    ```
    > **注意**:  
    > クローンする際は、WSL内で実行してください。WindowsのコマンドプロンプトやPowerShellでは動作しません。また、developブランチの方が最新の情報が反映されているため、必要に応じてブランチを切り替えてください。

    ```sh
    git clone -b develop https://github.com/sige0002/wsl2_docker_ros2.git
    ```

2. **`.env`ファイルの作成**  
   `.env.example`をコピーして`.env`にリネームします。

    ```sh
    cp .env.example .env
    ```

3. **`.env`の編集**  
   必要に応じて以下の値を編集します。

   - `IMAGE_NAME`  
     DockerイメージのベースとなるUbuntuのバージョンを指定します。  
     例: `ubuntu:24.04`（Ubuntu 24.04 LTS）、`ubuntu:22.04`（Ubuntu 22.04 LTS）など

   - `ROS_DISTRO_NAME`  
     ROS2のディストリビューション名を指定します。  
     例: `jazzy`, `humble`, `galactic`, `foxy` など

   - プロキシ設定  
     プロキシを使用しない場合は空欄のままにします。  
     プロキシを使用する場合は、`http_proxy`, `https_proxy`, `HTTP_PROXY`, `HTTPS_PROXY`の値を設定してください。

     > **注意:**  
     > すべて空欄の場合もしくは，すべて設定してある場合のみビルドできる設定になっています。一部のみ変更したい場合は、`Dockerfile`内の該当箇所（`RUN if [ -z "$http_proxy" ] && [ -z "$https_proxy" ]; then ...`）を編集してください。

4. **Dockerイメージのビルド**  
   以下のコマンドをクローンしたフォルダディレクトリで実行して、Dockerイメージをビルドします。

    ```sh
    cd wsl2_docker_ros2
    docker compose build
    ```

   これが成功すると、dockerイメージが作成されます。  
   イメージの確認は以下のコマンドで行えます。

    ```sh
    docker images
    ```

5. **コンテナの起動**  
   以下のコマンドを実行して、Dockerコンテナを起動します。

    ```sh
    docker compose up -d
    ```

   コンテナが起動したら、以下のコマンドでコンテナに接続します。

    ```sh
    docker exec -it <コンテナ名> /bin/bash
    ```

   ここで `<コンテナ名>` は、`docker compose up` 実行時に表示されるコンテナ名を指定します。
   devcontainerを使ったvscode開発環境を構築する場合，.devcontainerがあるディレクトリで以下のコマンドを実行します。

    ```sh
    code .
    ```

6. **GUIアプリケーションの確認**  
   コンテナ内でGUIアプリケーションを実行して、X11が正しく設定されているか確認します。

    ```sh
    xeyes
    ```

   `xeyes`（目玉のアプリケーション）が表示されれば成功です。

7. **ROS2の環境変数の確認**  
   コンテナ内でROS2の環境変数が正しく設定されているか確認します。

    ```sh
    echo $ROS_DISTRO
    ```

   `humble` や `jazzy` など、指定したROS2ディストリビューション名が表示されれば成功です。

---

# 3. Tips

## 3.1 Gitのインストール

Gitのインストール方法は公式ドキュメント等を参照してください。  
ユーザ設定例：

```sh
git config --global user.name "your_name"
git config --global user.email "your_email@example.com"
```

---

## 3.2 Git 初期化からGitHubへの初回アップロード手順

ここでは、ローカルフォルダをGitHub上のリモートリポジトリにアップロードするための一連の操作を説明します。

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
