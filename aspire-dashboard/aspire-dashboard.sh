#!/bin/bash

CONTAINER_NAME="aspire-dashboard"
IMAGE="mcr.microsoft.com/dotnet/aspire-dashboard:latest"
PORT_1=18888
PORT_2=18889
PORT_3=18890
DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=true

start_container() {
    echo "Starting Aspire Dashboard container..."

    # Remove existing container if present
    docker rm -f $CONTAINER_NAME 2>/dev/null || true

    # Start the container
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT_1:18888 \
        -p $PORT_2:18889 \
        -p $PORT_3:18890 \
        -e DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=$DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS \
        "$IMAGE"

    echo "Aspire Dashboard container started successfully."
}

stop_container() {
    echo "Stopping Aspire Dashboard container..."
    docker stop "$CONTAINER_NAME" 2>/dev/null || echo "Container is not running."
    docker rm "$CONTAINER_NAME" 2>/dev/null || echo "Container already removed."
}

status_container() {
    docker ps -a --filter "name=$CONTAINER_NAME"
}

check_health() {
    echo "Checking Aspire Dashboard container health..."
    
    if ! docker ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is not running"
        return 1
    fi
    
    # Test main dashboard endpoint
    if ! curl -s -I "http://127.0.0.1:${PORT_1}" >/dev/null 2>&1; then
        echo "Aspire Dashboard is not responding"
        return 1
    fi
    
    echo "Aspire Dashboard is healthy and accessible at http://localhost:${PORT_1}"
    return 0
}

case "$1" in
    start) start_container ;;
    stop) stop_container ;;
    status) status_container ;;
    health) check_health ;;
    *) echo "Usage: $0 {start|stop|status|health}" ;;
esac
