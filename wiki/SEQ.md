# SEQ

SEQ is a centralized structured log server from Datalust. It ingests logs, traces, and events from applications and provides a powerful query interface for searching and analyzing them.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Managing the Service](#managing-the-service)
5. [Management Script Commands](#management-script-commands)
6. [Running with Docker Compose](#running-with-docker-compose)
7. [Accessing SEQ](#accessing-seq)
8. [Sending Logs to SEQ](#sending-logs-to-seq)
9. [Health Checks](#health-checks)
10. [Troubleshooting](#troubleshooting)
11. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Container image | `datalust/seq:latest` |
| Container name | `seq` |
| Service user | `jim` |
| Ingestion API port | `5341` |
| Dashboard port | `8081` → container port `80` |
| Data directory | `/home/jim/.seq` |

---

## Prerequisites

- Podman or Docker installed on your system
- Root / sudo access (for systemd installation)

---

## Installation

Copy the management script and service file, then enable the service:

```bash
sudo cp seq.sh /usr/local/bin/seq.sh
sudo chmod +x /usr/local/bin/seq.sh

sudo cp seq.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable seq.service
```

Create the data directory:

```bash
mkdir -p ~/.seq
```

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

# Enable auto-start on boot
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

The `seq.sh` script can be called directly:

```bash
# Start SEQ (creates the pod and container)
seq.sh start

# Stop SEQ
seq.sh stop

# Check container and pod status
seq.sh status
```

The script:
1. Creates a Podman pod named `seqpod` (if it does not exist) with ports `5341` and `8081` exposed
2. Generates a password hash for the admin account
3. Starts the SEQ container inside the pod with data persisted at `~/.seq`

---

## Running with Docker Compose

As an alternative to the systemd service, you can run SEQ with Docker Compose:

```bash
cd /path/to/Data/seq

# Generate the password hash and start SEQ
PH=$(echo 'Password1' | docker run --rm -i datalust/seq config hash)

docker run \
  --name seq \
  -d \
  --restart unless-stopped \
  -e ACCEPT_EULA=Y \
  -e SEQ_FIRSTRUN_ADMINPASSWORDHASH="$PH" \
  -v ./data:/data \
  -p 5341:80 \
  datalust/seq
```

Or using the provided `compose.yml`:

```bash
docker compose up -d
```

---

## Accessing SEQ

Once running, open the SEQ dashboard at:

**[http://localhost:8081](http://localhost:8081)**

Default credentials:
- **Username:** `admin`
- **Password:** `P@ssword92`

The ingestion API is available at:

**`http://localhost:5341`**

---

## Sending Logs to SEQ

### .NET with Serilog

Install the Serilog SEQ sink:

```bash
dotnet add package Serilog.Sinks.Seq
```

Configure in code:

```csharp
using Serilog;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Seq("http://localhost:5341")
    .CreateLogger();

Log.Information("Application started");
Log.Warning("This is a warning with {Value}", 42);
Log.CloseAndFlush();
```

Or via `appsettings.json`:

```json
{
  "Serilog": {
    "WriteTo": [
      {
        "Name": "Seq",
        "Args": {
          "serverUrl": "http://localhost:5341"
        }
      }
    ]
  }
}
```

### Python with structlog / requests

```python
import requests
import json
from datetime import datetime, timezone

def send_to_seq(message, level="Information", **properties):
    event = {
        "Events": [{
            "Timestamp": datetime.now(timezone.utc).isoformat(),
            "Level": level,
            "MessageTemplate": message,
            "Properties": properties
        }]
    }
    requests.post(
        "http://localhost:5341/api/events/raw",
        data=json.dumps(event),
        headers={"Content-Type": "application/vnd.serilog.clef"}
    )

send_to_seq("Hello from Python {Lang}", Lang="Python")
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
# Check the ingestion API
curl -I http://localhost:5341/api

# Check the dashboard
curl -I http://localhost:8081

# View container status (Podman)
podman ps --filter "name=seq"

# View container logs
podman logs seq
```

Expected: HTTP `2xx` response from both endpoints.

---

## Troubleshooting

### Container fails to start

- Confirm the data directory exists: `ls -la ~/.seq`
- Check Podman/Docker is running
- View logs: `podman logs seq` or `sudo journalctl -xeu seq.service`

### Dashboard not accessible

- Verify pod port mappings: `podman pod ps` and `podman port seq`
- Ensure nothing else is using port 8081: `sudo lsof -i :8081`

### Logs not appearing in SEQ

- Confirm your application is sending to `http://localhost:5341`
- Check the ingestion API with curl (see Health Checks above)
- Verify the ACCEPT_EULA environment variable is set to `Y`

---

## Additional Resources

- [Datalust SEQ Documentation](https://docs.datalust.co/docs)
- [SEQ Docker Hub](https://hub.docker.com/r/datalust/seq)
- [Serilog.Sinks.Seq](https://github.com/serilog/serilog-sinks-seq)
- [Datalust Website](https://datalust.co/)
