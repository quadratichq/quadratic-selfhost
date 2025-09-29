#!/bin/bash

# Self-Hosting Initialization
# 
# Usage:
# 
#   ./init-local.sh 83f0ebdf-eafb-4c8d-bd7b-04ea07d61b7f

REPO="https://github.com/quadratichq/quadratic-selfhost.git"
SELF_HOSTING_URI="https://selfhost.quadratichq.com/"
INVALID_LICENSE_KEY="Invalid license key."
PROFILE=""
LICENSE_KEY=""

mkdir -p quadratic-selfhost
rsync -av --exclude='.git' --exclude='quadratic-selfhost' . quadratic-selfhost/
cd quadratic-selfhost
source ./utils.sh

if [ -f "quadratic-selfhost/LICENSE_KEY" ]; then
  LICENSE_KEY=$(<quadratic-selfhost/LICENSE_KEY)
elif [ -f "LICENSE_KEY" ]; then
  LICENSE_KEY=$(<LICENSE_KEY)
elif [ $1 ]; then
  LICENSE_KEY=$1
else
  LICENSE_KEY=$(get_license_key)
fi


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
ENCRYPTION_KEY=$(generate_random_encryption_key)
touch ENCRYPTION_KEY
echo $ENCRYPTION_KEY > ENCRYPTION_KEY

# adding .bak for compatibility with both GNU (Linux) and BSD (MacOS) sed
sed -i.bak "s/#LICENSE_KEY#/$LICENSE_KEY/g" ".env"
sed -i.bak "s/#ENCRYPTION_KEY#/$ENCRYPTION_KEY/g" ".env"

rm .env.bak

chmod +x docker/postgres/scripts/init.sh

sh start.sh
