# setup-wsl

## Usage
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
    ```
* 全体更新
    ```sh
    $ sudo apt update
    $ sudo apt upgrade --auto-remove -y ;sudo apt autoclean
    $ sudo systemctl poweroff
    ```
* `mitamae`でprovisioning
    ```sh
    $ git clone --recursive https://github.com/nakahiro386/setup-wsl.git
    $ cd setup-wsl/Ubuntu-22.04
    $ ./init.sh --dry-run
    $ docker run --rm hello-world
    ```
* ホストから`ssh-key`をコピーする
    ```sh
    $ cp /mnt/c/home/.ssh/id_rsa{,.pub} ~/.ssh/
    $ chmod u=rw,g=,o= ~/.ssh/id_rsa{,.pub}
    $ ssh-copy-id -p 2204 localhost
    ```
