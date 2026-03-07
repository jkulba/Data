# Dockhand

Dockhand is a modern Docker management UI that provides a web-based interface for managing containers, images, and more. It runs as a Docker container and is accessible via a browser on port 3000.

## Prerequisites

- Docker installed and running on your system
- `sudo` / root access for the systemd service installation

## Running Dockhand as a Systemd Service (Linux)

For persistent usage on Linux systems, you can install Dockhand as a systemd service that starts automatically on boot.

### Installation

The installation script automates the setup process:

```bash
cd /home/jim/Projects/Data/docker/dockhand
sudo ./install.sh
```

**What the install script does:**

1. **Creates a dedicated user**: Creates a `dockhand` system user with home directory at `/opt/dockhand`
2. **Sets up Docker permissions**: Adds the `dockhand` user to the `docker` group for container management
3. **Enables user lingering**: Configures systemd to allow the user's services to run even when not logged in
4. **Copies management script**: Installs `dockhand.sh` to `/opt/dockhand/` with execute permissions
5. **Installs systemd service**: Copies `dockhand.service` to `/etc/systemd/system/`
6. **Enables the service**: Configures Dockhand to start automatically on system boot

### Managing the Service

**Start Dockhand:**
```bash
sudo systemctl start dockhand.service
```

**Stop Dockhand:**
```bash
sudo systemctl stop dockhand.service
```

**Check status:**
```bash
sudo systemctl status dockhand.service
```

**Enable auto-start on boot (already done by install script):**
```bash
sudo systemctl enable dockhand.service
```

**Disable auto-start:**
```bash
sudo systemctl disable dockhand.service
```

**View logs:**
```bash
sudo journalctl -xeu dockhand.service
```

**View real-time logs:**
```bash
sudo journalctl -fu dockhand.service
```

### Management Script Commands

The `dockhand.sh` script provides additional management capabilities:

**Check container health:**
```bash
sudo -u dockhand /opt/dockhand/dockhand.sh health
```

**View container status:**
```bash
sudo -u dockhand /opt/dockhand/dockhand.sh status
```

**Manually start container:**
```bash
sudo -u dockhand /opt/dockhand/dockhand.sh start
```

**Manually stop container:**
```bash
sudo -u dockhand /opt/dockhand/dockhand.sh stop
```

### Data Persistence

When running as a systemd service, data is stored in:
```
/opt/dockhand
```

This directory is automatically created and persists across container restarts.

### Service Configuration

The service is configured to:
- Start automatically after Docker is running
- Use host networking (port 3000)
- Restart on failure
- Run as the `dockhand` user for security
- Mount the Docker socket for container management
- Persist data in `/opt/dockhand`

## Accessing the UI

Once running, open a browser and navigate to:

```
http://localhost:3000
```

## Troubleshooting

### Port Already in Use

If port 3000 is already in use, stop the conflicting service or update the port mapping in `dockhand.sh`.

### Container Not Starting

- Verify Docker is running: `sudo systemctl status docker`
- Check the container logs: `docker logs dockhand`
- Ensure the `dockhand` user has Docker socket access: `groups dockhand`

### Connection Refused

- Verify the container is running: `docker ps | grep dockhand`
- Check the service status: `sudo systemctl status dockhand.service`
- Verify firewall settings allow port 3000
