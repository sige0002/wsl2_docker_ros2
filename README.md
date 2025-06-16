# 1. WSL2とDocker EngineでROS2環境を構築する

## 1.1. WSL2のインストール

- **前提**：Windows 11を使用していること
- **前提**：WSL2が未インストールであること

> すでにインストール済みの場合、この手順は不要です。

1. 検索ボックスに「コントロールパネル」と入力し、表示されたアプリをクリックする
2. 「プログラム」をクリックし、「プログラムと機能」内の「Windows の機能の有効化または無効化」を選択する
3. 「仮想化マシン プラットフォーム」と「Linux用Windowsサブシステム」を有効にし、PCを再起動する
4. コマンドプロンプトで以下を実行し、WSL2をインストールする

    ```sh
    wsl --install
    ```

- 参考：[Microsoft公式ドキュメント](https://learn.microsoft.com/ja-jp/windows/wsl/install#install-wsl-command)

## 1.2. WSL2のバージョン確認とアップグレード

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
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
```

wsl内のシステムをアップデートします。

```sh
sudo apt update
sudo apt upgrade
```
wslをシャットダウンします。

```sh
wsl --shutdown
```
wslにもう一度入り，do-release-upgradeでアップグレード可能なバージョンがあるかを確認
```sh
do-release-upgrade -c
```
以下のような表示が出る
```sh
Checking for a new Ubuntu release
New release '24.04.2 LTS' available.
Run 'do-release-upgrade' to upgrade to it.
```
この場合24.04.2 LTSにアップグレード可能で以下のコマンドを実行してアップグレードできる．
```sh
sudo do-release-upgrade
```

---

# 2. Tips

## 2.1. Gitのインストール

Gitのインストール方法は公式ドキュメント等を参照してください。  
ユーザ設定例：

```sh
git config --global user.name "your_name"
git config --global user.email "your_email@example.com"
```

---

# 3. Git 初期化からGitHubへの初回アップロード手順

この手順は、ローカルフォルダをGitHub上のリモートリポジトリにアップロードするための一連の操作を説明します。

## 3.1. 手順

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
git remote add origin https://github.com/USERNAME/REPO_NAME.git
# または（origin が既に存在する場合）
git remote set-url origin https://github.com/USERNAME/REPO_NAME.git

# 6. ブランチ名を main に変更（GitHub のデフォルトに合わせる）
git branch -M main

# 7. リモートリポジトリへ push（初回）
git push -u origin main
```
