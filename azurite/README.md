# Azurite

Azurite is an open-source Azure Storage API-compatible emulator that provides a local environment for testing Azure Blob, Queue, and Table Storage applications without an Azure subscription.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Files](#files)
4. [Installation](#installation)
5. [Managing the Service](#managing-the-service)
6. [Management Script Commands](#management-script-commands)
7. [Running Manually with Docker](#running-manually-with-docker)
8. [Connection Details](#connection-details)
9. [Testing with Code](#testing-with-code)
10. [Health Checks](#health-checks)
11. [Troubleshooting](#troubleshooting)
12. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Container image | `mcr.microsoft.com/azure-storage/azurite:latest` |
| Container name | `azurite` |
| Service user | `azurite` |
| Blob service | `http://127.0.0.1:10000` |
| Queue service | `http://127.0.0.1:10001` |
| Table service | `http://127.0.0.1:10002` |
| Data path | `/home/azurite/.local/share/azurite-data` |

---

## Prerequisites

- Docker installed and running on your system
- Root / sudo access (for systemd installation)

---

## Files

| File | Description |
|------|-------------|
| `azurite.sh` | Container management script (start/stop/status/health) |
| `azurite.service` | systemd service unit file |
| `install.sh` | One-time installation script (requires root) |
| `README.md` | This file |

---

## Installation

Run the install script once to set up the service:

```bash
cd /path/to/Data/azurite
sudo ./install.sh
```

**What the install script does:**

1. Creates an `azurite` system user with home directory at `/opt/azurite`
2. Adds the `azurite` user to the `docker` group
3. Enables user lingering (`loginctl enable-linger azurite`)
4. Copies `azurite.sh` to `/opt/azurite/` with execute permissions
5. Copies `azurite.service` to `/etc/systemd/system/`
6. Runs `systemctl daemon-reload` and enables the service to start on boot

After installation, start the service manually for the first time:

```bash
sudo systemctl start azurite.service
```

---

## Managing the Service

```bash
# Start
sudo systemctl start azurite.service

# Stop
sudo systemctl stop azurite.service

# Check status
sudo systemctl status azurite.service

# Enable auto-start on boot (done by install script)
sudo systemctl enable azurite.service

# Disable auto-start
sudo systemctl disable azurite.service

# View logs
sudo journalctl -xeu azurite.service

# Follow real-time logs
sudo journalctl -fu azurite.service
```

---

## Management Script Commands

The `azurite.sh` script can also be called directly as the `azurite` user:

```bash
sudo -u azurite /opt/azurite/azurite.sh start
sudo -u azurite /opt/azurite/azurite.sh stop
sudo -u azurite /opt/azurite/azurite.sh status
sudo -u azurite /opt/azurite/azurite.sh health
```

The health check tests both Blob and Table Storage endpoints to confirm they are responding.

---

## Running Manually with Docker

Use these commands when running without systemd (e.g., on Windows 11 or for a quick test):

**Linux / macOS:**

```bash
docker run -d \
  --name azurite \
  -p 10000:10000 \
  -p 10001:10001 \
  -p 10002:10002 \
  -v $HOME/azurite-data:/data \
  mcr.microsoft.com/azure-storage/azurite:latest
```

**Windows 11 (PowerShell):**

```powershell
docker run -d `
  --name azurite `
  -p 10000:10000 `
  -p 10001:10001 `
  -p 10002:10002 `
  -v ${HOME}/azurite-data:/data `
  mcr.microsoft.com/azure-storage/azurite:latest
```

| Port | Service |
|------|---------|
| 10000 | Blob storage |
| 10001 | Queue storage |
| 10002 | Table storage |

---

## Connection Details

### Default Connection String

```
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;
```

| Field | Value |
|-------|-------|
| Account Name | `devstoreaccount1` |
| Account Key | `Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==` |

---

## Testing with Code

### Python Example

```python
from azure.data.tables import TableServiceClient

connection_string = (
    "DefaultEndpointsProtocol=http;"
    "AccountName=devstoreaccount1;"
    "AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;"
    "TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"
)

client = TableServiceClient.from_connection_string(connection_string)
client.create_table("testtable")
print("Table created successfully!")
```

### .NET Example

```csharp
using Azure.Data.Tables;

var connectionString =
    "DefaultEndpointsProtocol=http;" +
    "AccountName=devstoreaccount1;" +
    "AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;" +
    "TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;";

var tableServiceClient = new TableServiceClient(connectionString);
await tableServiceClient.CreateTableIfNotExistsAsync("testtable");
Console.WriteLine("Table created successfully!");
```

---

## Health Checks

```bash
# Check service status
sudo systemctl status azurite.service

# Run the built-in health check
sudo -u azurite /opt/azurite/azurite.sh health

# Test the Table Storage endpoint directly
curl -I "http://127.0.0.1:10002/devstoreaccount1?comp=properties"

# View container logs
docker logs azurite
```

Expected: HTTP `200` or `400` from the Table Storage endpoint (both indicate the service is running).

---

## Troubleshooting

**Port already in use** — map to alternate host ports:

```bash
docker run -d \
  --name azurite \
  -p 10100:10000 \
  -p 10101:10001 \
  -p 10102:10002 \
  mcr.microsoft.com/azure-storage/azurite:latest
```

Update your connection string to use the new ports.

**Connection refused:**
- Verify the container is running: `docker ps`
- Check port mappings: `docker port azurite`
- Ensure Docker is running: `sudo systemctl status docker`

**Connecting with Azure Storage Explorer:**
1. Download [Azure Storage Explorer](https://azure.microsoft.com/features/storage-explorer/)
2. Add a new connection → **Local storage emulator**
3. Use the default connection string above

---

## Additional Resources

- [Azurite GitHub Repository](https://github.com/Azure/Azurite)
- [Azure Storage Documentation](https://docs.microsoft.com/azure/storage/)
- [Azure Storage Explorer](https://azure.microsoft.com/features/storage-explorer/)
