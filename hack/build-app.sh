#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

docker login --username=sunfmin --password=$DOCKER_HUB_PASSWORD
make push
