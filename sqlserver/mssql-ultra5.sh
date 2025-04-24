#!/bin/bash
#exec >> /opt/mssql-ultra3/sql.log 2>&1
#set -e
#echo "$(date): Running $0 $1 as $(whoami)"

CONTAINER_NAME="mssql-ultra5"
IMAGE="mcr.microsoft.com/mssql/server:2022-latest"
SA_PASSWORD="P@ssword92"
PORT=1433
DATA_PATH="/home/jim/.mssql-ultra5/mssql-data"

start_container() {
    echo "Starting SQL Server container..."

    podman rm -f $CONTAINER_NAME 2>/dev/null || true

    mkdir -p "$DATA_PATH"
    chown -R $HOST_UID:$HOST_GID "$DATA_PATH"

    podman run -d \
        --user root \
        --name $CONTAINER_NAME \
        --network host \
        -e 'ACCEPT_EULA=Y' \
        -e "SA_PASSWORD=$SA_PASSWORD" \
        -v "$DATA_PATH:/var/opt/mssql:Z" \
        "$IMAGE"
}

stop_container() {
    echo "Stopping SQL Server container..."
    podman stop "$CONTAINER_NAME"
    podman rm "$CONTAINER_NAME"
}

status_container() {
    podman ps -a --filter "name=$CONTAINER_NAME"
}

case "$1" in
    start) start_container ;;
    stop) stop_container ;;
    status) status_container ;;
    *) echo "Usage: $0 {start|stop|status}" ;;
esac

