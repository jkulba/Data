#!/bin/bash

CONTAINER_NAME="mssql-server"
IMAGE="mcr.microsoft.com/mssql/server:2022-latest"
SA_PASSWORD="P@ssword92"
PORT=1433
VOLUME_NAME="mssql-data"

start_container() {
    echo "Starting SQL Server container..."

    # Remove the container if it exists
    podman rm -f $CONTAINER_NAME 2>/dev/null || true

    
    # Create volume if it doesn't exist
    podman volume inspect $VOLUME_NAME > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "Creating volume $VOLUME_NAME..."
        podman volume create $VOLUME_NAME
    fi

    podman run -d \
        --name $CONTAINER_NAME \
        --network host \
        -e 'ACCEPT_EULA=Y' \
        -e "SA_PASSWORD=$SA_PASSWORD" \
        -v $VOLUME_NAME:/var/opt/mssql \
        $IMAGE
}

stop_container() {
    echo "Stopping SQL Server container..."
    podman stop $CONTAINER_NAME
    podman rm $CONTAINER_NAME
}

status_container() {
    podman ps -a --filter "name=$CONTAINER_NAME"
}

case "$1" in
    start)
        start_container
        ;;
    stop)
        stop_container
        ;;
    status)
        status_container
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        ;;
esac

