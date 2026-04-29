#!/bin/sh

# read the value of PROFILE from the file
PROFILE=$(cat PROFILE)

start() {
  # Load environment variables from .env file
  set -a
  . ./.env
  set +a

  # Stop containers and remove volumes
  docker compose $PROFILE down --volumes --remove-orphans

  # Check if cloud controller image exists locally, if not create a fallback
  CLOUD_CONTROLLER_IMAGE="${ECR_URL}/quadratic-cloud-controller:${IMAGE_TAG}"
  CLOUD_WORKER_IMAGE="${ECR_URL}/quadratic-cloud-worker:${IMAGE_TAG}"
  if ! docker pull "$CLOUD_CONTROLLER_IMAGE" 2>/dev/null; then
    echo "Cloud controller image not available locally, using hello-world as fallback"
    docker pull hello-world
    docker tag hello-world "$CLOUD_CONTROLLER_IMAGE"
  else
    docker pull "$CLOUD_WORKER_IMAGE"
  fi

  # Check if MCP server image exists locally, if not create a fallback
  MCP_SERVER_IMAGE="${ECR_URL}/quadratic-mcp-server:${IMAGE_TAG}"
  if ! docker pull "$MCP_SERVER_IMAGE" 2>/dev/null; then
    echo "MCP server image not available locally, using hello-world as fallback"
    docker pull hello-world
    docker tag hello-world "$MCP_SERVER_IMAGE"
  fi

  # Check if developer API image exists locally, if not create a fallback
  DEVELOPER_API_IMAGE="${ECR_URL}/quadratic-developer-api:${IMAGE_TAG}"
  if ! docker pull "$DEVELOPER_API_IMAGE" 2>/dev/null; then
    echo "Developer API image not available locally, using hello-world as fallback"
    docker pull hello-world
    docker tag hello-world "$DEVELOPER_API_IMAGE"
  fi

  # Start services with new images in detached mode
  docker compose $PROFILE up -d

  # Clear builder cache to avoid using old images and save space
  docker builder prune -af
}

start
