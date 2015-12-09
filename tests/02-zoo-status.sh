#!/usr/bin/env bash -x
# Test case for Docker build

# Set values
pkg=${0##*/}
pkg_root=$(dirname "${BASH_SOURCE}")

# Source common script
source "${pkg_root}/../common.sh"

# main function
main() {
  log "${green}Confirming ${DOCKER_IMAGE} status${reset}"
  docker run -d -P --name ${DOCKER_IMAGE} ${DOCKER_IMAGE}:${TAG} &>/dev/null
  port=$(docker inspect --format '{{(index (index .NetworkSettings.Ports "2181/tcp") 0).HostPort}}' ${DOCKER_IMAGE})
#  host=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${DOCKER_IMAGE})
  # We need the Docker hosts IP here since we can't always use SDN to access the Docker container directly
  if [ -z ${DOCKER_MACHINE_NAME} ]; then
    myhost=$(host $(hostname) | cut -d' ' -f4)
  else
    myhost=$(docker-machine ip ${DOCKER_MACHINE_NAME})
  fi
  url="http://${myhost}:${port}"
  sleep 10
  echo ruok | nc ${myhost} ${port} &>/dev/null
  if [ $? -eq 0 ]; then
    log "${green}[PASS] ${DOCKER_IMAGE} Status ${reset}"
  else
    docker rm -f ${DOCKER_IMAGE} &>/dev/null
    die "${DOCKER_IMAGE} status check"
  fi
  docker rm -f ${DOCKER_IMAGE} &>/dev/null
}

check-env
main
