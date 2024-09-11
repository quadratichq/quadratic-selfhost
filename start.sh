#!/bin/sh

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  docker compose "$PROFILE" down
  yes | docker compose rm quadratic-client
  docker compose "$PROFILE" up -d
}

start