#!/bin/bash

CONTAINER_NAME="seq"
IMAGE="docker.io/datalust/seq:latest"
DATA_DIR="/home/jim/.seq"
NETWORK_NAME="seq-network"
SEQ_PORT="5341"
DASHBOARD_PORT="8081"

function start() {
    echo "Ensuring network $NETWORK_NAME exists..."
    if ! docker network inspect $NETWORK_NAME >/dev/null 2>&1; then
        docker network create $NETWORK_NAME
    fi

    echo "Starting $CONTAINER_NAME container..."

    # Remove the container if it exists
    docker rm -f $CONTAINER_NAME 2>/dev/null || true

    # Set the password hash
    PH=$(echo 'P@ssword92' | docker run --rm -i $IMAGE config hash)

    # Run the container
    docker run --name $CONTAINER_NAME -d \
        --network $NETWORK_NAME \
        -p $SEQ_PORT:$SEQ_PORT \
        -p $DASHBOARD_PORT:80 \
        --restart unless-stopped \
        -e ACCEPT_EULA=Y \
        -e SEQ_FIRSTRUN_ADMINPASSWORDHASH="$PH" \
        -v "$DATA_DIR:/var/opt/seq" \
        $IMAGE

    echo "$CONTAINER_NAME started on network $NETWORK_NAME."
}

function stop() {
    echo "Stopping $CONTAINER_NAME container..."
    docker stop $CONTAINER_NAME 2>/dev/null || echo "$CONTAINER_NAME is not running."
    docker rm $CONTAINER_NAME 2>/dev/null || echo "$CONTAINER_NAME does not exist."
    # Optionally remove the network as well:
    # docker network rm $NETWORK_NAME 2>/dev/null || echo "$NETWORK_NAME network does not exist."
}

function status() {
    docker network inspect $NETWORK_NAME 2>/dev/null | grep -q "\"Name\": \"$NETWORK_NAME\"" && echo "Network: $NETWORK_NAME exists" || echo "Network: $NETWORK_NAME does not exist"
    docker ps -a --filter "name=$CONTAINER_NAME"
}

function usage() {
    echo "Usage: $0 {start|stop|status}"
    exit 1
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    *)
        usage
        ;;
esac
