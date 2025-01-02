#!/bin/bash

# Self-Hosting Initialization
# 
# Usage:
# 
#   ./init.sh 83f0ebdf-eafb-4c8d-bd7b-04ea07d61b7f


REPO="https://github.com/quadratichq/quadratic-selfhost.git"
SELF_HOSTING_URI="https://selfhost.quadratichq.com/"
INVALID_LICENSE_KEY="Invalid license key."
PROFILE=""
LICENSE_KEY=""

get_license_key() {
    read -p "Enter your license key (Get one for free instantly at $SELF_HOSTING_URI): " user_input
    
    if [[ $user_input =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
      echo $user_input
    else
      echo $INVALID_LICENSE_KEY
      return 1
    fi
}

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

checkout() {
  git clone $REPO
  cd quadratic-selfhost
  git checkout
}

if [ -f "quadratic-selfhost/LICENSE_KEY" ]; then
  LICENSE_KEY=$(<quadratic-selfhost/LICENSE_KEY)
elif [ $1 ]; then
  LICENSE_KEY=$1
else
  LICENSE_KEY=$(get_license_key)
fi

# retrieve the code from github
checkout

# copy the local config files
cp docker/ory-auth/config/kratos.local.yml docker/ory-auth/config/kratos.yml
cp .env.local .env

# write license key to LICENSE file
touch LICENSE_KEY
echo $LICENSE_KEY > LICENSE_KEY

# write docker compose profile to PROFILE file
PROFILE=$(parse_profile)
touch PROFILE
echo $PROFILE > PROFILE

# generate a random encryption key
ENCRYPTION_KEY=$(openssl rand -base64 32)
touch ENCRYPTION_KEY
echo $ENCRYPTION_KEY > ENCRYPTION_KEY

# remove the init.sh script
rm ../init.sh

# adding .bak for compatibility with both GNU (Linux) and BSD (MacOS) sed
sed -i.bak "s/#LICENSE_KEY#/$LICENSE_KEY/g" ".env"
sed -i.bak "s/#ENCRYPTION_KEY#/$ENCRYPTION_KEY/g" ".env"

rm .env.bak

sh start.sh