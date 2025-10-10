#!/bin/sh

# This script is used to remove the existing containers, volumes, and images, pull the latest images, and start the services
# This is necessary for use in preview previews where we want to ensure that the latest images are used

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  # Stop containers, remove volumes and remove images
  docker compose $PROFILE down --volumes --remove-orphans --rmi all

  # Pull latest images, but handle missing cloud controller gracefully
  echo "Pulling available images..."
  docker compose $PROFILE pull --ignore-pull-failures || {
    echo "Some images failed to pull, continuing with available images..."
  }

  # Try to pull a fallback image for cloud controller if the real one doesn't exist
  if ! docker image inspect "${ECR_URL}/quadratic-cloud-controller:${IMAGE_TAG}" > /dev/null 2>&1; then
    echo "Cloud controller image not available, pulling hello-world as fallback..."
    docker pull hello-world
    docker tag hello-world "${ECR_URL}/quadratic-cloud-controller:${IMAGE_TAG}"
  fi

  # Start services with new images in detached mode
  docker compose $PROFILE up -d

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

start
