#!/bin/bash

set -e

IMAGE_REPOSITORY=victordev13
IMAGE_NAME=kube-news

echo "Building image..."
docker build -t $IMAGE_NAME -f src/Dockerfile src/

generate_next_version() {
    CURRENT_VERSION=$(docker images --format "{{.Tag}}" $IMAGE_REPOSITORY/$IMAGE_NAME | grep -E "^[0-9.]*[0-9]" | tail -n 1)
    IFS='.' read -r -a version_parts <<< "$CURRENT_VERSION"
    ((version_parts[2]++))
    echo "${version_parts[0]}.${version_parts[1]}.${version_parts[2]}"
}

NEW_VERSION=$(generate_next_version)

echo "Generating new image versions..."
docker tag $IMAGE_NAME $IMAGE_REPOSITORY/$IMAGE_NAME:latest
docker tag $IMAGE_NAME $IMAGE_REPOSITORY/$IMAGE_NAME:$NEW_VERSION

echo "Publishing new version..."
docker push $IMAGE_REPOSITORY/$IMAGE_NAME:$NEW_VERSION
docker push $IMAGE_REPOSITORY/$IMAGE_NAME:latest
