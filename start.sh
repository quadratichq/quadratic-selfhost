#!/bin/sh

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  # Stop containers and remove volumes
  docker compose $PROFILE down --volumes --remove-orphans

  # Start services with new images in detached mode
  docker compose $PROFILE up -d

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

start
