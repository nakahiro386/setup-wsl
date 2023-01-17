#!/usr/bin/env bash
set -e

mitamae_version='1.14.0'
mitamae_sha256='318968af9995c83929a5aedd3216e9c4ecb14db2e53340efaac4444ff5e18bde'
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
