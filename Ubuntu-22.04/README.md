# setup-wsl

## Setup
* `Ubuntu 22.04.1 LTS`のダウンロード
    * `wsl --list --online`やMicrosoft docに記載されているリンクは`Ubuntu`となっている。
    * [Microsoft Store - Generation Project (v1.2.3) \[by @rgadguard & mkuba50\]](https://store.rg-adguard.net/)
        * [Ubuntu 22.04.1 LTS - Microsoft Store アプリ](https://apps.microsoft.com/store/detail/ubuntu-22041-lts/9PN20MSR04DW)
* ダウンロードしたパッケージのインストール
    ```ps1
    > Add-AppxPackage ./CanonicalGroupLimited.Ubuntu22.04LTS_2204.1.23.0_neutral_~_79rhkp1fndgsc.appxbundle
    ```
* スタートメニューから`Ubuntu 22.04.1 LTS`を起動
* `systemd`の有効化
    ```sh
    $ sudo tee /etc/wsl.conf <<EOF
    > [user]
    > default=$USER
    > [boot]
    > systemd=true
    > [interop]
    > appendWindowsPath=false
    > EOF
    ```
* wslを再起動し、`systemd`が有効になっているか確認。
    ```sh
    $ sudo systemctl --failed
    # -> systemd-sysusers.serviceが失敗しているが後で修正するため、問題ない。
    $ history -c
    $ sudo systemctl poweroff
    ```
* エクスポート、インポートしstorage fileのパスを変更する。
    ```dos
    >wsl --export Ubuntu-22.04 Ubuntu-22.04_%date:/=%.tar
    >wsl --unregister Ubuntu-22.04
    >mkdir "%home%\wsl\storage\Ubuntu-22.04"
    >wsl --import Ubuntu-22.04 "%home%\wsl\storage\Ubuntu-22.04" Ubuntu-22.04_%date:/=%.tar
    ```
* `Ubuntu 22.04.1 LTS`を起動し、パッケージ更新を行う。
    ```sh
    $ sudo apt update
    $ sudo apt upgrade --auto-remove -y ;sudo apt autoclean
    $ sudo systemctl poweroff
    ```
* ホストから`ssh-key`をコピーする
    ```sh
    $ mkdir -p -m u=rwx,g=,o= ~/.ssh
    $ cp /mnt/c/home/.ssh/id_rsa{,.pub} ~/.ssh/
    $ chmod u=rw,g=,o= ~/.ssh/id_rsa{,.pub}
    $ # ssh-copy-id -p 2204 localhost
    ```
* `mitamae`でprovisioning
    ```sh
    $ git clone --recursive https://github.com/nakahiro386/setup-wsl.git
    $ cd setup-wsl/Ubuntu-22.04
    $ ./init.sh
    $ docker run --rm hello-world
    ```
* `dotfiles`のセットアップ
    ```sh
    $ cd ~/repo/github.com/nakahiro386/dotfiles
    $ ./init.sh --dry-run
    $ ./init.sh
    $ ./install_anyenv.sh --dry-run
    $ ./install_anyenv.sh
    $ anyenv git co master
    $ exit
    ```
* `vimfiles`のセットアップ
    ```vim
    :echo dein#insta()
    :vs $VIMFILES/vimrc_init_local.vim
    scriptencoding utf-8
    set pythonthreedll=/usr/lib/x86_64-linux-gnu/libpython3.10.so.1.0
    let g:dein#install_github_api_token = 'ghp_*******'
    ```
* `localhost`にパスワードなしでsshできるようにする。
    ```sh
    $ ssh-copy-id -p 2204 localhost
    ```
* GPG キーのインポート
    ```sh
    $ gpg --import BF0A84C125FB7548.key
    $ gpg --edit-key BF0A84C125FB7548 trust quit
    5
    $ gpg --fetch-keys https://github.com/web-flow.gpg
    $ gpg --edit-key noreply@github.com trust quit
    4
    $ gpg --lsign-key noreply@github.com
    ```
