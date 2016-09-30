#!/bin/bash
#
# DESCRIPTION:
#
# Builds a container based on the specified git tag. If no tag is
# passed in we assume that semver tags are used and use the most
# recent tag.
#
# USAGE:
#
# $ build.sh mycontainer 1.0.1
#

set -u
set -e

CONTAINER=${1:?"Container name required"}
GIT_TAG=${2:-"latest"}
GIT_BRANCH=${3:-"master"} # Not yet used - always assumes master

GIT_URL=$(git remote get-url origin 2>/dev/null | head --lines 1)
TMP_DIR=$(mktemp --directory)


trap clean SIGTERM SIGQUIT SIGINT

clean() {
	rm -rf ${TMP_DIR}
}


# Build a container based on the current remote git ref
build() {
	local container=${1}
	local git_url=${2}
	local git_ref=${3}
	local old_dir=${4}

	local last_updated=$(TZ="UTC" date --rfc-3339="seconds")

	git clone ${git_url} .
	[ -d "${old_dir}/artifacts" ] && \
		[ ! -e "artifacts" ] && \
		cp -rp ${old_dir}/artifacts .

	sudo docker build \
		--no-cache \
		--label="com.datadoghq.build-date"="${last_updated}" \
		--label="com.datadoghq.vcs-url"="${git_url}" \
		--label="com.datadoghq.vcs-ref"="${git_ref}" \
		--tag ${container}:${git_ref} \
		.
}

# Tag a container based on the current tag pointing at the current git ref
tag() {
	local container=${1}
	local git_ref=${2}
	local git_tag=${3}

	sudo docker tag ${container}:${git_ref} ${container}:${git_tag} || true
}

image_has_ref() {
	local container=${1}
	local git_ref=${2}

	if sudo docker images --quiet ${container}:${git_ref} | \
		grep --quiet --extended-regexp '^[0-9a-f]{12}'; then
		return 0
	fi
	return 1
}

tag_to_ref() {
	local git_tag=${1}

	echo $(git ls-remote --tags origin 2>/dev/null | \
		awk '$2 ~/refs\/tags\/'${git_tag}'/ { print $1 }')
}

tag_name() {
	local tag=${1}

	case "${tag}" in
		"latest")
			# This assumes semver (or similar)
			git_tag=$(git ls-remote --tags origin 2>/dev/null | \
				tail --lines 1 | \
				awk -F/ '{ print $3 }')
			;;
		*)
			git_tag=${tag}
			;;
	esac

	echo ${git_tag}
}

main() {
	local git_tag=$(tag_name ${GIT_TAG})
	local git_ref=$(tag_to_ref ${git_tag})

	if [ -z "${git_ref}" ]; then
		echo "No remote ref ${git_ref} exists for branch ${GIT_BRANCH}" >&2
		exit 1
	fi

	if image_has_ref ${CONTAINER} ${git_ref}; then
		echo "Image ${CONTAINER}:${git_ref} already exists"
		exit 0
	fi

	local old_dir=$(pwd)
	pushd ${TMP_DIR}
	build ${CONTAINER} ${GIT_URL} ${git_ref} ${old_dir}
	popd

	tag ${CONTAINER} ${git_ref} ${git_tag}
}

main
