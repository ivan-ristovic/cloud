#!/bin/bash

mkdir -p ./data/config

set -ex;

source ../root.env
source ./matrix.env
docker run --rm --entrypoint="/bin/sh" \
  -v $(pwd)/data/config:/mnt \
  matrixdotorg/dendrite-monolith:latest \
  -c "/usr/bin/generate-config \
    -dir /var/dendrite/ \
    -db postgres://$MATRIX_DB_USER:$MATRIX_DB_PASS@matrix-db/$MATRIX_DB?sslmode=disable \
    -server $DOMAIN > /mnt/dendrite.yaml"

