#!/bin/sh

stop() {
  docker compose --profile "*" down
  docker system prune -af && docker builder prune -af && docker volume prune -af
}

stop