#!/bin/bash

CONTAINER_NAME="seq"
IMAGE="docker.io/datalust/seq:latest"
DATA_PATH="$HOME/.local/share/seq-data"
NETWORK_NAME="seq-network"
SEQ_PORT="5341"
DASHBOARD_PORT="8081"

start_container() {
    echo "Starting Seq container..."

    # Remove existing container if present
    docker rm -f $CONTAINER_NAME 2>/dev/null || true

    # Create data directory if it doesn't exist
    mkdir -p "$DATA_PATH"

    # Ensure network exists
    if ! docker network inspect $NETWORK_NAME >/dev/null 2>&1; then
        docker network create $NETWORK_NAME
    fi

    # Compute password hash
    PH=$(echo 'P@ssword92' | docker run --rm -i "$IMAGE" config hash)

    # Start the container
    docker run -d \
        --name $CONTAINER_NAME \
        --network $NETWORK_NAME \
        -p $SEQ_PORT:5341 \
        -p $DASHBOARD_PORT:80 \
        --restart=unless-stopped \
        -e ACCEPT_EULA=Y \
        -e SEQ_FIRSTRUN_ADMINPASSWORDHASH="$PH" \
        -v "$DATA_PATH:/data" \
        --health-cmd "curl -sf http://localhost:80 || exit 1" \
        --health-interval 30s \
        --health-timeout 5s \
        --health-retries 3 \
        --health-start-period 20s \
        "$IMAGE"

    echo "Seq container started successfully."
}

stop_container() {
    echo "Stopping Seq container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || echo "Container is not running."
    docker rm "$CONTAINER_NAME" 2>/dev/null || echo "Container already removed."
}

status_container() {
    docker ps -a --filter "name=$CONTAINER_NAME"
}

check_health() {
    echo "Checking Seq container health..."

    if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is not running"
        return 1
    fi

    if ! curl -sf "http://127.0.0.1:${DASHBOARD_PORT}" >/dev/null 2>&1; then
        echo "Seq is not responding"
        return 1
    fi

    echo "Seq is healthy and accessible at http://localhost:${DASHBOARD_PORT}"
    return 0
}

case "$1" in
    start) start_container ;;
    stop) stop_container ;;
    status) status_container ;;
    health) check_health ;;
    *) echo "Usage: $0 {start|stop|status|health}" ;;
esac
