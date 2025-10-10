#!/bin/sh

# This script is used to remove the existing containers, volumes, and images, pull the latest images, and start the services
# This is necessary for use in preview previews where we want to ensure that the latest images are used

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  # Stop containers, remove volumes and remove images
  docker compose $PROFILE down --volumes --remove-orphans --rmi all

  # Create fallback for cloud controller BEFORE trying to pull
  CLOUD_CONTROLLER_IMAGE="${ECR_URL}/quadratic-cloud-controller:${IMAGE_TAG}"
  echo "Checking if cloud controller image exists: $CLOUD_CONTROLLER_IMAGE"
  
  # Try to pull just the cloud controller image to test if it exists
  if ! docker pull "$CLOUD_CONTROLLER_IMAGE" 2>/dev/null; then
    echo "Cloud controller image not available in registry, using hello-world as fallback..."
    docker pull hello-world
    docker tag hello-world "$CLOUD_CONTROLLER_IMAGE"
  fi

  # Since we removed all images above, we need to pull them back
  # But skip the explicit pull and let 'docker compose up' handle it
  # The pull_policy: missing setting will prevent pulling the cloud controller if it exists locally
  echo "Starting services (will pull missing images automatically)..."
  docker compose $PROFILE up -d --pull missing

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

start
