#!/usr/bin/env bash
set -e

mitamae_version='1.11.7'
mitamae_sha256='513dc86f05ffe5d1fd85d835169aa414c8a32b9ac4190f62605839f38a0c0be5'
mitamae_bin="bin/mitamae-x86_64-linux-${mitamae_version}"

cd $(dirname $0)
if [ ! -e "${mitamae_bin}" ]; then
    wget -q -O "${mitamae_bin}" https://github.com/itamae-kitchen/mitamae/releases/download/v${mitamae_version}/mitamae-x86_64-linux
    chmod +x "${mitamae_bin}"
    echo "${mitamae_sha256} *${mitamae_bin}" > bin/mitamae.sha256
fi

if ! sha256sum --quiet --status -c bin/mitamae.sha256; then
    echo "checksum verificatoin failed!"
    exit 1
fi

${mitamae_bin} $@
