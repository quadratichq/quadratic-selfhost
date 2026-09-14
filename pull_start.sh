#!/bin/sh

# This script is used to remove the existing containers, volumes, and images, pull the latest images, and start the services
# This is necessary for use in preview previews where we want to ensure that the latest images are used

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  # Load environment variables from .env file
  set -a
  . ./.env
  set +a

  # Stop containers and remove volumes (previews want a fresh DB), but KEEP
  # images: removing them (--rmi all) forced a ~6GB re-download of the whole
  # stack every deploy, which outran the CI deploy wait on preview instances
  # and left compose aborting with zero containers when one large pull
  # failed. Layers that didn't change are reused; superseded images are
  # pruned after the new stack is up.
  docker compose $PROFILE down --volumes --remove-orphans

  # Try to pull the cloud controller image, create fallback if it doesn't exist
  CLOUD_CONTROLLER_IMAGE="${ECR_URL}/quadratic-cloud-controller:${IMAGE_TAG}"
  CLOUD_WORKER_IMAGE="${ECR_URL}/quadratic-cloud-worker:${IMAGE_TAG}"
  if ! docker pull "$CLOUD_CONTROLLER_IMAGE" 2>/dev/null; then
    echo "Cloud controller image not available, using hello-world as fallback"
    docker pull hello-world
    docker tag hello-world "$CLOUD_CONTROLLER_IMAGE"
  else
    docker pull "$CLOUD_WORKER_IMAGE"
  fi

  # Try to pull the MCP server image, create fallback if it doesn't exist
  MCP_SERVER_IMAGE="${ECR_URL}/quadratic-mcp-server:${IMAGE_TAG}"
  if ! docker pull "$MCP_SERVER_IMAGE" 2>/dev/null; then
    echo "MCP server image not available, using hello-world as fallback"
    docker pull hello-world
    docker tag hello-world "$MCP_SERVER_IMAGE"
  fi

  # Try to pull the developer API image, create fallback if it doesn't exist
  DEVELOPER_API_IMAGE="${ECR_URL}/quadratic-developer-api:${IMAGE_TAG}"
  if ! docker pull "$DEVELOPER_API_IMAGE" 2>/dev/null; then
    echo "Developer API image not available, using hello-world as fallback"
    docker pull hello-world
    docker tag hello-world "$DEVELOPER_API_IMAGE"
  fi

  # Pull other images. --ignore-pull-failures tolerates optional services
  # whose images are absent in this registry; `up` re-attempts those pulls
  # below and aborts everything if a required one is really missing, so
  # fail loudly there instead of leaving CI to poll a dead stack.
  docker compose $PROFILE pull --ignore-pull-failures

  # Start services with new images in detached mode
  if ! docker compose $PROFILE up -d; then
    echo "FATAL: docker compose up failed" >&2
    exit 1
  fi

  # Now that the new containers are running, drop superseded image
  # versions and builder cache to keep preview disks bounded.
  docker image prune -af
  docker builder prune -af
}

start
