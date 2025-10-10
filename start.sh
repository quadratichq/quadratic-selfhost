#!/bin/sh

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  # Stop containers and remove volumes
  docker compose $PROFILE down --volumes --remove-orphans

  # Check if cloud controller image exists locally, if not create a fallback
  CLOUD_CONTROLLER_IMAGE="${ECR_URL}/quadratic-cloud-controller:${IMAGE_TAG}"
  if ! docker image inspect "$CLOUD_CONTROLLER_IMAGE" > /dev/null 2>&1; then
    echo "Cloud controller image not available locally: $CLOUD_CONTROLLER_IMAGE"
    echo "Using hello-world as fallback..."
    docker pull hello-world
    docker tag hello-world "$CLOUD_CONTROLLER_IMAGE"
  fi

  # Start services with available images in detached mode
  docker compose $PROFILE up -d

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

start
