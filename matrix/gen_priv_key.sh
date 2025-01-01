#!/bin/bash

echo "This should only be executed once"

mkdir -p ./data/config

set -ex;
docker run --rm --entrypoint="/usr/bin/generate-keys" \
  -v $(pwd)/data/config:/mnt \
    matrixdotorg/dendrite-monolith:latest \
    -private-key /mnt/matrix_key.pem \
    -tls-cert /mnt/server.crt \
    -tls-key /mnt/server.key

