#!/bin/bash

# Self-Hosting Initialization
# 
# Usage:
# 
#   ./init.sh 83f0ebdf-eafb-4c8d-bd7b-04ea07d61b7f localhost
# 
# 
# Flow:
# 
# First, check to see if there is a VERSION file, if so, use that version.
# If not, then check for the first command line argument, if so, use that version.
# Else, prompt the user.
# 
# First, check to see if there is a HOST file, if so, use that host.
# If not, then check for the first command line argument, if so, use that host.
# Else, prompt the user.

REPO="https://github.com/quadratichq/quadratic-selfhost.git"
SELF_HOSTING_URI="https://selfhost.quadratichq.com/"
INVALID_LICENSE_KEY="Invalid license key."
PROFILE=""
LICENSE_KEY=""
HOST=""

get_license_key() {
    read -p "Enter your license key (Get one for free instantly at $SELF_HOSTING_URI): " user_input
    
    if [[ $user_input =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$ ]]; then
      echo $user_input
    else
      echo $INVALID_LICENSE_KEY
      return 1
    fi
}

get_host() {
    read -p "What public host name or public IP address are you using for this setup (e.g. localhost, app.quadratic.com, or other): " user_input
    
    # TODO: validate host
    echo $user_input
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

if [ -f "quadratic-selfhost/HOST" ]; then
  HOST=$(<quadratic-selfhost/HOST)
elif [ $2 ]; then
  HOST=$2
else
  HOST=$(get_host)
fi

# retrieve the code from github
checkout

# Source utils.sh
source ./utils.sh

# copy the aws config files
cp docker/ory-auth/config/kratos.aws.yml docker/ory-auth/config/kratos.yml
cp .env.aws .env

# write license key to LICENSE file
touch LICENSE_KEY
echo $LICENSE_KEY > LICENSE_KEY

# write docker compose profile to PROFILE file
PROFILE=$(parse_profile)
touch PROFILE
echo $PROFILE > PROFILE

# write host to HOST file
touch HOST
echo $HOST > HOST

# generate a random encryption key
ENCRYPTION_KEY=$(openssl rand -base64 32)
touch ENCRYPTION_KEY
echo $ENCRYPTION_KEY > ENCRYPTION_KEY

# remove the init.sh script
rm ../init.sh

# adding .bak for compatibility with both GNU (Linux) and BSD (MacOS) sed
sed -i.bak "s/#LICENSE_KEY#/$LICENSE_KEY/g" ".env"
sed -i.bak "s/#HOST#/$HOST/g" ".env"
sed -i.bak "s/#HOST#/$HOST/g" "docker/ory-auth/config/kratos.yml"
sed -i.bak "s/#HOST#/$HOST/g" "docker/caddy/config/Caddyfile"
sed -i.bak "s/#ENCRYPTION_KEY#/$ENCRYPTION_KEY/g" ".env"

rm .env.bak
rm docker/ory-auth/config/kratos.yml.bak
rm docker/caddy/config/Caddyfile.bak

sh start.sh
