#!/usr/bin/env bash -x
# Test case for Docker build

# Set values
pkg=${0##*/}
pkg_root=$(dirname "${BASH_SOURCE}")

# Source common script
source "${pkg_root}/../common.sh"

# Start container and get information
setup() {
  log "${yellow}Confirming ${DOCKER_IMAGE} status${reset}"
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
}

# Cleanup after testing
cleanup() {
  log "Cleaning up..."
  docker rm -f ${DOCKER_IMAGE} &>/dev/null
}

# Test for status
test-status() {
  timer=60
  delay=5
  while [[ "$(echo ruok | nc "$myhost" ${port} 2>/dev/null)" != "imok" ]] ; do
    [[ ${timer} -le 0 ]] && log "${red}[FAIL] Timer expired before test completed.${reset}" && return 1
    log "Rechecking in ${delay}s. Timeout in ${timer}s..."
    sleep ${delay}
    timer=$(( timer-delay ))
  done
  log "${green}[PASS] Status check!${reset}"
}

# main function
main() {
  check-env
  setup
  test-status
  [ $? -eq 0 ] && cleanup
}

main
