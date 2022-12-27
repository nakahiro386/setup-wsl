#!/usr/bin/env bash
set -e

cd $(dirname $0)
sudo ./mitamae/mitamae.sh local $@ recipe/recipe.rb
