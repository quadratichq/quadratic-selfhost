#!/bin/sh

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

# read the value of HOST from the file
HOST=$(cat HOST)

start() {
  docker compose $PROFILE down
  yes | docker compose rm quadratic-client
  docker compose $PROFILE up -d
}

start

echo "Quadratic client started on https://$HOST"