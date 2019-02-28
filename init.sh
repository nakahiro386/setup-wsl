#!/usr/bin/env bash
set -e

version='1.7.2'
mitamae_version="mitamae-${version}"
mitamae_path="./bin/${mitamae_version}"

if [ ! -f "${mitamae_path}" ]; then
    wget -q -O "${mitamae_path}" https://github.com/itamae-kitchen/mitamae/releases/download/v${version}/mitamae-x86_64-linux
    chmod +x "${mitamae_path}"
fi

sudo ${mitamae_path} local $@ recipe/recipe.rb
echo -e "\nコンソールを終了してscripts\\sshd_start.jsを実行する。"

