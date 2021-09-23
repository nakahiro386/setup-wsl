#!/usr/bin/env bash
set -e

mitamae_version='1.12.7'
mitamae_sha256='53074fd65e3925c92a188dcd3378519850b9cd79f39cffe84da529b9e86010a6'
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
