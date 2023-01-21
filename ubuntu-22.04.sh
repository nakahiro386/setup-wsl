#!/usr/bin/env bash
set -e

cd $(dirname $0)
NODE_YAML=ubuntu-22.04.yaml
if [ -f _ubuntu-22.04.yaml ]; then
    NODE_YAML=_ubuntu-22.04.yaml
fi
sudo ./mitamae/mitamae.sh local $@ ubuntu2204.rb --node-yaml=$(pwd)/$NODE_YAML
