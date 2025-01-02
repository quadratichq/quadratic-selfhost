#!/bin/bash

parse_profile() {
  # automatically export all variables
  set -a
  [[ -f ".env" ]] && source .env
  # disable auto export
  set +a

  values=()
  variables=(
    "DATABASE_IN_DOCKER_COMPOSE"
    "PUBSUB_IN_DOCKER_COMPOSE"
    "CADDY_IN_DOCKER_COMPOSE"
    "ORY_IN_DOCKER_COMPOSE"
    "QUADRATIC_CLIENT_IN_DOCKER_COMPOSE"
    "QUADRATIC_API_IN_DOCKER_COMPOSE"
    "QUADRATIC_MULTIPLAYER_IN_DOCKER_COMPOSE"
    "QUADRATIC_FILES_IN_DOCKER_COMPOSE"
    "QUADRATIC_FILES_URL_INTERNAL"
    "QUADRATIC_FILES_URL_EXTERNAL"
    "QUADRATIC_CONNECTION_IN_DOCKER_COMPOSE"
  )

  for var_name in "${variables[@]}"; do
    local var_value=$(eval echo \$$var_name)

    if [ "$var_value" == "true" ]; then
      # store the lowercase variable name
      var_name_stripped=$(echo "$var_name" | sed 's/_IN_DOCKER_COMPOSE//g')
      var_name_lower=$(echo "$var_name_stripped" | awk '{print tolower($0)}')
      values+=("--profile ${var_name_lower}")
    fi
  done  

  echo "${values[@]}" 
}