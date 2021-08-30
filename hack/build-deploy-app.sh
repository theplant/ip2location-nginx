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

export IMAGE_TAG="$(date "+%Y%m%d")"
export SHARED_TEST_CLUSTER="ssh -o StrictHostKeychecking=no ubuntu@bastion.test.shared.k8s.theplant.dev /bin/bash"
export SHARED_K8S_CLUSTER="ssh -o StrictHostKeychecking=no ubuntu@bastion.prod.aigle.k8s.theplant.dev /bin/bash"

# if PR merge to master (postsubmit job)
# then build new base image and app image
if [ "$JOB_TYPE" == "postsubmit" ]; then
  plantbuild push ./plantbuild/build-base.jsonnet -v "$IMAGE_TAG"
fi

# if periodic job
# then build app image only
plantbuild push ./plantbuild/build.jsonnet -v "$IMAGE_TAG"

./hack/deploy-to-cluster.sh test "$SHARED_TEST_CLUSTER"

# TEST_COUNTRY_CODE=$(curl -I -m 3 -s -H 'IP2Location-IP: 1.1.1.1' -i https://ip2location-test.theplant-dev.com | awk 'BEGIN {FS=": "}/^ip2location-country-code/{print $2}')
TEST_COUNTRY_CODE=$(curl -I -m 3 -s -H 'IP2Location-IP: 1.1.1.1' -i https://ip2location-test.theplant-dev.com | awk 'BEGIN {FS=": "}/^ip2location-region/{print $2}')

if [ "$TEST_COUNTRY_CODE" == "California" ]; 
  then
    echo "Test cluster deploy successfully, TEST_COUNTRY_CODE = $TEST_COUNTRY_CODE"
    ./hack/deploy-to-cluster.sh prod "$SHARED_K8S_CLUSTER"
  else
    echo "TEST_COUNTRY_CODE = $TEST_COUNTRY_CODE"
    echo "Test cluster deploy failed, will NOT continue deploy to Prod cluster!!!"
    exit 1
fi
