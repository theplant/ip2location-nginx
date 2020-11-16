#!/usr/bin/env bash

set -o errexit
set -o pipefail

# if no cluster aliases provided, display the usage and exit
if [ "$ENVIRONMENT" == "" ]; then
  echo "Usage: ENVIRONMENT=<demo/prod> $0"
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
  # export KUBECTL_BASH="ssh -o StrictHostKeychecking=no ubuntu@bastion.<env>.aigle.k8s.theplant.dev /bin/bash"
fi

# allows CI presubmit jobs to test by dry-running
if [ "$JOB_TYPE" == "presubmit" ]; then
  plantbuild k8s_apply ./plantbuild/$ENVIRONMENT/all.jsonnet -d client
  plantbuild k8s_apply ./plantbuild/$ENVIRONMENT/all.jsonnet -d server
  exit
fi

plantbuild k8s_apply ./plantbuild/$ENVIRONMENT/all.jsonnet

# consider to move this functionality to plantbuild
if [ -z "$KUBECTL_BASH" ]; then
  KUBECTL_BASH="/bin/bash"
fi

NAMESPACE="ip2location"
COMMAND="kubectl -n $NAMESPACE get deploy -o name |
        xargs -n1 \
        kubectl -n $NAMESPACE rollout status --timeout 150s"

echo "$COMMAND" | $KUBECTL_BASH
