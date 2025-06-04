#!/bin/sh

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

# read the value of HOST from the file
HOST=$(cat HOST)

start() {
  # Stop containers and remove volumes
  docker compose $PROFILE down --volumes --remove-orphans

  # Start services with new images in detached mode
  docker compose $PROFILE up -d

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

start
