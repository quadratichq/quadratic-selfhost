#!/bin/sh

# This script is used to remove the existing containers, volumes, and images, pull the latest images, and start the services
# This is necessary for use in preview previews where we want to ensure that the latest images are used

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  # Stop containers, remove volumes and remove images
  docker compose $PROFILE down --volumes --remove-orphans --rmi all

  # Pull latest images
  docker compose $PROFILE pull

  # Start services with new images in detached mode
  docker compose $PROFILE up -d

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

start
