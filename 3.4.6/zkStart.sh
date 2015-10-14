#! /usr/bin/env bash

ZK_CFG_FILE=/opt/zookeeper/conf/zoo.cfg
ZK_DATA_DIR=/var/lib/zookeeper/data
ZK_LOG_DIR=/var/lib/zookeeper/log
ZK_USER=zookeeper

# Fail hard and fast
set -eo pipefail

ZK_ID=${ZK_ID:-1}
echo "ZK_ID=$ZK_ID" && echo $ZK_ID > $ZK_DATA_DIR/myid

ZK_TICK_TIME=${ZK_TICK_TIME:-2000}
echo "tickTime=${ZK_TICK_TIME}" | tee -a $ZK_CFG_FILE

ZK_INIT_LIMIT=${ZK_INIT_LIMIT:-5}
echo "initLimit=${ZK_INIT_LIMIT}" | tee -a $ZK_CFG_FILE

ZK_SYNC_LIMIT=${ZK_SYNC_LIMIT:-2}
echo "syncLimit=${ZK_SYNC_LIMIT}" | tee -a $ZK_CFG_FILE

echo "dataDir=${ZK_DATA_DIR}" | tee -a $ZK_CFG_FILE
echo "dataLogDir=${ZK_LOG_DIR}" | tee -a $ZK_CFG_FILE
echo "clientPort=2181" | tee -a $ZK_CFG_FILE

ZK_AUTOPURGE_SNAP_RETAIN_COUNT=${ZK_AUTOPURGE_SNAP_RETAIN_COUNT:-3}
echo "autopurge.snapRetainCount=${ZK_AUTOPURGE_SNAP_RETAIN_COUNT}" | tee -a $ZK_CFG_FILE

ZK_AUTOPURGE_PURGE_INTERVAL=${ZK_AUTOPURGE_PURGE_INTERVAL:-0}
echo "autopurge.purgeInterval=${ZK_AUTOPURGE_PURGE_INTERVAL}" | tee -a $ZK_CFG_FILE

for VAR in `env`; do
  if [[ $VAR =~ ^ZK_SERVER_[0-9]+= ]]; then
    SERVER_ID=`echo "$VAR" | sed -r "s/ZK_SERVER_(.*)=.*/\1/"`
    SERVER_IP=`echo "$VAR" | sed 's/.*=//'`
    if [ "${SERVER_ID}" = "${ZK_ID}" ]; then
      echo "server.${SERVER_ID}=0.0.0.0:2888:3888" | tee -a $ZK_CFG_FILE
    else
      echo "server.${SERVER_ID}=${SERVER_IP}:2888:3888" | tee -a $ZK_CFG_FILE
    fi
  fi
done

/opt/zookeeper/bin/zkServer.sh start-foreground
