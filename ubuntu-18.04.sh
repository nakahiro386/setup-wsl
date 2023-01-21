#!/usr/bin/env bash
set -e

cd $(dirname $0)
NODE_YAML=ubuntu-18.04.yaml
if [ -f _ubuntu-18.04.yaml ]; then
    NODE_YAML=_ubuntu-18.04.yaml
fi
sudo ./mitamae/mitamae.sh local $@ ubuntu1804.rb --node-yaml=$(pwd)/$NODE_YAML
