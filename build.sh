#!/bin/bash
set -e

DOCKER_USER="jonathanortega2023"
IMAGE_DEV="flutter_dev"
IMAGE_FIRE="flutter_fire"

echo "🚀 Building $IMAGE_FIRE ..."
docker build --build-arg FLUTTERFIRE=true -t $IMAGE_FIRE:latest -f Dockerfile .
docker tag $IMAGE_FIRE:latest $DOCKER_USER/$IMAGE_FIRE:latest

echo "🚀 Building $IMAGE_DEV ..."
docker build -t $IMAGE_DEV:latest -f Dockerfile .
docker tag $IMAGE_DEV:latest $DOCKER_USER/$IMAGE_DEV:latest

echo "📦 Pushing images to Docker Hub ..."
docker push $DOCKER_USER/$IMAGE_DEV:latest &
PID_DEV=$!
docker push $DOCKER_USER/$IMAGE_FIRE:latest &
PID_FIRE=$!
wait $PID_DEV
wait $PID_FIRE

echo "✅ All images built and pushed successfully!"