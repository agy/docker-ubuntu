#!/bin/bash

set -u
set -e

env | sort

DRONE_PRIVATE_REPO=${DRONE_PRIVATE_REPO:-"false"}
DRONE_PR=${DRONE_PR:-""}

cd ${DRONE_BUILD_DIR}

# Exit early with an error if this is a pull request and the repo isn't private
if [ "${DRONE_PR}" != "" ] && [ "${DRONE_PRIVATE_REPO}" == "false" ]; then
    echo "Repo is public. Drone cannot run this container in privileged mode."
    exit 1
fi

wrapdocker &
sleep 5

make container
