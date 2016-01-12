## ZooKeeper Docker
[![Circle CI](https://circleci.com/gh/cgswong/docker-zookeeper.svg?style=svg)](https://circleci.com/gh/cgswong/docker-zookeeper)
This is a highly configurable Dockerized [Apache ZooKeeper](http://zookeeper.apache.org/) image. There is a published version on [DockerHub](https://registry.hub.docker.com/u/cgswong/zookeeper/) using the automated build process.

## How to use this image
The container can be configured via environment variables where any ZK property can be set after `zk_` with underscore instead of period ('.') used. For example:

| Environment Variable           | Zookeeper Property        | Default |
| ------------------------------ | ------------------------- | -------:|
| zk_tickTime                    | tickTime                  | 5000    |
| zk_initLimit                   | initLimit                 | 5       |
| zk_syncLimit                   | syncLimit                 | 2       |
| zk_autopurge_snapRetainCount   | autopurge.snapRetainCount | 3       |
| zk_autopurge_purgeInterval     | autopurge.purgeInterval   | 12      |

A few sensible values have been set as given above.

The data directory, `/var/lib/zookeeper`, is exposed for mounting to your local host. This facilitates using external storage for data (`/var/lib/zookeeper/data`), and snapshots and the transaction logs (`/var/lib/zookeeper/logs`). The configuration directory, `/opt/zookeeper/conf`, is also exposed for mounting such that you can use your own configuration file, and also take advantage of variable substitution.

### Using your configuration file
This image also provides for a remote properties file to be used, which will also be processed for variable substitution. To download a remote properties file, set the environment variable `zk_cfg_url` to the location of the file.

### Standalone mode
If you are happy with the defaults, just run the container to get Zookeeper in standalone mode:

```sh
docker run --rm --name zk -p 2181:2181 cgswong/zookeeper:latest
```

### Cluster mode
To run a cluster just set more `zk_server_X` environment variables, where `X` is the respective ZooKeeper ID, set to the respective IP/hostname. You'll also need to publish the respective cluster ports. For example:

```sh
docker run -d --name zk1 \
  -p 2181:2181 -p 2888:2888 -p 3888:3888 \
  -e zk_id=1 -e zk_server_1=172.17.8.101 -e zk_server_2=172.17.8.102 -e zk_server_3=172.17.8.103 \
  cgswong/zookeeper:latest
docker run -d --name zk2 \
  --publish 2181:2181 --publish 2888:2888 --publish 3888:3888 \
  -e zk_id=2 -e zk_server_1=172.17.8.101 -e zk_server_2=172.17.8.102 -e zk_server_3=172.17.8.103 \
  cgswong/zookeeper:latest
docker run -d --name zk3 \
  -p 2181:2181 -p 2888:2888 -p 3888:3888 \
  -e zk_id=3 -e zk_server_1=172.17.8.101 -e zk_server_2=172.17.8.102 -e zk_server_3=172.17.8.103 \
  cgswong/zookeeper:latest
```

The above commands are run across 3 separate hosts. To form a cluster on a single host change the local port mappings to avoid collisions.

# User Feedback

## Issues
If you have any problems with or questions about this image, please contact me through a [GitHub issue](https://github.com/cgswong/docker-zooker/issues).

## Contributing
You are invited to contribute new features, fixes, or updates, large or small; I'm always thrilled to receive pull requests, and I'll do my best to process them as fast as I can.

Before you start to code, I recommend discussing your plans through a [GitHub issue](https://github.com/cgswong/docker-zookeeper/issues), especially for more ambitious contributions. This gives other contributors a chance to point you in the right direction, give you feedback on your design, and help you find out if someone else is working on the same thing.
