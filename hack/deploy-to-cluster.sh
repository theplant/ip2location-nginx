#!/usr/bin/env bash

set -o errexit
set -o pipefail

export CLUSTER=${1}
export IMAGE_TAG=${2}
export KUBECTL_BASH=${3}

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

IP2LOCATION_SERVICE_ENDPOINT=https://ip2location-"$CLUSTER".theplant-dev.com
echo "IP2LOCATION_SERVICE_ENDPOINT='$IP2LOCATION_SERVICE_ENDPOINT'"
echo "curl -I -s -H 'IP2Location-IP: 8.8.8.8' -i $IP2LOCATION_SERVICE_ENDPOINT"

MAX_RETRIES=3
RETRY_DELAY=3

for ((retry=1; retry<="$MAX_RETRIES"; retry++)); do
    curl -I -s -H 'IP2Location-IP: 8.8.8.8' -i "$IP2LOCATION_SERVICE_ENDPOINT"
    VALIDATE_COUNTRY_CODE=$(curl -I -s -H 'IP2Location-IP: 8.8.8.8' -i "$IP2LOCATION_SERVICE_ENDPOINT" | awk 'BEGIN {FS=": "}/^ip2location-country-code/{print $2}' | tr -d '\r')

    if [ -z "$VALIDATE_COUNTRY_CODE" ]; then
        echo "Country code is empty. Retrying in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY
    else
        echo "Country code: $VALIDATE_COUNTRY_CODE"
        break
    fi
done

if [ "$VALIDATE_COUNTRY_CODE" == "US" ];
  then
    echo "'$CLUSTER' cluster deployed successfully, COUNTRY_CODE='$VALIDATE_COUNTRY_CODE'"
  else
    echo "COUNTRY_CODE='$VALIDATE_COUNTRY_CODE'"
    echo "'$CLUSTER' cluster deployed failed!!!"
    exit 1
fi
