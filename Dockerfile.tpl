# DESC: Docker file to create Apache Zookeeper container

FROM cgswong/java:openjre8

ENV ZK_VERSION %%VERSION%%
ENV ZK_USER zookeeper
ENV ZK_GROUP zookeeper
ENV ZK_DIR /var/lib/zookeeper
ENV ZK_HOME /opt/zookeeper

ADD zkStart.sh /usr/local/bin/zkStart.sh

RUN apk --update add \
      curl \
      bash &&\
    mkdir -p \
      /opt \
      $ZK_DIR/conf \
      $ZK_DIR/data \
      $ZK_DIR/log &&\
    curl -sSL http://mirrors.sonic.net/apache/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz | tar zxf - -C /opt &&\
    ln -s /opt/zookeeper-${ZK_VERSION} $ZK_HOME &&\
    addgroup $ZK_GROUP &&\
    adduser -h $ZK_DIR -D -s /bin/bash -G $ZK_GROUP $ZK_USER &&\
    chown -R $ZK_USER:$ZK_GROUP $ZK_DIR $ZK_HOME &&\
    chmod +x /usr/local/bin/zkStart.sh

USER $ZK_USER

# Expose client port (2188/tcp), peer connection port (2888/tcp), leader election port (3888/tcp)
EXPOSE 2181 2888 3888

# Expose volumes
VOLUME ["${ZK_DIR}"]

ENTRYPOINT ["/usr/local/bin/zkStart.sh"]
CMD [""]
