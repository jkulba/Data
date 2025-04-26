#!/bin/bash
#exec >> /home/jim/.mssql-ultra3/sql.log 2>&1
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
        --restart=unless-stopped \
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

check_health() {
    # Construct the sqlcmd command to run inside the container
    SQLCMD_COMMAND="/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P '$SA_PASSWORD' -Q 'SELECT @@version' -N -C"

    echo "Checking SQL Server container health..."
    if ! podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is not running"
        return 1
    fi
    
    if ! podman exec -it "$CONTAINER_NAME" bash -c "$SQLCMD_COMMAND" >/dev/null 2>&1; then
        echo "SQL Server is not responding"
        return 1
    fi
    
    echo "SQL Server is healthy"
    return 0
}

case "$1" in
    start) start_container ;;
    stop) stop_container ;;
    status) status_container ;;
    health) check_health ;;
    *) echo "Usage: $0 {start|stop|status|health}" ;;
esac


#podman exec -it mssql-ultra3 /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'P@ssword92' -Q "SELECT @@VERSION" -N -C



