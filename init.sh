#!/usr/bin/env bash
set -e

cd $(dirname $0)
sudo ./mitamae/mitamae.sh local $@ recipe/recipe.rb
echo -e "\nコンソールを終了してscripts\\sshd_start.jsを実行する。"
