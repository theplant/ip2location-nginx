#!/usr/bin/env bash

set -o errexit
set -o pipefail

export CLUSTER=${1}
export KUBECTL_BASH=${2}

echo "$CLUSTER"
echo "$KUBECTL_BASH"

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

echo 1
echo "$KUBECTL_BASH"

echo 2
echo "$KUBECTL_BASH"

# allows CI presubmit jobs to test by dry-running
if [ "$JOB_TYPE" == "periodics" ]; then
  plantbuild k8s_apply ./plantbuild/"$CLUSTER"/all.jsonnet -v "$IMAGE_TAG" -d client
  plantbuild k8s_apply ./plantbuild/"$CLUSTER"/all.jsonnet -v "$IMAGE_TAG" -d server
fi

echo 3
echo "$KUBECTL_BASH"

plantbuild k8s_apply ./plantbuild/"$CLUSTER"/all.jsonnet -v "$IMAGE_TAG"

echo 4
echo "$KUBECTL_BASH"

# consider to move this functionality to plantbuild
if [ -z "$KUBECTL_BASH" ]; then
  KUBECTL_BASH="/bin/bash"
fi

echo 5
echo "$KUBECTL_BASH"

NAMESPACE="ip2location-$CLUSTER"
COMMAND="kubectl -n $NAMESPACE get deploy -o name |
          xargs -n1 \
            kubectl -n $NAMESPACE rollout status --timeout 150s"

echo 6
echo "$KUBECTL_BASH"

echo "$COMMAND" | $KUBECTL_BASH
