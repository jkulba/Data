# Aspire Dashboard

The .NET Aspire Dashboard is a standalone application that provides a web-based UI for viewing telemetry data from your distributed applications. It displays logs, traces, and metrics in real-time, making it an excellent tool for local development and debugging.

## Prerequisites

- Docker CLI installed on your system (Linux or Windows 11)
- Basic knowledge of Docker commands

## Running Aspire Dashboard as a Systemd Service (Linux)

For production-like usage on Linux systems, you can install Aspire Dashboard as a systemd service that runs automatically on boot.

### Installation

The installation script automates the setup process:

```bash
cd /path/to/Projects/Data/aspire-dashboard
sudo ./install.sh
```

**What the install script does:**

1. **Creates a dedicated user**: Creates an `aspire` system user with home directory at `/opt/aspire-dashboard`
2. **Sets up Docker permissions**: Adds the `aspire` user to the `docker` group for container management
3. **Enables user lingering**: Configures systemd to allow the user's services to run even when not logged in
4. **Copies management script**: Installs `aspire-dashboard.sh` to `/opt/aspire-dashboard/` with execute permissions
5. **Installs systemd service**: Copies `aspire-dashboard.service` to `/etc/systemd/system/`
6. **Enables the service**: Configures Aspire Dashboard to start automatically on system boot

### Managing the Service

**Start Aspire Dashboard:**
```bash
sudo systemctl start aspire-dashboard.service
```

**Stop Aspire Dashboard:**
```bash
sudo systemctl stop aspire-dashboard.service
```

**Check status:**
```bash
sudo systemctl status aspire-dashboard.service
```

**Enable auto-start on boot (already done by install script):**
```bash
sudo systemctl enable aspire-dashboard.service
```

**Disable auto-start:**
```bash
sudo systemctl disable aspire-dashboard.service
```

**View logs:**
```bash
sudo journalctl -xeu aspire-dashboard.service
```

**View real-time logs:**
```bash
sudo journalctl -fu aspire-dashboard.service
```

### Management Script Commands

The `aspire-dashboard.sh` script provides additional management capabilities:

**Check container health:**
```bash
sudo -u aspire /opt/aspire-dashboard/aspire-dashboard.sh health
```

This tests the dashboard endpoint to ensure it's responding.

**View container status:**
```bash
sudo -u aspire /opt/aspire-dashboard/aspire-dashboard.sh status
```

**Manually start container:**
```bash
sudo -u aspire /opt/aspire-dashboard/aspire-dashboard.sh start
```

**Manually stop container:**
```bash
sudo -u aspire /opt/aspire-dashboard/aspire-dashboard.sh stop
```

### Service Configuration

The service is configured to:
- Start automatically after Docker is running
- Expose ports 18888, 18889, 18890
- Restart on failure
- Run as the `aspire` user for security
- Allow anonymous access for development purposes

## Running Aspire Dashboard in Docker (Manual)

For Windows 11 or manual Docker management on Linux, use these commands.

### Start Aspire Dashboard Container

Run the following command to start Aspire Dashboard:

```bash
docker run -d \
  --name aspire-dashboard \
  -p 18888:18888 \
  -p 18889:18889 \
  -p 18890:18890 \
  -e DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=true \
  mcr.microsoft.com/dotnet/aspire-dashboard:latest
```

**Port Mappings:**
- `18888`: Dashboard UI (main web interface)
- `18889`: OTLP gRPC endpoint (for receiving telemetry)
- `18890`: OTLP HTTP endpoint (for receiving telemetry)

**For Windows 11 (PowerShell):**
```powershell
docker run -d `
  --name aspire-dashboard `
  -p 18888:18888 `
  -p 18889:18889 `
  -p 18890:18890 `
  -e DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=true `
  mcr.microsoft.com/dotnet/aspire-dashboard:latest
```

## Accessing the Dashboard

Once the container is running, you can access the Aspire Dashboard at:

