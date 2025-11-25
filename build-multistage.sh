#!/bin/bash

set -e

DOCKER_USER="jonathanortega2023"
IMAGE_NAME="flutter_dev"
DOCKERFILE="Dockerfile.multistage"

echo "Building Flutter dev images from multistage Dockerfile..."

# Build web variant (no FlutterFire)
echo ""
echo "==> Building ${IMAGE_NAME}:web"
docker build \
  --target web \
  --build-arg FLUTTERFIRE=false \
  -t ${IMAGE_NAME}:web \
  -f ${DOCKERFILE} \
  .
docker tag ${IMAGE_NAME}:web ${DOCKER_USER}/${IMAGE_NAME}:web

# Build web variant (with FlutterFire)
echo ""
echo "==> Building ${IMAGE_NAME}:web_fire"
docker build \
  --target web \
  --build-arg FLUTTERFIRE=true \
  -t ${IMAGE_NAME}:web_fire \
  -f ${DOCKERFILE} \
  .
docker tag ${IMAGE_NAME}:web_fire ${DOCKER_USER}/${IMAGE_NAME}:web_fire

# Build android variant (no FlutterFire)
echo ""
echo "==> Building ${IMAGE_NAME}:android"
docker build \
  --target android \
  --build-arg FLUTTERFIRE=false \
  -t ${IMAGE_NAME}:android \
  -f ${DOCKERFILE} \
  .
docker tag ${IMAGE_NAME}:android ${DOCKER_USER}/${IMAGE_NAME}:android

# Build android variant (with FlutterFire)
echo ""
echo "==> Building ${IMAGE_NAME}:android_fire"
docker build \
  --target android \
  --build-arg FLUTTERFIRE=true \
  -t ${IMAGE_NAME}:android_fire \
  -f ${DOCKERFILE} \
  .
docker tag ${IMAGE_NAME}:android_fire ${DOCKER_USER}/${IMAGE_NAME}:android_fire

echo ""
echo "==> All images built successfully!"
echo ""
echo "📦 Pushing images to Docker Hub ..."
docker push ${DOCKER_USER}/${IMAGE_NAME}:web
docker push ${DOCKER_USER}/${IMAGE_NAME}:web_fire
docker push ${DOCKER_USER}/${IMAGE_NAME}:android
docker push ${DOCKER_USER}/${IMAGE_NAME}:android_fire

echo ""
echo "✅ All images built and pushed successfully!"
echo ""
echo "Available images:"
echo "  - ${DOCKER_USER}/${IMAGE_NAME}:web - Web-only Flutter"
echo "  - ${DOCKER_USER}/${IMAGE_NAME}:web_fire - Web-only Flutter + FlutterFire CLI"
echo "  - ${DOCKER_USER}/${IMAGE_NAME}:android - Full Flutter with Android SDK"
echo "  - ${DOCKER_USER}/${IMAGE_NAME}:android_fire - Full Flutter with Android SDK + FlutterFire CLI"
