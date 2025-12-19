#!/bin/bash

CONTAINER_NAME="mssql-server"
IMAGE="mcr.microsoft.com/mssql/server:2022-latest"
SA_PASSWORD="P@ssword92"
PORT=1433
DATA_PATH="$HOME/.local/share/mssql-data"

start_container() {
    echo "Starting SQL Server container..."

    # Remove existing container if present
    podman rm -f $CONTAINER_NAME 2>/dev/null || true

    # Create data directory if it doesn't exist
    mkdir -p "$DATA_PATH"

    # Start the container
    podman run -d \
        --user root \
        --name $CONTAINER_NAME \
        --network host \
        --restart=unless-stopped \
        -e 'ACCEPT_EULA=Y' \
        -e "SA_PASSWORD=$SA_PASSWORD" \
        -v "$DATA_PATH:/var/opt/mssql:Z" \
        "$IMAGE"

    echo "SQL Server container started successfully."
}

stop_container() {
    echo "Stopping SQL Server container..."
    podman stop "$CONTAINER_NAME" 2>/dev/null || echo "Container is not running."
    podman rm "$CONTAINER_NAME" 2>/dev/null || echo "Container already removed."
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
