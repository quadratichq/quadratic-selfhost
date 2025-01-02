#!/bin/sh

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

stop() {
  # Stop containers and remove volumes
  docker compose $PROFILE down --volumes --remove-orphans

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

stop