#!/bin/bash

CONTAINER_NAME="azurite"
IMAGE="mcr.microsoft.com/azure-storage/azurite:latest"
PORT_BLOB=10000
PORT_QUEUE=10001
PORT_TABLE=10002
DATA_PATH="$HOME/.local/share/azurite-data"

start_container() {
    echo "Starting Azurite container..."

    # Remove existing container if present
    docker rm -f $CONTAINER_NAME 2>/dev/null || true

    # Create data directory if it doesn't exist
    mkdir -p "$DATA_PATH"

    # Start the container
    docker run -d \
        --name $CONTAINER_NAME \
        --network host \
        --restart=unless-stopped \
        -v "$DATA_PATH:/data" \
        --health-cmd "nc -z 127.0.0.1 ${PORT_BLOB} && nc -z 127.0.0.1 ${PORT_QUEUE} && nc -z 127.0.0.1 ${PORT_TABLE} || exit 1" \
        --health-interval 30s \
        --health-timeout 5s \
        --health-retries 3 \
        --health-start-period 10s \
        "$IMAGE"

    echo "Azurite container started successfully."
}

stop_container() {
    echo "Stopping Azurite container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || echo "Container is not running."
    docker rm "$CONTAINER_NAME" 2>/dev/null || echo "Container already removed."
}

status_container() {
    docker ps -a --filter "name=$CONTAINER_NAME"
}

check_health() {
    echo "Checking Azurite container health..."
    
    if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is not running"
        return 1
    fi
    
    # Test Table Storage endpoint
    if ! curl -s -I "http://127.0.0.1:${PORT_TABLE}/devstoreaccount1?comp=properties" >/dev/null 2>&1; then
        echo "Azurite Table Storage is not responding"
        return 1
    fi
    
    # Test Blob Storage endpoint
    if ! curl -s -I "http://127.0.0.1:${PORT_BLOB}/devstoreaccount1?comp=properties" >/dev/null 2>&1; then
        echo "Azurite Blob Storage is not responding"
        return 1
    fi
    
    echo "Azurite is healthy (Blob, Queue, and Table services running)"
    return 0
}

case "$1" in
    start) start_container ;;
    stop) stop_container ;;
    status) status_container ;;
    health) check_health ;;
    *) echo "Usage: $0 {start|stop|status|health}" ;;
esac
