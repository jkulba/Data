# Dockhand

Dockhand is a modern, open-source Docker management UI providing real-time container management, Compose stack orchestration, and multi-environment support in a lightweight, privacy-focused package.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Managing the Service](#managing-the-service)
5. [Management Script Commands](#management-script-commands)
6. [Accessing Dockhand](#accessing-dockhand)
7. [First-Time Setup](#first-time-setup)
8. [Health Checks](#health-checks)
9. [Troubleshooting](#troubleshooting)
10. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Container image | `fnsys/dockhand:latest` |
| Container name | `dockhand` |
| Service user | `dockhand` |
| Web UI | `http://localhost:3000` |
| Data directory | `/opt/dockhand` |

---

## Prerequisites

- Docker installed and running on your system
- Root / sudo access (for systemd installation)

---

## Installation

Run the install script once from the `dockhand/` directory:

```bash
cd /path/to/Data/dockhand
sudo ./install.sh
```

**What the install script does:**

1. Creates a `dockhand` system user with home directory at `/opt/dockhand`
2. Adds the `dockhand` user to the `docker` group
3. Enables user lingering (`loginctl enable-linger dockhand`)
4. Copies `dockhand.sh` to `/opt/dockhand/` with execute permissions
5. Copies `dockhand.service` to `/etc/systemd/system/`
6. Runs `systemctl daemon-reload` and enables the service to start on boot

After installation, start the service manually for the first time:

```bash
sudo systemctl start dockhand.service
```

---

## Managing the Service

```bash
# Start
sudo systemctl start dockhand.service

# Stop
sudo systemctl stop dockhand.service

# Check status
sudo systemctl status dockhand.service

# Enable auto-start on boot (done by install script)
sudo systemctl enable dockhand.service

# Disable auto-start
sudo systemctl disable dockhand.service

# View logs
sudo journalctl -xeu dockhand.service

# Follow logs in real time
sudo journalctl -fu dockhand.service
```

---

## Management Script Commands

The `dockhand.sh` script can also be called directly:

```bash
sudo -u dockhand /opt/dockhand/dockhand.sh start
sudo -u dockhand /opt/dockhand/dockhand.sh stop
sudo -u dockhand /opt/dockhand/dockhand.sh status
sudo -u dockhand /opt/dockhand/dockhand.sh health
```

---

## Accessing Dockhand

| Interface | URL |
|-----------|-----|
| Web UI | http://localhost:3000 |

---

## First-Time Setup

On first launch, authentication is **disabled**. Navigate to **Settings → Authentication** to enable it and create your first admin user.

Dockhand automatically configures a local Docker environment on startup. To manage additional Docker hosts, go to **Settings → Environments**.

---

## Health Checks

```bash
sudo -u dockhand /opt/dockhand/dockhand.sh health
```

The health check verifies the container is running and the web UI responds on port 3000.

---

## Troubleshooting

**Container fails to start — Docker socket permission denied**

The `dockhand` user must be in the `docker` group:

```bash
groups dockhand
sudo usermod -aG docker dockhand
sudo systemctl restart dockhand.service
```

**Web UI not accessible after start**

Check container logs and verify port 3000 is free:

```bash
docker logs dockhand
ss -tlnp | grep 3000
```

**Relative volume paths in stacks mounted as empty directories**

Dockhand is configured with matching paths (`-v /opt/dockhand:/opt/dockhand` and `DATA_DIR=/opt/dockhand`). This ensures Docker Compose can resolve relative bind-mount paths on the host filesystem. See the [Dockhand data storage docs](https://dockhand.pro/manual/#data-storage) for details.

**Locked out of the UI**

Use the emergency scripts inside the container to recover access:

```bash
# Disable authentication entirely
docker exec -it dockhand /app/scripts/disable-auth.sh

# Or create a default admin user (admin / admin123)
docker exec -it dockhand /app/scripts/create-admin.sh

# Or reset a specific user's password
docker exec -it dockhand /app/scripts/reset-password.sh username NewPassword123
```

---

## Additional Resources

- Website: https://dockhand.pro
- Manual: https://dockhand.pro/manual
- GitHub: https://github.com/Finsys/dockhand
- Docker Hub: https://hub.docker.com/r/fnsys/dockhand
