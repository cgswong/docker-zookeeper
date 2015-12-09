FROM cgswong/java:openjre8
MAINTAINER Stuart Wong <cgs.wong@gmail.com>

ENV ZK_VERSION %%VERSION%%
ENV ZK_USER zookeeper
ENV ZK_GROUP zookeeper
ENV ZOO_DIR /var/lib/zookeeper
ENV ZOOBINDIR /opt/zookeeper

ADD zkStart.sh /usr/local/bin/zkStart.sh

RUN apk --update add \
      curl \
      bash \
      tar &&\
    mkdir -p \
      ${ZOOBINDIR}/conf \
      ${ZOO_DIR}/data \
      ${ZOO_DIR}/log &&\
    curl -sSL http://mirrors.sonic.net/apache/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz | tar zxf - -C ${ZOOBINDIR} --strip-components=1 &&\
    addgroup ${ZK_GROUP} &&\
    adduser -h ${ZOO_DIR} -D -s /bin/bash -G ${ZK_GROUP} ${ZK_USER} &&\
    chown -R ${ZK_USER}:${ZK_GROUP} ${ZOO_DIR} ${ZOOBINDIR} &&\
    chmod +x /usr/local/bin/zkStart.sh

USER ${ZK_USER}

# Expose client port (2188/tcp;2281/tcps), leader connection port (2888/tcp), leader election port (3888/tcp), JMX port (9000/tcp)
EXPOSE 2181 2281 2888 3888 9001

# Expose volumes
VOLUME ["${ZOO_DIR}","${ZOOBINDIR}/conf"]

ENTRYPOINT ["/usr/local/bin/zkStart.sh"]
CMD [""]
