#!/bin/sh

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  docker compose $PROFILE down -v --remove-orphans
  docker compose $PROFILE up -d
  docker system prune -af && docker builder prune -af && docker volume prune -af
}

start