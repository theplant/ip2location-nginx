#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1091
source hack/get-tools.sh

curl -fSL -o DB11.ZIP "http://www.ip2location.com/download/?token=${DOWNLOAD_TOKEN}&file=DB11LITEBINIPV6"
unzip DB11.ZIP -d DB11
mv DB11/IP2LOCATION-LITE-DB11.IPV6.BIN DB11.BIN
rm -rf DB11.ZIP DB11

plantbuild push ./plantbuild/build.jsonnet

./hack/deploy-to-cluster.sh test "ssh -o StrictHostKeychecking=no ubuntu@bastion.test.shared.k8s.theplant.dev /bin/bash"
# ./deploy-to-cluster.sh prod "ssh -o StrictHostKeychecking=no ubuntu@bastion.prod.aigle.k8s.theplant.dev /bin/bash"
