#!/usr/bin/env bash

# Setup shutdown handlers
pid=0
trap 'shutdown_handler' SIGTERM SIGINT

# Setup environment and variables
ZOO_DIR="/var/lib/zookeeper"
ZOOCFGDIR="/opt/zookeeper/conf" ; export ZOOCFGDIR
ZOOCFG="${ZOOCFGDIR}/zoo.cfg" ; export ZOOCFG
JMXPORT=9001 ; export JMXPORT

zk_dataDir=${ZOO_DIR}/data
zk_dataLogDir=${ZOO_DIR}/log

: ${zk_id:=1}
: ${zk_tickTime:=5000}
: ${zk_initLimit:=5}
: ${zk_syncLimit:=2}
: ${zk_clientPort:=2181}
: ${zk_maxClientCnxns:=100}
: ${zk_autopurge_purgeInterval:=12}

export zk_dataDir
export zk_dataLogDir
export zk_id
export zk_tickTime
export zk_initLimit
export zk_syncLimit
export zk_clientPort
export zk_maxClientCnxns
export zk_autopurge_purgeInterval

# Write messages to screen
log() {
  echo "$(date +"[%F %X,000]") $(hostname) [action.admin.container] $1"
}

# Write exit failure messages to syslog and exit with failure code (i.e. non-zero)
die() {
  log "[FAIL] $1" && exit 1
}

# Download the config file, if given a URL
if [ ! -z "${zk_cfg_url}" ]; then
  log "[INFO] Downloading ZK config file from ${zk_cfg_url}"
  curl -sSL ${zk_cfg_url} --output ${ZOOCFG} ||
  [ $? -ne 0 ] && die "Failed to download ${zk_cfg_url}"
elif [ ! -f ${ZOOCFG} ]; then
  touch ${ZOOCFG}
fi

# Set ZooKeeper ID
echo ${zk_id} > ${zk_dataDir}/myid

# Process env variables
for var in $(env | grep -v '^zk_cfg_' | grep '^zk_' | sort); do
  key=$(echo ${var} | sed -r 's/zk_(.*)=.*/\1/g' | tr '_' '.')
  value=$(echo ${var} | sed -r 's/.*=(.*)/\1/g')
  if egrep -q "(^|^#)$key" ${ZOOCFG}; then
    sed -r -i "s@(^|^#)($key)=(.*)@\2=${!value}@g" ${ZOOCFG}
  else
    echo "${key}=${value}" >> ${ZOOCFG}
  fi
done

shutdown_handler() {
  # Handle Docker shutdown signals to allow correct exit codes upon container shutdown
  log "[INFO] Requesting container shutdown..."
  kill -SIGINT "${pid}"
  log "[INFO] Container stopped."
  exit 0
}

# if `docker run` first argument start with `--` the user is passing launcher arguments
if [[ "$1" == "--"* || -z $1 ]]; then
  exec /opt/zookeeper/bin/zkServer.sh start-foreground ${ZOOCFG} "$@" &
  pid=$!
  log "[INFO] Started with PID: ${pid}"
  wait ${pid}
  trap - SIGTERM SIGINT
  wait ${pid}
else
  exec "$@"
fi
