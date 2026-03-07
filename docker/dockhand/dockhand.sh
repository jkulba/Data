#!/bin/bash

CONTAINER_NAME="dockhand"
IMAGE="fnsys/dockhand:latest"
PORT=3000
DATA_PATH="/opt/dockhand"

start_container() {
    echo "Starting dockhand container..."

    # Remove existing container if present
    docker rm -f $CONTAINER_NAME 2>/dev/null || true

    # Create data directory if it doesn't exist
    mkdir -p "$DATA_PATH"

    # Start the container
    docker run -d \
        --name $CONTAINER_NAME \
        -p 3000:3000 \
        --network host \
        --restart=unless-stopped \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /opt/dockhand:/opt/dockhand \
        -e DATA_DIR=/opt/dockhand \
        "$IMAGE"

    echo "dockhand container started successfully."
}

stop_container() {
    echo "Stopping dockhand container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || echo "Container is not running."
    docker rm "$CONTAINER_NAME" 2>/dev/null || echo "Container already removed."
}

status_container() {
    docker ps -a --filter "name=$CONTAINER_NAME"
}

check_health() {
    echo "Checking dockhand container health..."
    
    if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is not running"
        return 1
    fi
    
    echo "dockhand is healthy"
    return 0
}

case "$1" in
    start) start_container ;;
    stop) stop_container ;;
    status) status_container ;;
    health) check_health ;;
    *) echo "Usage: $0 {start|stop|status|health}" ;;
esac
