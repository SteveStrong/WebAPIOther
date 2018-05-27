#!/bin/sh
echo Clean all Docker images

# Delete all containers
docker rm -f $(docker ps -a -q)
# Delete all images
docker rmi -f $(docker images -q)

#docker stack deploy --compose-file docker-compose.yml vossibility
