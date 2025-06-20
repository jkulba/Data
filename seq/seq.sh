#!/bin/bash

CONTAINER_NAME="seq"
IMAGE="docker.io/datalust/seq:latest"
DATA_DIR="/home/jim/.data"
POD_NAME="seqpod"
POD_PORT="5341"

function start() {
    echo "Ensuring pod $POD_NAME exists..."
    if ! podman pod exists $POD_NAME; then
        podman pod create --name $POD_NAME -p $POD_PORT:$POD_PORT
    fi

    echo "Starting $CONTAINER_NAME container..."

    # Remove the container if it exists
    podman rm -f $CONTAINER_NAME 2>/dev/null || true

    # Set the password hash
    PH=$(echo 'P@ssword92' | podman run --rm -i $IMAGE config hash)

    # Run the container in the pod
    podman run --name $CONTAINER_NAME -d \
        --pod $POD_NAME \
        --restart unless-stopped \
        -e ACCEPT_EULA=Y \
        -e SEQ_FIRSTRUN_ADMINPASSWORDHASH="$PH" \
        -v "$DATA_DIR:/var/opt/seq:Z" \
        $IMAGE

    echo "$CONTAINER_NAME started in pod $POD_NAME."
}

function stop() {
    echo "Stopping $CONTAINER_NAME container..."
    podman stop $CONTAINER_NAME 2>/dev/null || echo "$CONTAINER_NAME is not running."
    podman rm $CONTAINER_NAME 2>/dev/null || echo "$CONTAINER_NAME does not exist."
    # Optionally stop and remove the pod as well:
    # podman pod rm $POD_NAME 2>/dev/null || echo "$POD_NAME pod does not exist."
}

function status() {
    podman pod ps --filter "name=$POD_NAME"
    podman ps --filter "name=$CONTAINER_NAME"
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
