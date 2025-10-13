#!/bin/sh

# This script is used to remove the existing containers, volumes, and images, pull the latest images, and start the services
# This is necessary for use in preview previews where we want to ensure that the latest images are used

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  # Load environment variables from .env file
  set -a
  . ./.env
  set +a

  # Stop containers, remove volumes and remove images
  docker compose $PROFILE down --volumes --remove-orphans --rmi all

  # Try to pull the cloud controller image, create fallback if it doesn't exist
  CLOUD_CONTROLLER_IMAGE="${ECR_URL}/quadratic-cloud-controller:${IMAGE_TAG}"
  CLOUE_WORKER_IMAGE="${ECR_URL}/quadratic-cloud-worker:${IMAGE_TAG}"
  if ! docker pull "$CLOUD_CONTROLLER_IMAGE" 2>/dev/null; then
    echo "Cloud controller image not available, using hello-world as fallback"
    docker pull hello-world
    docker tag hello-world "$CLOUD_CONTROLLER_IMAGE"
  else
    docker pull "$CLOUE_WORKER_IMAGE"
  fi

  # Pull other images
  docker compose $PROFILE pull --ignore-pull-failures

  # Start services with new images in detached mode
  docker compose $PROFILE up -d

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

start
