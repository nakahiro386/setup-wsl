#!/usr/bin/env bash
set -e

cd $(dirname $0)
NODE_YAML=ubuntu-22.04_user.yaml
if [ -f _ubuntu-22.04_user.yaml ]; then
    NODE_YAML=_ubuntu-22.04_user.yaml
fi
./mitamae/mitamae.sh local $@ ubuntu2204user.rb --node-yaml=$(pwd)/$NODE_YAML
