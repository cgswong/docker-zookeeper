#! /usr/bin/env bash

: ${ZK_DIR:-"/var/lib/zookeeper"}
ZK_CFG_FILE=${ZK_DIR}/zoo.cfg

zk_dataDir=${ZK_DIR}/data
zk_dataLogDir=${ZK_DIR}/log

: ${zk_id:-1}
: ${zk_tickTime:-2000}
: ${zk_initLimit:-5}
: ${zk_syncLimit:-2}
: ${zk_clientPort:-2181}
: ${zk_maxClientCnxns:-100}
: ${zk_autopurge.purgeInterval:-12}

export zk_id
export zk_tickTime
export zk_initLimit
export zk_syncLimit
export zk_clientPort
export zk_maxClientCnxns
export zk_autopurge.purgeInterval

# Download the config file, if given a URL
if [ ! -z "$zk_cfg_url" ]; then
  echo "$(date +"[%F %X,000]")[INFO ][action.admin.container   ] Downloading ZK config file from ${zk_cfg_url}"
  curl -sSL ${zk_cfg_url} --output ${ZK_CFG_FILE}
  if [ $? -ne 0 ]; then
    echo "$(date +"[%F %X,000]")[ERROR][action.admin.container   ] Failed to download ${zk_cfg_url}, exiting."
    exit 1
  fi
fi

# Set ZooKeeper ID
echo $zk_id > $zk_dataDir/myid

# Process env variables
for var in $(env | grep -v '^zk_cfg_' | grep '^zk_' | sort); do
  key=$(echo $var | sed -r 's/zk_(.*)=.*/\1/g')
  value=$(echo $var | sed -r 's/.*=(.*)/\1/g')
  if egrep -q "(^|^#)$key" $ZK_CFG_FILE; then
    sed -r -i "s@(^|^#)($key)=(.*)@\2=${!value}@g" $ZK_CFG_FILE
  else
  echo "${key}=${value}" >> ${ZK_CFG_FILE}
  fi
done

/opt/zookeeper/bin/zkServer.sh start-foreground
