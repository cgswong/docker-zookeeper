#!/usr/bin/env bash
# Add files for each version.

set -e

# Set values
pkg=${BASH_SOURCE##*/}
travisEnv=

# set colors
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
purple=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)

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
  cp zkStart.sh "${version}/"
  sed -e 's/%%VERSION%%/'"$version"'/' < Dockerfile.tpl > "$version/Dockerfile"
  if ! grep "  - VERSION=$version" .travis.yml &>/dev/null ; then
    travisEnv='\n  - VERSION='"$version$travisEnv"
  fi
done
if [ ! -z "$travisEnv" ] ; then
  echo "${yellow}Updating Travis CI${reset}"
  travis="$(awk -v 'RS=\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
  echo "$travis" > .travis.yml
fi
echo "${green}Complete${reset}"
