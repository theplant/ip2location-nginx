#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

export IMAGE_TAG_DATE="$(date "+%Y%m%d")"
export IMAGE_TAG_HASH="$(git rev-parse HEAD | cut -c 1-7)"
export SHARED_TEST_CLUSTER="ssh -o StrictHostKeychecking=no ubuntu@bastion.test.shared.k8s.theplant.dev /bin/bash"
export SHARED_K8S_CLUSTER="ssh -o StrictHostKeychecking=no ubuntu@bastion.prod.aigle.k8s.theplant.dev /bin/bash"

if [ "$JOB_TYPE" == "periodic" ]; 
  then
    echo "This is weekly periodic job, will build app and deploy test and prod."
    ./hack/build-app.sh "$IMAGE_TAG_DATE"
    ./hack/deploy-to-cluster.sh test "$IMAGE_TAG_DATE" "$SHARED_TEST_CLUSTER"
    ./hack/deploy-to-cluster.sh prod "$IMAGE_TAG_DATE" "$SHARED_K8S_CLUSTER"
    exit

elif [ "$JOB_TYPE" == "postsubmit" ] && [ "$PULL_BASE_REF" == "release-test" ]; 
  then
    echo "This is postsubmit job for branch release-test, will build base+app and deploy test."
    ./hack/build-base.sh
    ./hack/build-app.sh "$IMAGE_TAG_HASH"
    ./hack/deploy-to-cluster.sh test "$IMAGE_TAG_HASH" "$SHARED_TEST_CLUSTER"
    exit

elif [ "$JOB_TYPE" == "postsubmit" ] && [ "$PULL_BASE_REF" == "release-prod" ]; 
  then
    echo "This is postsubmit job for branch release-prod, will deploy prod."
    ./hack/deploy-to-cluster.sh prod "$IMAGE_TAG_HASH" "$SHARED_K8S_CLUSTER"
    exit

else
  echo "Wrong case, CI brake!!!"
  exit 1
fi
