# Aspire Dashboard

The .NET Aspire Dashboard is a standalone web application that displays real-time logs, traces, and metrics from distributed applications via OpenTelemetry. Ideal for local development and debugging.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Files](#files)
4. [Installation](#installation)
5. [Managing the Service](#managing-the-service)
6. [Management Script Commands](#management-script-commands)
7. [Running Manually with Docker](#running-manually-with-docker)
8. [Sending Telemetry](#sending-telemetry)
9. [Health Checks](#health-checks)
10. [Troubleshooting](#troubleshooting)
11. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Container image | `mcr.microsoft.com/dotnet/aspire-dashboard:latest` |
| Container name | `aspire-dashboard` |
| Service user | `aspire-dashboard` |
| Dashboard UI | `http://localhost:18888` |
| OTLP gRPC endpoint | `http://localhost:18889` |
| OTLP HTTP endpoint | `http://localhost:18890` |
| Data path | `/opt/aspire-dashboard` |

---

## Prerequisites

- Docker installed and running on your system
- Root / sudo access (for systemd installation)

---

## Files

| File | Description |
|------|-------------|
| `aspire-dashboard.sh` | Container management script (start/stop/status/health) |
| `aspire-dashboard.service` | systemd service unit file |
| `install.sh` | One-time installation script (requires root) |
| `README.md` | This file |

---

## Installation

Run the install script once to set up the service:

```bash
cd /path/to/Data/aspire-dashboard
sudo ./install.sh
```

**What the install script does:**

1. Creates an `aspire-dashboard` system user with home directory at `/opt/aspire-dashboard`
2. Adds the `aspire-dashboard` user to the `docker` group
3. Enables user lingering (`loginctl enable-linger aspire-dashboard`)
4. Copies `aspire-dashboard.sh` to `/opt/aspire-dashboard/` with execute permissions
5. Copies `aspire-dashboard.service` to `/etc/systemd/system/`
6. Runs `systemctl daemon-reload` and enables the service to start on boot

After installation, start the service manually for the first time:

```bash
sudo systemctl start aspire-dashboard.service
```

---

## Managing the Service

```bash
# Start
sudo systemctl start aspire-dashboard.service

# Stop
sudo systemctl stop aspire-dashboard.service

# Check status
sudo systemctl status aspire-dashboard.service

# Enable auto-start on boot (done by install script)
sudo systemctl enable aspire-dashboard.service

# Disable auto-start
sudo systemctl disable aspire-dashboard.service

# View logs
sudo journalctl -xeu aspire-dashboard.service

# Follow real-time logs
sudo journalctl -fu aspire-dashboard.service
```

---

## Management Script Commands

The `aspire-dashboard.sh` script can also be called directly as the `aspire-dashboard` user:

```bash
sudo -u aspire-dashboard /opt/aspire-dashboard/aspire-dashboard.sh start
sudo -u aspire-dashboard /opt/aspire-dashboard/aspire-dashboard.sh stop
sudo -u aspire-dashboard /opt/aspire-dashboard/aspire-dashboard.sh status
sudo -u aspire-dashboard /opt/aspire-dashboard/aspire-dashboard.sh health
```

---

## Running Manually with Docker

Use these commands when running without systemd (e.g., on Windows 11 or for a quick test):

**Linux / macOS:**

```bash
docker run -d \
  --name aspire-dashboard \
  -p 18888:18888 \
  -p 18889:18889 \
  -p 18890:18890 \
  -e DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=true \
  mcr.microsoft.com/dotnet/aspire-dashboard:latest
```

**Windows 11 (PowerShell):**

```powershell
docker run -d `
  --name aspire-dashboard `
  -p 18888:18888 `
  -p 18889:18889 `
  -p 18890:18890 `
  -e DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=true `
  mcr.microsoft.com/dotnet/aspire-dashboard:latest
```

| Port | Purpose |
|------|---------|
| 18888 | Dashboard UI |
| 18889 | OTLP gRPC endpoint |
| 18890 | OTLP HTTP endpoint |

---

## Sending Telemetry

### .NET Example

```csharp
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddOpenTelemetry()
    .ConfigureResource(r => r.AddService("MyService"))
    .WithTracing(t => t
        .AddAspNetCoreInstrumentation()
        .AddOtlpExporter(o => o.Endpoint = new Uri("http://localhost:18889")));

var app = builder.Build();
app.Run();
```

### Python Example

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

provider = TracerProvider()
provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint="http://localhost:18889", insecure=True))
)
trace.set_tracer_provider(provider)
```

---

## Health Checks

```bash
# Check service status
sudo systemctl status aspire-dashboard.service

# Run the built-in health check
sudo -u aspire-dashboard /opt/aspire-dashboard/aspire-dashboard.sh health

# Test the dashboard endpoint directly
curl -I http://localhost:18888

# View container logs
docker logs aspire-dashboard
```

Expected: HTTP `200 OK` from the dashboard endpoint.

---

## Troubleshooting

**Port already in use** — map to alternate host ports:

```bash
docker run -d \
  --name aspire-dashboard \
  -p 28888:18888 \
  -p 28889:18889 \
  -p 28890:18890 \
  -e DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=true \
  mcr.microsoft.com/dotnet/aspire-dashboard:latest
```

**Connection refused:**
- Verify the container is running: `docker ps`
- Check port mappings: `docker port aspire-dashboard`
- Ensure Docker is running: `sudo systemctl status docker`

**Dashboard not showing data:**
- Confirm your app sends telemetry to `http://localhost:18889` (gRPC) or `http://localhost:18890` (HTTP)
- Review application logs for OTLP export errors

---

## Additional Resources

- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire/)
- [Aspire Dashboard GitHub](https://github.com/dotnet/aspire)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
