#!/bin/bash

set -u
set -e

env

cd ${DRONE_BUILD_DIR}

make tag
