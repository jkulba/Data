# Seq

Seq is a centralized structured log server from Datalust. It ingests logs, traces, and events from applications and provides a powerful query interface for searching and analyzing them.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Files](#files)
4. [Installation](#installation)
5. [Managing the Service](#managing-the-service)
6. [Management Script Commands](#management-script-commands)
7. [Running with Docker Compose](#running-with-docker-compose)
8. [Accessing Seq](#accessing-seq)
9. [Sending Logs to Seq](#sending-logs-to-seq)
10. [Health Checks](#health-checks)
11. [Troubleshooting](#troubleshooting)
12. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Container image | `docker.io/datalust/seq:latest` |
| Container name | `seq` |
| Service user | `seq` |
| Ingestion API port | `5341` |
| Dashboard port | `8081` → container port `80` |
| Data path | `/home/seq/.local/share/seq-data` |

---

## Prerequisites

- Docker installed and running on your system
- Root / sudo access (for systemd installation)

---

## Files

| File | Description |
|------|-------------|
| `seq.sh` | Container management script (start/stop/status/health) |
| `seq.service` | systemd service unit file |
| `install.sh` | One-time installation script (requires root) |
| `compose.yml` | Docker Compose alternative to systemd service |
| `README.md` | This file |

---

## Installation

Run the install script once to set up the service:

```bash
cd /path/to/Data/seq
sudo ./install.sh
```

**What the install script does:**

1. Creates a `seq` system user with home directory at `/opt/seq`
2. Adds the `seq` user to the `docker` group
3. Enables user lingering (`loginctl enable-linger seq`)
4. Copies `seq.sh` to `/opt/seq/` with execute permissions
5. Copies `seq.service` to `/etc/systemd/system/`
6. Runs `systemctl daemon-reload` and enables the service to start on boot

After installation, start the service manually for the first time:

```bash
sudo systemctl start seq.service
```

---

## Managing the Service

```bash
# Start
sudo systemctl start seq.service

# Stop
sudo systemctl stop seq.service

# Check status
sudo systemctl status seq.service

# Enable auto-start on boot (done by install script)
sudo systemctl enable seq.service

# Disable auto-start
sudo systemctl disable seq.service

# View logs
sudo journalctl -xeu seq.service

# Follow real-time logs
sudo journalctl -fu seq.service
```

---

## Management Script Commands

The `seq.sh` script can also be called directly as the `seq` user:

```bash
sudo -u seq /opt/seq/seq.sh start
sudo -u seq /opt/seq/seq.sh stop
sudo -u seq /opt/seq/seq.sh status
sudo -u seq /opt/seq/seq.sh health
```

---

## Running with Docker Compose

As an alternative to the systemd service:

```bash
cd /path/to/Data/seq

# Set the password hash environment variable first
export SEQ_FIRSTRUN_ADMINPASSWORDHASH=$(echo 'P@ssword92' | docker run --rm -i datalust/seq config hash)

docker compose up -d
```

---

## Accessing Seq

Once running, open the Seq dashboard at:

**[http://localhost:8081](http://localhost:8081)**

Default credentials:
- **Username:** `admin`
- **Password:** `P@ssword92`

The ingestion API is available at: `http://localhost:5341`

---

## Sending Logs to Seq

### .NET with Serilog

```bash
dotnet add package Serilog.Sinks.Seq
```

```csharp
Log.Logger = new LoggerConfiguration()
    .WriteTo.Seq("http://localhost:5341")
    .CreateLogger();
```

### curl (raw CLEF)

```bash
curl -X POST http://localhost:5341/api/events/raw \
  -H "Content-Type: application/vnd.serilog.clef" \
  -d '{"@t":"2024-01-01T00:00:00Z","@mt":"Hello from curl","@l":"Information"}'
```

---

## Health Checks

```bash
# Check service status
sudo systemctl status seq.service

# Run the built-in health check
sudo -u seq /opt/seq/seq.sh health

# Test the dashboard endpoint
curl -I http://localhost:8081

# View container logs
docker logs seq
```

---

## Troubleshooting

**Container fails to start:**
- Check Docker is running: `sudo systemctl status docker`
- View service logs: `sudo journalctl -xeu seq.service`
- View container logs: `docker logs seq`

**Dashboard not accessible:**
- Verify the container is running: `docker ps | grep seq`
- Ensure port 8081 is free: `sudo lsof -i :8081`

**Logs not appearing in Seq:**
- Confirm your application sends to `http://localhost:5341`
- Verify `ACCEPT_EULA=Y` is set in the container environment

---

## Additional Resources

- [Datalust Seq Documentation](https://docs.datalust.co/docs)
- [Seq Docker Hub](https://hub.docker.com/r/datalust/seq)
- [Serilog.Sinks.Seq](https://github.com/serilog/serilog-sinks-seq)
