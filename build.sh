#!/bin/bash

set -u
set -e

CONTAINER=${1:?"Container name required"}
BRANCH=${2:-"master"}
GIT_REF=${3:-$(git ls-remote --heads origin 2>/dev/null | awk '$2 ~/refs\/heads\/'${BRANCH}'/ { print $1 }')}

GIT_TAG=$(git tag --points-at ${GIT_REF} 2>/dev/null | head --lines 1)
GIT_URL=$(git remote get-url origin 2>/dev/null | head --lines 1)

LAST_UPDATED=$(TZ="UTC" date --rfc-3339="seconds")
SUDO="sudo"


# Build a container based on the current remote git ref
build() {
	local tmp_dir=$(mktemp --directory)
	pushd ${tmp_dir}
	git clone ${GIT_URL} .

	${SUDO} docker build \
		--no-cache \
		--label="com.datadoghq.build-date"="${LAST_UPDATED}" \
		--label="com.datadoghq.vcs-url"="${GIT_URL}" \
		--label="com.datadoghq.vcs-ref"="${GIT_REF}" \
		--tag ${CONTAINER}:${GIT_REF} \
		.

	popd
	rm -rf ${tmp_dir} || true
}

# Tag a container based on the current tag pointing at the current git ref
tag() {
	${SUDO} docker tag ${CONTAINER}:${GIT_REF} ${CONTAINER}:${GIT_TAG} || true
}

image_has_ref() {
	if ${SUDO} docker images --quiet ${CONTAINER}:${GIT_REF} | \
		grep --quiet --extended-regexp '^[0-9a-f]{12}'; then
		return 0
	fi
	return 1
}

main() {
	if [ -z "${GIT_TAG}" ]; then
		echo "No tags pointing at ref:" >&2
		echo " * Have you pushed the branch to the remote repo?" >&2
		echo " * Have you tagged the ref?" >&2
		exit 1
	fi

	if [ -z "${GIT_REF}" ]; then
		echo "No remote ref ${GIT_REF} exists for branch ${BRANCH}" >&2
		exit 1
	fi

	if image_has_ref; then
		echo "Image for ref ${GIT_REF} already exists"
		exit 0
	fi

	build
	tag
}

main
