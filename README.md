# setup-wsl

## Usage

```sh
$ git clone https://github.com/nakahiro386/setup-wsl.git
$ cd setup-wsl
$ ./init.sh
```

ubuntuを再起動

```sh
$ cd setup-wsl
$ ./install_anyenv.sh
```

再ログイン

```sh
$ pyenv install 3.7.2
$ pyenv global 3.7.2
$ pip install --upgrade pip setuptools
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

