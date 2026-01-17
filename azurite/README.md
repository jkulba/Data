# Azurite Storage

Azurite is an open-source Azure Storage API compatible server (emulator) that provides a local environment for testing Azure blob, queue, and table storage applications.

## Prerequisites

- Docker CLI installed on your system (Linux or Windows 11)
- Basic knowledge of Docker commands

## Running Azurite as a Systemd Service (Linux)

For production-like usage on Linux systems, you can install Azurite as a systemd service that runs automatically on boot.

### Installation

The installation script automates the setup process:

```bash
cd /home/jim/Projects/Data/azurite
sudo ./install.sh
```

**What the install script does:**

1. **Creates a dedicated user**: Creates an `azurite` system user with home directory at `/opt/azurite`
2. **Sets up Docker permissions**: Adds the `azurite` user to the `docker` group for container management
3. **Enables user lingering**: Configures systemd to allow the user's services to run even when not logged in
4. **Copies management script**: Installs `azurite.sh` to `/opt/azurite/` with execute permissions
5. **Installs systemd service**: Copies `azurite.service` to `/etc/systemd/system/`
6. **Enables the service**: Configures Azurite to start automatically on system boot

### Managing the Service

**Start Azurite:**
```bash
sudo systemctl start azurite.service
```

**Stop Azurite:**
```bash
sudo systemctl stop azurite.service
```

**Check status:**
```bash
sudo systemctl status azurite.service
```

**Enable auto-start on boot (already done by install script):**
```bash
sudo systemctl enable azurite.service
```

**Disable auto-start:**
```bash
sudo systemctl disable azurite.service
```

**View logs:**
```bash
sudo journalctl -xeu azurite.service
```

**View real-time logs:**
```bash
sudo journalctl -fu azurite.service
```

### Management Script Commands

The `azurite.sh` script provides additional management capabilities:

**Check container health:**
```bash
sudo -u azurite /opt/azurite/azurite.sh health
```

This tests both Blob and Table Storage endpoints to ensure they're responding.

**View container status:**
```bash
sudo -u azurite /opt/azurite/azurite.sh status
```

**Manually start container:**
```bash
sudo -u azurite /opt/azurite/azurite.sh start
```

**Manually stop container:**
```bash
sudo -u azurite /opt/azurite/azurite.sh stop
```

### Data Persistence

When running as a systemd service, data is stored in:
```
/home/azurite/.local/share/azurite-data
```

This directory is automatically created and persists across container restarts.

### Service Configuration

The service is configured to:
- Start automatically after Docker is running
- Use host networking (ports 10000, 10001, 10002)
- Restart on failure
- Run as the `azurite` user for security
- Persist data in the azurite user's home directory

## Running Azurite in Docker (Manual)

For Windows 11 or manual Docker management on Linux, use these commands.

### Start Azurite Container

Run the following command to start Azurite with table storage support:

```bash
docker run -d \
  --name azurite \
  -p 10000:10000 \
  -p 10001:10001 \
  -p 10002:10002 \
  mcr.microsoft.com/azure-storage/azurite
```

**Port Mappings:**
- `10000`: Blob service
- `10001`: Queue service  
- `10002`: Table service (Azure Table Storage)

**For Windows 11 (PowerShell):**
```powershell
docker run -d `
  --name azurite `
  -p 10000:10000 `
  -p 10001:10001 `
  -p 10002:10002 `
  mcr.microsoft.com/azure-storage/azurite
```

### With Data Persistence

To persist data between container restarts:

**Linux:**
```bash
docker run -d \
  --name azurite \
  -p 10000:10000 \
  -p 10001:10001 \
  -p 10002:10002 \
  -v $HOME/azurite-data:/data \
  mcr.microsoft.com/azure-storage/azurite
```

**Windows 11 (PowerShell):**
```powershell
docker run -d `
  --name azurite `
  -p 10000:10000 `
  -p 10001:10001 `
  -p 10002:10002 `
  -v ${HOME}/azurite-data:/data `
  mcr.microsoft.com/azure-storage/azurite
```

## Testing the Connection

### Verify Container is Running

```bash
docker ps | grep azurite
```

Expected output should show the container running with all three ports mapped.

### Check Container Logs

```bash
docker logs azurite
```

You should see output indicating all services (Blob, Queue, and Table) have started successfully.

### Test Table Storage Endpoint

**Using curl:**

```bash
curl -I http://127.0.0.1:10002/devstoreaccount1?comp=properties
```

**Expected response:**
- HTTP status `200 OK` or `400` (both indicate the service is responding)
- Headers showing `Server: Azurite-Table/...`

### Test with Azure Storage Explorer

1. Download [Azure Storage Explorer](https://azure.microsoft.com/features/storage-explorer/)
2. Connect using "Local storage emulator"
3. Use the default connection string (or see below)

## Connection Details

### Default Connection String

```
DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;
```

### Endpoint URLs

- **Blob Service**: `http://127.0.0.1:10000/devstoreaccount1`
- **Queue Service**: `http://127.0.0.1:10001/devstoreaccount1`
- **Table Service**: `http://127.0.0.1:10002/devstoreaccount1`

### Account Credentials

- **Account Name**: `devstoreaccount1`
- **Account Key**: `Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==`

## Container Management

### Stop the Container

```bash
docker stop azurite
```

### Start the Container

```bash
docker start azurite
```

### Restart the Container

```bash
docker restart azurite
```

### Remove the Container

```bash
docker rm -f azurite
```

### View Real-time Logs

```bash
docker logs -f azurite
```

## Testing with Code

### Python Example

```python
from azure.data.tables import TableServiceClient

connection_string = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;"

# Create the TableServiceClient
table_service_client = TableServiceClient.from_connection_string(connection_string)

# Create a table
table_client = table_service_client.create_table("testtable")
print("Table created successfully!")
```

### .NET Example

```csharp
using Azure.Data.Tables;

string connectionString = "DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;";

var tableServiceClient = new TableServiceClient(connectionString);
await tableServiceClient.CreateTableIfNotExistsAsync("testtable");
Console.WriteLine("Table created successfully!");
```

## Troubleshooting

### Port Already in Use

If you get a port conflict error, either:
1. Stop the service using that port
2. Use different ports:

```bash
docker run -d \
  --name azurite \
  -p 10100:10000 \
  -p 10101:10001 \
  -p 10102:10002 \
  mcr.microsoft.com/azure-storage/azurite
```

Update your connection string to use `http://127.0.0.1:10102` for table storage.

### Connection Refused

- Verify the container is running: `docker ps`
- Check if ports are properly mapped: `docker port azurite`
- Verify firewall settings allow local connections

## Additional Resources

- [Azurite GitHub Repository](https://github.com/Azure/Azurite)
- [Azure Table Storage Documentation](https://docs.microsoft.com/azure/storage/tables/)
- [Azure Storage Explorer](https://azure.microsoft.com/features/storage-explorer/)
_Azure t_