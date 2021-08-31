#!/usr/bin/env bash

set -o errexit
set -o pipefail

CLUSTER=${1}
IMAGE_TAG=${2}
KUBECTL_BASH=${3}

# if no cluster aliases provided, display the usage and exit
if [ "$CLUSTER" == "" ]; then
  echo "Usage: CLUSTER=test or prod $0"
  exit
fi

# assuming we already have kubectl and plantbuild installed on macos
# shellcheck disable=SC1091
if [ "$(uname)" != "Darwin" ]; then
  source hack/get-tools.sh
else
  echo "looks like you are running this on your laptop, see comments to set KUBECTL_BASH for clusters behind bastion"
  # modify and uncommet the export statement to set bastion excuting
  # assuming we have access to the bastion server and it has kubectl and kubeconfig installed
  # export KUBECTL_BASH="ssh -o StrictHostKeychecking=no ubuntu@bastion.foobar.theplant.dev /bin/bash"
fi

plantbuild k8s_apply ./plantbuild/"$CLUSTER"/all.jsonnet -v "$IMAGE_TAG"

# consider to move this functionality to plantbuild
if [ -z "$KUBECTL_BASH" ]; then
  KUBECTL_BASH="/bin/bash"
fi

NAMESPACE="ip2location-$CLUSTER"
COMMAND="kubectl -n $NAMESPACE get deploy -o name |
          xargs -n1 \
            kubectl -n $NAMESPACE rollout status --timeout 150s"

echo "$COMMAND" | $KUBECTL_BASH

VALIDATE_COUNTRY_CODE=$(curl -I -s -H 'IP2Location-IP: 1.1.1.1' -i https://ip2location-"$CLUSTER".theplant-dev.com | awk 'BEGIN {FS=": "}/^ip2location-country-code/{print $2}' | tr -d '\r')

if [ "$VALIDATE_COUNTRY_CODE" == "US" ]; 
  then
    echo "'$CLUSTER' cluster deployed successfully, COUNTRY_CODE='$VALIDATE_COUNTRY_CODE'"
  else
    echo "COUNTRY_CODE='$VALIDATE_COUNTRY_CODE'"
    echo "'$CLUSTER' cluster deployed failed!!!"
    exit 1
fi
