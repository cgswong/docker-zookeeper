## Zookeeper Docker
This is a highly configurable Dockerized [Apache Zookeeper](http://zookeeper.apache.org/) image. There is a published version on [DockerHub](https://registry.hub.docker.com/u/cgswong/zookeeper/) using the automated build process.

## How to use this image
The container can be configured via environment variables:

| Environment Variable           | Zookeeper Property        | Default |
| ------------------------------ | ------------------------- | -------:|
| ZK_ID                          | N/A                       | 1       |
| ZK_TICK_TIME                   | tickTime                  | 2000    |
| ZK_INIT_LIMIT                  | initLimit                 | 5       |
| ZK_SYNC_LIMIT                  | syncLimit                 | 2       |
| ZK_AUTOPURGE_SNAP_RETAIN_COUNT | autopurge.snapRetainCount | 3       |
| ZK_AUTOPURGE_PURGE_INTERVAL    | autopurge.purgeInterval   | 0       |

The data directory, `/var/lib/zookeeper`, is exposed for mounting to your local host. This facilitates using external storage for data (`/var/lib/zookeeper/data`), snapshots and the transaction logs (`/var/lib/zookeeper/logs`). The configuration directory, `/opt/zookeeper/conf`, is also exposed for mounting such that you can use your own configuration file (and also take advantage of variable substitution).

### Standalone mode
If you are happy with the defaults, just run the container to get Zookeeper in standalone mode:

```sh
docker run --rm --name zk --publish 2181:2181 cgswong/zookeeper:latest
```

### Cluster mode
To run a cluster just set more `ZK_SERVER_X` environment variables (replace `X` with the respective Zookeeper ID) set to the respective IP/hostname:

```sh
docker run --rm --name zk1 \
  --publish 2181:2181 --publish 2888:2888 --publish 3888:3888 \
  --env ZK_ID=1 --env ZK_SERVER_1=172.17.8.101 --env ZK_SERVER_2=172.17.8.102 --env ZK_SERVER_3=172.17.8.103 \
  cgswong/zookeeper:latest
docker run --rm --name zk2 \
  --publish 2181:2181 --publish 2888:2888 --publish 3888:3888 \
  --env ZK_ID=2 --env ZK_SERVER_1=172.17.8.101 --env ZK_SERVER_2=172.17.8.102 --env ZK_SERVER_3=172.17.8.103 \
  cgswong/zookeeper:latest
docker run --rm --name zk3 \
  --publish 2181:2181 --publish 2888:2888 --publish 3888:3888 \
  --env ZK_ID=3 --env ZK_SERVER_1=172.17.8.101 --env ZK_SERVER_2=172.17.8.102 --env ZK_SERVER_3=172.17.8.103 \
  cgswong/zookeeper:latest
```

The above commands are run across 3 separate hosts. To form a cluster on a single host change the local port mappings to avoid collisions.

# User Feedback

## Issues
If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/cgswong/docker-zooker/issues).

## Contributing
You are invited to contribute new features, fixes, or updates, large or small; I'm always thrilled to receive pull requests, and I'll do my best to process them as fast as I can.

Before you start to code, I recommend discussing your plans through a [GitHub issue](https://github.com/cgswong/docker-zookeeper/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.

