#!/usr/bin/env bash
set -e

cd $(dirname $0)
sudo ./mitamae/mitamae.sh local $@ init.rb