**Dashboard URL:** [http://localhost:18888](http://localhost:18888)

## Testing the Connection

### Verify Container is Running

```bash
docker ps | grep aspire-dashboard
```

Expected output should show the container running with all three ports mapped.

### Check Container Logs

```bash
docker logs aspire-dashboard
```

You should see output indicating the dashboard has started successfully.

### Test Dashboard Endpoint

**Using curl:**

```bash
curl -I http://localhost:18888
```

**Or simply open in your browser:**

```
http://localhost:18888
```

You should see the Aspire Dashboard UI displaying telemetry information.

## Endpoint Details

### Dashboard Endpoints

- **Dashboard UI**: `http://localhost:18888`
- **OTLP gRPC Endpoint**: `http://localhost:18889`
- **OTLP HTTP Endpoint**: `http://localhost:18890`

### Environment Variables

- **DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS**: `true` (allows access without authentication - suitable for local development only)

## Container Management

### Stop the Container

```bash
docker stop aspire-dashboard
```

### Start the Container

```bash
docker start aspire-dashboard
```

### Restart the Container

```bash
docker restart aspire-dashboard
```

### Remove the Container

```bash
docker rm -f aspire-dashboard
```

### View Real-time Logs

```bash
docker logs -f aspire-dashboard
```

## Sending Telemetry to the Dashboard

### .NET Example with OpenTelemetry

To send telemetry from your .NET application to the Aspire Dashboard:

```csharp
using OpenTelemetry.Resources;
using OpenTelemetry.Trace;
using OpenTelemetry.Logs;
using OpenTelemetry.Metrics;

var builder = WebApplication.CreateBuilder(args);

// Configure OpenTelemetry
builder.Services.AddOpenTelemetry()
    .ConfigureResource(resource => resource.AddService("MyService"))
    .WithTracing(tracing => tracing
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddOtlpExporter(options => 
        {
            options.Endpoint = new Uri("http://localhost:18889");
        }))
    .WithMetrics(metrics => metrics
        .AddAspNetCoreInstrumentation()
        .AddHttpClientInstrumentation()
        .AddOtlpExporter(options => 
        {
            options.Endpoint = new Uri("http://localhost:18889");
        }));

builder.Logging.AddOpenTelemetry(logging => logging
    .AddOtlpExporter(options => 
    {
        options.Endpoint = new Uri("http://localhost:18889");
    }));

var app = builder.Build();
app.Run();
```

### Python Example with OpenTelemetry

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

# Configure the OTLP exporter
otlp_exporter = OTLPSpanExporter(
    endpoint="http://localhost:18889",
    insecure=True
)

# Set up the tracer provider
trace.set_tracer_provider(TracerProvider())
tracer_provider = trace.get_tracer_provider()
tracer_provider.add_span_processor(BatchSpanProcessor(otlp_exporter))

# Create a tracer
tracer = trace.get_tracer(__name__)

# Use the tracer
with tracer.start_as_current_span("my-operation"):
    print("Sending telemetry to Aspire Dashboard")
```

## Troubleshooting

### Port Already in Use

If you get a port conflict error, either:
1. Stop the service using that port
2. Use different ports:

```bash
docker run -d \
  --name aspire-dashboard \
  -p 28888:18888 \
  -p 28889:18889 \
  -p 28890:18890 \
  -e DOTNET_DASHBOARD_UNSECURED_ALLOW_ANONYMOUS=true \
  mcr.microsoft.com/dotnet/aspire-dashboard:latest
```

Then access the dashboard at `http://localhost:28888`.

### Connection Refused

- Verify the container is running: `docker ps`
- Check if ports are properly mapped: `docker port aspire-dashboard`
- Verify firewall settings allow local connections
- Ensure Docker is running

### Dashboard Not Showing Data

- Verify your application is configured to send telemetry to the correct OTLP endpoint
- Check that the OTLP exporter is properly configured in your application
- Review application logs for any OpenTelemetry export errors

## Additional Resources

- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire/)
- [Aspire Dashboard GitHub](https://github.com/dotnet/aspire)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [OTLP Protocol Specification](https://opentelemetry.io/docs/specs/otlp/)
