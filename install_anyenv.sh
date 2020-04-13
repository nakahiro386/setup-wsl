#!/usr/bin/env bash
set -e

cd $(dirname $0)
sudo ./mitamae/mitamae.sh local $@ recipe/install_anyenv_package.rb
export PYTHON_CONFIGURE_OPTS="--enable-shared"
./mitamae/mitamae.sh local $@ recipe/install_anyenv.rb
