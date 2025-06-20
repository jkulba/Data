# Create SEQ pod

To create a pod with the seq logging server, follow these steps:

## (1) Create a pod

Create a new pod with the seq default ports and name it `seqpod`.

```shell
podman pod create --name seqpod -p 5341:5341
```
This creates a pod named seqpod and maps port 5341 (Seq default) from the pod to your host.

## (2) Create bash script to run seq using official seq container

```shell
#!/bin/bash

CONTAINER_NAME="seq"
IMAGE="docker.io/datalust/seq:latest"
DATA_DIR="/home/jim/.data"

function start() {
    echo "Starting $CONTAINER_NAME container..."

    # Remove the container if it exists
    podman rm -f $CONTAINER_NAME 2>/dev/null || true

    # Set the password hash
    PH=$(echo 'P@ssword92' | podman run --rm -i $IMAGE config hash)

    # Run the container
    podman run --name $CONTAINER_NAME -d \
        --restart unless-stopped \
        -e ACCEPT_EULA=Y \
        -e SEQ_FIRSTRUN_ADMINPASSWORDHASH="$PH" \
        -v "$DATA_DIR:/var/opt/seq:Z" \
        -p 5341:80 \
        $IMAGE

    echo "$CONTAINER_NAME started."
}

function stop() {
    echo "Stopping $CONTAINER_NAME container..."
    podman stop $CONTAINER_NAME 2>/dev/null || echo "$CONTAINER_NAME is not running."
    podman rm $CONTAINER_NAME 2>/dev/null || echo "$CONTAINER_NAME does not exist."
}

function status() {
    podman ps --filter "name=$CONTAINER_NAME"
}

function usage() {
    echo "Usage: $0 {start|stop|status}"
    exit 1
}

# Main
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

```
