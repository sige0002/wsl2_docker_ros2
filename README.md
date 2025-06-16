# WSL2とDocker EngineでROS2環境を構築する

## 1. WSL2のインストール

- 前提：Windows 11を使用していること
- wsl2が未インストールであること

インストールされている場合は、この手順は不要
- 検索ボックスに「コントロールパネル」と入力し、表示されたアプリをクリックする
- 「プログラム」をクリックし、「プログラムと機能」内の「Windows の機能の有効化または無効化」を選択する
- 「仮想化マシン プラットフォーム」と「Linux用Windowsサブシステム」を有効にし、PCを再起動する
- コマンドプロンプトで以下を実行し、WSL2をインストールする

    ```sh
    wsl --install
    ```

- 参考：[Microsoft公式ドキュメント](https://learn.microsoft.com/ja-jp/windows/wsl/install#install-wsl-command)

### 1.1. WSL2のバージョン確認とアップグレード
- WSL2のバージョンを確認するには、以下のコマンドを実行する．（wsl内で）

    ```sh
    cat /etc/os-release
    ```
出力例  
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
いったんシステムをアップデートする．

```sh
sudo apt update
sudo apt upgrade
```
# Tips
## Gitを入れよう
調べて入れればいい！  
ユーザの設定は以下の通り  
git config --global user.name "your_name"  
git config --global user.email "your_email@example.com"

