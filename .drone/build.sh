#!/bin/bash

set -u
set -e

cd ${DRONE_BUILD_DIR}

wrapdocker &
sleep 5

make container
