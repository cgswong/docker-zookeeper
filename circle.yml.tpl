machine:
  services:
    - docker

dependencies:
  cache_directories:
    - "~/docker"
  override:
    - docker info
    - if [ -e ~/docker/image.tar ]; then docker load --input ~/docker/image.tar; fi
    - docker build -t cgswong/zookeeper:%%VERSION%% .
    - mkdir -p ~/docker; docker save cgswong/zookeeper:%%VERSION%% > ~/docker/image.tar

test:
  override:
    - docker run -d --rm --name zk --publish 2181:2181 cgswong/zookeeper:%%VERSION%%; sleep 10

deployment:
  hub:
    branch: master
    commands:
      - docker login -e $DOCKER_EMAIL -u $DOCKER_USER -p $DOCKER_PASSWORD
      - docker push cgswong/zookeeper:%%VERSION%%
