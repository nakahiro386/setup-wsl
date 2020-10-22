# setup-wsl

## Usage

```sh
$ git clone --recursive https://github.com/nakahiro386/setup-wsl.git
$ cd setup-wsl
$ ./init.sh
```

ubuntuを再起動

```sh
$ cd setup-wsl
$ ./install_anyenv.sh
```

再ログイン

ホストからssh-keyをコピーする

```sh
mkdir -p -m u=rwx,g=,o= ~/.ssh
cp /mnt/c/home/.ssh/id_rsa{,.pub} ~/.ssh/
chmod u=rw,g=,o= ~/.ssh/id_rsa{,.pub}
ssh-copy-id localhost
```

```sh
$ pip install --upgrade pip setuptools
$ pip install --upgrade pipenv
$ cd setup-wsl/ansible
$ pipenv sync
$ pipenv run galaxy-install
# $ pipenv run playbook-check
$ pipenv run playbook
```

## Tips

### パスワードのリセット

1. コマンドプロンプトを実行。デフォルトユーザをrootに変更する。
    ```dosbatch
    > ubuntu1804.exe config --default-user root
    ```
1. Ubuntu 18.04を実行。対象ユーザのパスワードを変更する。
    ```sh
    $ password [username]
    ```
1. コマンドプロンプトを実行。デフォルトユーザを対象ユーザに戻す。
    ```dosbatch
    > ubuntu1804.exe config --default-user [username]
    ```

### リセット

1. スタートメニューからUbuntu 18.04を右クリック
1. その他 > アプリの設定を選択
1. 終了ボタンを押す
    * sshdなどのバックグラウンドプロセスは終了しないことがあるのでプロセスを確認する
1. リセットボタンを押す


### WSL 2 への変換

* [Windows Subsystem for Linux (WSL) を Windows 10 にインストールする | Microsoft Docs](https://docs.microsoft.com/ja-jp/windows/wsl/install-win10)

1. バージョンの確認
    ```dosbatch
    >wsl -l -v
      NAME            STATE           VERSION
    * Ubuntu-18.04    Stopped         1
    ```
1. "仮想マシン プラットフォーム" オプション機能の有効化
    * 管理者権限のpowershellで以下を実行
        ```ps1
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

        展開イメージのサービスと管理ツール
        バージョン: 10.0.19041.572

        イメージのバージョン: 10.0.19041.572

        機能を有効にしています
        [==========================100.0%==========================]
        操作は正常に完了しました。
        ```
    * PCを再起動する
1. Linux カーネル更新プログラム のインストール
    * [x64 マシン用 WSL2 Linux カーネル更新プログラム パッケージ](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)をダウンロード、実行する
1. WSL 2 をデフォルトバージョンに設定
    * 管理者権限のpowershellで以下を実行
        ```ps1
        wsl --set-default-version 2
        WSL 2 との主な違いについては、https://aka.ms/wsl2 を参照してください
        ```
1. 既存のディストリビューションをWSL 2に変換する。
    ```ps1
    wsl --set-version Ubuntu-18.04 2
    変換中です。この処理には数分かかることがあります...
    WSL 2 との主な違いについては、https://aka.ms/wsl2 を参照してください
    変換が完了しました。
    ```
