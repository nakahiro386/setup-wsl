#!/usr/bin/env bash
set -e

cd $(dirname $0)
sudo ./mitamae/mitamae.sh local $@ recipe/install_anyenv.rb --node-yaml=node.yaml
