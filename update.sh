#!/usr/bin/env bash
# Add files for each version.

set -e

# Set values
pkg=${BASH_SOURCE##*/}
pkg_root=$(dirname "${BASH_SOURCE}")

# Source common script
source "${pkg_root}/common.sh"

# Script directory
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

VERSIONS=${VERSIONS:-"$@"}
if [ ! -z "$VERSIONS" ]; then
  versions=( "$VERSIONS" )
else
  versions=( ?.?.? )
fi
versions=( "${versions[@]%/}" )
versions=( $(printf '%s\n' "${versions[@]}"|sort -V) )

dlVersions=$(curl -sSL 'http://mirrors.sonic.net/apache/zookeeper/' | sed -rn 's!.*?>(zookeeper-)?([0-9]+\.[0-9]+\.[0-9]).*!\2!gp' | sort -V | uniq)
for version in "${versions[@]}"; do
  echo "${yellow}Updating version: ${version}${reset}"
  cp src/usr/local/bin/zkStart.sh "${version}/"
  sed -e 's/%%VERSION%%/'"$version"'/' < Dockerfile.tpl > "$version/Dockerfile"
done
echo "${green}Complete${reset}"
