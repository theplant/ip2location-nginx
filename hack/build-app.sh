#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

IMAGE_TAG=${1}

# shellcheck disable=SC1091
source hack/get-tools.sh

# curl -fSL -o DB11.ZIP "http://www.ip2location.com/download/?token=${DOWNLOAD_TOKEN}&file=DB11LITEBINIPV6"
curl -fSL -o DB11.ZIP "https://db11.s3.amazonaws.com/IP2LOCATION-LITE-DB11.IPV6.BIN.ZIP"
unzip DB11.ZIP -d DB11
mv DB11/IP2LOCATION-LITE-DB11.IPV6.BIN DB11.BIN
rm -rf DB11.ZIP DB11

plantbuild push ./plantbuild/build.jsonnet -v "$IMAGE_TAG"
