#!/usr/bin/env bash
set -e

version='1.7.2'
mitamae_version="mitamae-${version}"
mitamae_path="./bin/${mitamae_version}"

sudo ${mitamae_path} local $@ recipe/install_anyenv_package.rb
${mitamae_path} local $@ recipe/install_anyenv.rb

