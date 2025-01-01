#!/bin/bash

if [ $# -lt 1 ]; then
    echo "username missing"
    exit 1
fi

docker exec -it matrix-server \
    /usr/bin/create-account \
    -config /etc/dendrite/dendrite.yaml \
    -username $1 $@ 
