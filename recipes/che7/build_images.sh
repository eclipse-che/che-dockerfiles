#!/bin/bash

set -e

REPOSITORY='eclipse-che'
IMAGE_BASENAME='che7'

while read -r line; do
  tag=$(echo $line | cut -f 1 -d ' ')
  image=$(echo $line | cut -f 2 -d ' ')
  echo "Building ${REPOSITORY}/${IMAGE_BASENAME}-${tag} based on $image ..."
  docker build -t "${REPOSITORY}/${IMAGE_BASENAME}-$tag" --build-arg FROM_IMAGE=$image .
done < base_images
