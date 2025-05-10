#!/bin/bash

CONTAINER_NAME="valkey-ultra3"
IMAGE="docker.io/valkey/valkey:latest"
PORT=6379
DATA_PATH="/home/jim/.valkey-ultra3/valkey-data"
CONFIG_PATH="/home/jim/.valkey-ultra3/valkey.conf"
PASSWORD="P@ssword92"

start_container() {
    echo "Starting Valkey container..."

    podman rm -f "$CONTAINER_NAME" 2>/dev/null || true

    mkdir -p "$DATA_PATH"
    mkdir -p "$(dirname "$CONFIG_PATH")"

    # Create default config if it doesn't exist
    if [ ! -f "$CONFIG_PATH" ]; then
        cat > "$CONFIG_PATH" <<EOF
requirepass $PASSWORD
appendonly yes
EOF
    fi

#    chown -R $HOST_UID:$HOST_GID "$DATA_PATH"

    podman run -d \
        --userns=keep-id \
        --name "$CONTAINER_NAME" \
        --network host \
        --restart=unless-stopped \
        -v "$DATA_PATH:/data:Z" \
        -v "$CONFIG_PATH:/etc/valkey/valkey.conf:Z" \
        "$IMAGE" \
        valkey-server /etc/valkey/valkey.conf
}

stop_container() {
    echo "Stopping Valkey container..."
    podman stop "$CONTAINER_NAME"
    podman rm "$CONTAINER_NAME"
}

status_container() {
    podman ps -a --filter "name=$CONTAINER_NAME"
}

check_health() {
    echo "Checking Valkey container health..."

    if ! podman ps --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
        echo "Container is not running"
        return 1
    fi

    # Test PING with redis-cli
    if ! podman exec -i "$CONTAINER_NAME" valkey-cli -a "$PASSWORD" ping | grep -q "PONG"; then
        echo "Valkey is not responding"
        return 1
    fi

    echo "Valkey is healthy"
    return 0
}

case "$1" in
    start) start_container ;;
    stop) stop_container ;;
    status) status_container ;;
    health) check_health ;;
    *) echo "Usage: $0 {start|stop|status|health}" ;;
esac

