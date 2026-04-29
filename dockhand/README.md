# Dockhand

Dockhand is a modern, open-source Docker management UI providing real-time container management, Compose stack orchestration, and multi-environment support in a lightweight, privacy-focused package.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Files Overview](#files-overview)
4. [Installation](#installation)
5. [Managing the Service](#managing-the-service)
6. [Management Script Commands](#management-script-commands)
7. [Accessing Dockhand](#accessing-dockhand)
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
| Web UI port | `3000` |
| Data directory | `/opt/dockhand` |

---

## Prerequisites

- Docker installed and running on your system
- Root / sudo access (for systemd installation)

---

## Files Overview

| File | Description |
|------|-------------|
| `dockhand.sh` | Container management script (start/stop/status/health) |
| `dockhand.service` | systemd service unit file |
| `install.sh` | One-time installation script (requires root) |
| `README.md` | This documentation file |

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

Once running, open your browser to:

```
http://localhost:3000
```

**First-time setup:** Authentication is disabled on first launch. Navigate to **Settings → Authentication** to enable authentication and create your first admin user.

---

## Health Checks

```bash
sudo -u dockhand /opt/dockhand/dockhand.sh health
```

The health check verifies that the container is running and the web UI is responding on port 3000.

---

## Troubleshooting

**Container fails to start — Docker socket permission denied**

The `dockhand` user must be in the `docker` group. Verify with:

```bash
groups dockhand
```

If `docker` is not listed, add it and restart:

```bash
sudo usermod -aG docker dockhand
sudo systemctl restart dockhand.service
```

**Web UI not accessible after start**

Check container logs:

```bash
docker logs dockhand
```

Verify port 3000 is not already in use:

```bash
ss -tlnp | grep 3000
```

**Relative volume paths in stacks mounted as empty directories**

Dockhand is configured with matching paths (`-v /opt/dockhand:/opt/dockhand` and `DATA_DIR=/opt/dockhand`). This ensures compose stacks with relative volume paths resolve correctly on the host. If issues persist, check the [Dockhand data storage documentation](https://dockhand.pro/manual/#data-storage).

---

## Additional Resources

- Website: https://dockhand.pro
- Manual: https://dockhand.pro/manual
- GitHub: https://github.com/Finsys/dockhand
- Docker Hub: https://hub.docker.com/r/fnsys/dockhand
