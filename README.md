# WSL2とDockerでros2を動かしてみよう
# 目次
- [WSL2とDockerでros2を動かしてみよう](#wsl2とdockerでros2を動かしてみよう)
- [目次](#目次)
- [1. WSL2とDocker EngineでROS2環境を構築する](#1-wsl2とdocker-engineでros2環境を構築する)
  - [1.1 WSL2のインストール](#11-wsl2のインストール)
    - [前提条件](#前提条件)
    - [1.2 WSLの起動とシャットダウン](#12-wslの起動とシャットダウン)
  - [1.2 WSL2のバージョン確認とアップグレード（任意）](#12-wsl2のバージョン確認とアップグレード任意)
  - [1.3 Docker Engineのインストール](#13-docker-engineのインストール)
    - [前提条件](#前提条件-1)
- [2. 実行まで](#2-実行まで)
  - [インストール](#インストール)
- [3. Tips](#3-tips)
  - [2.1 Gitのインストール](#21-gitのインストール)
  - [2.2 Git 初期化からGitHubへの初回アップロード手順](#22-git-初期化からgithubへの初回アップロード手順)


# 1. WSL2とDocker EngineでROS2環境を構築する

> **すでにWSLとDocker Engineがある場合は，[2. 実行まで](#2-実行まで)から始めてください。**

---

## 1.1 WSL2のインストール

### 前提条件

- Windows 11を使用していること
- WSL2が未インストールであること

> すでにインストール済みの場合はこの手順を省略してください。

1. 検索ボックスに「コントロールパネル」と入力し、表示されたアプリをクリックします。
2. 「プログラム」→「プログラムと機能」→「Windows の機能の有効化または無効化」を選択します。
3. 「仮想化マシン プラットフォーム」と「Linux用Windowsサブシステム」を有効にし、PCを再起動します。
4. コマンドプロンプトで以下を実行し、WSL2をインストールします（規定ではUbuntuがインストールされます）。

  ```sh
  wsl --install
  ```

  - 参考: [Microsoft公式ドキュメント](https://learn.microsoft.com/ja-jp/windows/wsl/install#install-wsl-command)

5. Linuxユーザー情報を設定します。WSLのインストール後、初回接続時にLinuxディストリビューションのユーザーアカウントとパスワードを作成します。インストールが完了すると、スタートメニューにUbuntuが追加されるので、そこからインストールしたディストリビューションに接続します。

  - ここで作成されるアカウントが規定のユーザーとなり、接続時に自動的にサインインされます。
  - このユーザーはWindows側のユーザーとは関係なく、ディストリビューションごとに固有です。また、Linux管理者として`sudo`コマンドが実行できます。

---

### 1.2 WSLの起動とシャットダウン

- WSLを起動するには、スタートメニューから「Ubuntu」などのインストールしたディストリビューションを選択するか、コマンドプロンプトやPowerShellで以下を実行します。

  ```sh
  wsl
  ```

- VSCodeではRemote Development拡張機能を使用してWSLに接続できます。左下の`><`アイコンをクリックし、WSLに接続を選択してください。

- WSLをシャットダウンするには、以下を実行します。

  ```sh
  wsl --shutdown
  ```

---

## 1.2 WSL2のバージョン確認とアップグレード（任意）

- WSL2のバージョンを確認するには、WSL内で以下を実行します。

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

- システムをアップデートします。

  ```sh
  sudo apt update
  sudo apt upgrade
  ```

- WSLをシャットダウンします。

  ```sh
  wsl --shutdown
  ```

- 再度WSLに入り、アップグレード可能なバージョンを確認します。

  ```sh
  do-release-upgrade -c
  ```

  **出力例**
  ```
  Checking for a new Ubuntu release
  New release '24.04.2 LTS' available.
  Run 'do-release-upgrade' to upgrade to it.
  ```

- アップグレードする場合は以下を実行します。

  ```sh
  sudo do-release-upgrade
  ```

---

## 1.3 Docker Engineのインストール

### 前提条件

- WSL2がインストールされていること

1. WSL内に入り、GUI表示用のLinuxウィンドウシステム「X11」アプリケーションをインストールします。

  ```sh
  sudo apt install x11-apps
  ```

  `xeyes`と入力し、目玉が表示されれば成功です。

2. Docker Engineをインストールするために必要なパッケージをインストールします。

3. Dockerの古いバージョンの削除  
   Docker Engineをインストールする前に、競合するパッケージをアンインストールします。  
   参考: [Docker公式ドキュメント](https://docs.docker.com/engine/install/ubuntu/)

  ```sh
  for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
  ```

4. Docker Engineのリポジトリを追加します。

  ```sh
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  ```

5. 最新バージョンをインストールするには、次のコマンドを実行します（特定のバージョンを入れたい場合は公式ドキュメント参照）。

  ```sh
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  ```

6. イメージを実行してインストールが成功したことを確認します。

  ```sh
  sudo docker run hello-world
  ```

7. 実行権限がない場合は以下を実行します。

  ```sh
  sudo usermod -aG docker $USER
  ```

  その後、WSLを再起動してください。

---

# 2. 実行まで

## インストール

- `git clone`でリポジトリをクローンします。

  ```sh
  git clone https://github.com/your-username/your-repo.git
  ```

---

# 3. Tips

## 2.1 Gitのインストール

- Gitのインストール方法は公式ドキュメント等を参照してください。

- ユーザ設定例：

  ```sh
  git config --global user.name "your_name"
  git config --global user.email "your_email@example.com"
  ```

---

## 2.2 Git 初期化からGitHubへの初回アップロード手順

ローカルフォルダをGitHub上のリモートリポジトリにアップロードするための一連の操作例です。

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
