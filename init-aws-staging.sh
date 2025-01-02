#!/bin/bash

# Self-Hosting Initialization (for quadratic development staging)
# 
# Usage:
# 
#   ./init-aws-staging.sh 83f0ebdf-eafb-4c8d-bd7b-04ea07d61b7f localhost
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

# Download and source utils.sh
curl -sSf https://raw.githubusercontent.com/quadratichq/quadratic-selfhost/main/utils.sh -o utils.sh
source ./utils.sh

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

# copy the aws staging config files
cp docker/ory-auth/config/kratos.aws.yml docker/ory-auth/config/kratos.yml
cp .env.aws-staging .env

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
ENCRYPTION_KEY=$(generate_random_encryption_key)
touch ENCRYPTION_KEY
echo $ENCRYPTION_KEY > ENCRYPTION_KEY

# remove the utils.sh and init.sh script
rm ../utils.sh
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
