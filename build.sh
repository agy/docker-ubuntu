#!/bin/bash

set -u
set -e

CONTAINER=${1:?"Container name required"}
BRANCH=${2:-"master"}
REF=${3:-$(git ls-remote --heads origin 2>/dev/null | awk '$2 ~/refs\/heads\/'${BRANCH}'/ { print $1 }')}

TAG=$(git tag --points-at ${REF} 2>/dev/null | head --lines 1)
URL=$(git remote get-url origin 2>/dev/null | head --lines 1)

LAST_UPDATED=$(TZ="UTC" date --rfc-3339="seconds")
SUDO="sudo"


# Build a container based on the current remote git ref
build() {
	local tmp_dir=$(mktemp --directory)
	pushd ${tmp_dir}
	git clone ${URL} .

	${SUDO} docker build \
		--no-cache \
		--label="com.datadoghq.build-date"="${LAST_UPDATED}" \
		--label="com.datadoghq.vcs-url"="${URL}" \
		--label="com.datadoghq.vcs-ref"="${REF}" \
		--tag ${CONTAINER}:${REF} \
		.

	popd
	rm -rf ${tmp_dir} || true
}

# Tag a container based on the current tag pointing at the current git ref
tag() {
	${SUDO} docker tag ${CONTAINER}:${REF} ${CONTAINER}:${TAG} || true
}

image_has_ref() {
	${SUDO} docker images --quiet ${CONTAINER}:${REF} | \
		grep --quiet '^[a-f0-8]{12}' && \
		return 1
	return 0
}

main() {
	if [ -z "${TAG}" ]; then
		echo "No tags pointing at ref:"
		echo " * Have you pushed the branch to the remote repo?"
		echo " * Have you tagged the ref?"
		exit 0
	fi

	if [ -z "${REF}" ]; then
		echo "No remote ref ${REF} exists for branch ${BRANCH}"
		exit 1
	fi

	if image_has_ref; then
		echo "Image for ref ${REF} already exists"
		exit 0
	fi

	build
	tag
}

main
