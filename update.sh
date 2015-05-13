#!/usr/local/bin/bash
# ###################################################
# DESC.: Update Dockerfile for each version directory.
#        Show some information on each version.
# ###################################################
set -e

declare -A aliases
aliases=(
  [3.4.6]='latest'
)

# Script directory
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
downloadable=$(curl -sSL 'http://mirrors.sonic.net/apache/zookeeper/' | sed -rn 's!.*?>(zookeeper-)?([0-9]+\.[0-9]+\.[0-9]).*!\2!gp')
url='git://github.com/cgswong/docker-zookeeper'

for version in "${versions[@]}"; do
  recent=$(echo "$downloadable" | grep -m 1 "$version")
  sed 's/%%VERSION%%/'"$recent"'/' <Dockerfile.tpl >"$version/Dockerfile"
  cp -p zkStart.sh $version/

  commit="$(git log -1 --format='format:%H' -- "$version")"
  fullVersion="$(grep -m1 'ENV ZK_VERSION' "$version/Dockerfile" | cut -d' ' -f3)"

  versionAliases=()
  while [ "$fullVersion" != "$version" -a "${fullVersion%[-]*}" != "$fullVersion" ]; do
    versionAliases+=( $fullVersion )
    fullVersion="${fullVersion%[-]*}"
  done
  versionAliases+=( $version ${aliases[$version]} )

  for va in "${versionAliases[@]}"; do
    echo "$va: ${url}@${commit} $version"
  done
done
