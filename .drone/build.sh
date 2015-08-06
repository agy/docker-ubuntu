#!/bin/bash

set -u
set -e

env | sort

DRONE_PRIVATE_REPO=${DRONE_PRIVATE_REPO:-"false"}

cd ${DRONE_BUILD_DIR}

if [ "${DRONE_PRIVATE_REPO}" == "false" ]; then
    echo "Repo is public. Drone cannot run this container in privileged mode."
    exit 1
fi

wrapdocker &
sleep 5

make container
