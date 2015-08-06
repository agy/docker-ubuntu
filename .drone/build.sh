#!/bin/bash

set -u
set -e

env | sort

cd ${DRONE_BUILD_DIR}

wrapdocker &
sleep 5

make container
