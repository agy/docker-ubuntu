#!/bin/bash

set -u
set -e

env

cd /var/cache/drone/src/github.com/${owner}/${name}

wrapdocker &
sleep 5

make container
