# Qdrant

Qdrant is a high-performance vector database and similarity search engine designed for storing, searching, and managing high-dimensional vectors with an extended filtering support.

## Prerequisites

- Docker CLI installed on your system (Linux or Windows 11)
- Basic knowledge of Docker commands

## Running Qdrant as a Systemd Service (Linux)

For production-like usage on Linux systems, you can install Qdrant as a systemd service that runs automatically on boot.

### Installation

The installation script automates the setup process:

```bash
cd /home/jim/Projects/Data/qdrant
sudo ./install.sh
```

**What the install script does:**

1. **Creates a dedicated user**: Creates a `qdrant` system user with home directory at `/opt/qdrant`
2. **Sets up Docker permissions**: Adds the `qdrant` user to the `docker` group for container management
3. **Enables user lingering**: Configures systemd to allow the user's services to run even when not logged in
4. **Copies management script**: Installs `qdrant.sh` to `/opt/qdrant/` with execute permissions
5. **Installs systemd service**: Copies `qdrant.service` to `/etc/systemd/system/`
6. **Enables the service**: Configures Qdrant to start automatically on system boot

### Managing the Service

**Start Qdrant:**
```bash
sudo systemctl start qdrant.service
```

**Stop Qdrant:**
```bash
sudo systemctl stop qdrant.service
```

**Check status:**
```bash
sudo systemctl status qdrant.service
```

**Enable auto-start on boot (already done by install script):**
```bash
sudo systemctl enable qdrant.service
```

**Disable auto-start:**
```bash
sudo systemctl disable qdrant.service
```

**View logs:**
```bash
sudo journalctl -xeu qdrant.service
```

**View real-time logs:**
```bash
sudo journalctl -fu qdrant.service
```

### Management Script Commands

The `qdrant.sh` script provides additional management capabilities:

**Check container health:**
```bash
sudo -u qdrant /opt/qdrant/qdrant.sh health
```

**View container status:**
```bash
sudo -u qdrant /opt/qdrant/qdrant.sh status
```

**Manually start container:**
```bash
sudo -u qdrant /opt/qdrant/qdrant.sh start
```

**Manually stop container:**
```bash
sudo -u qdrant /opt/qdrant/qdrant.sh stop
```

### Data Persistence

When running as a systemd service, data is stored in:
```
/home/qdrant/.local/share/qdrant-data
```

This directory is automatically created and persists across container restarts.

### Service Configuration

The service is configured to:
- Start automatically after Docker is running
- Use host networking (ports 6333 REST, 6334 gRPC)
- Restart on failure
- Run as the `qdrant` user for security
- Persist data in the qdrant user's home directory

## Running Qdrant in Docker (Manual)

For Windows 11 or manual Docker management on Linux, use these commands.

### Start Qdrant Container

```bash
docker run -d \
  --name qdrant \
  -p 6333:6333 \
  -p 6334:6334 \
  qdrant/qdrant
```

**Port Mappings:**
- `6333`: REST API
- `6334`: gRPC API

**For Windows 11 (PowerShell):**
```powershell
docker run -d `
  --name qdrant `
  -p 6333:6333 `
  -p 6334:6334 `
  qdrant/qdrant
```

### With Data Persistence

To persist data between container restarts:

**Linux:**
```bash
docker run -d \
  --name qdrant \
  -p 6333:6333 \
  -p 6334:6334 \
  -v $HOME/qdrant-data:/qdrant/storage \
  qdrant/qdrant
```

**Windows 11 (PowerShell):**
```powershell
docker run -d `
  --name qdrant `
  -p 6333:6333 `
  -p 6334:6334 `
  -v ${HOME}/qdrant-data:/qdrant/storage `
  qdrant/qdrant
```

## Connection Details

### Endpoint URLs

- **REST API**: `http://127.0.0.1:6333`
- **gRPC API**: `http://127.0.0.1:6334`
- **Web UI**: `http://127.0.0.1:6333/dashboard`

## Health Checks

### Verify Container is Running

```bash
docker ps | grep qdrant
```

### Test the REST API Health Endpoint

```bash
curl http://127.0.0.1:6333/healthz
```

Expected response: JSON with `title` and `version` fields.

### Check Container Logs

```bash
docker logs qdrant
```

## Testing with Code

### Python Example

Install the client:
```bash
pip install qdrant-client
```

```python
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams

client = QdrantClient(url="http://localhost:6333")

# Create a collection
client.create_collection(
    collection_name="test_collection",
    vectors_config=VectorParams(size=4, distance=Distance.DOT),
)

print("Collection created successfully!")

# List collections
collections = client.get_collections()
print(collections)
```

### curl Example

```bash
# Check health
curl http://127.0.0.1:6333/healthz

# List collections
curl http://127.0.0.1:6333/collections

# Create a collection
curl -X PUT http://127.0.0.1:6333/collections/test_collection \
  -H "Content-Type: application/json" \
  -d '{"vectors": {"size": 4, "distance": "Dot"}}'
```

## Troubleshooting

### Port Already in Use

If you get a port conflict error, use different host ports:

```bash
docker run -d \
  --name qdrant \
  -p 6433:6333 \
  -p 6434:6334 \
  qdrant/qdrant
```

Update your client connection to use `http://127.0.0.1:6433`.

### Connection Refused

- Verify the container is running: `docker ps`
- Check if ports are properly mapped: `docker port qdrant`
- Verify Docker is running: `sudo systemctl status docker`

## Additional Resources

- [Qdrant Docker Hub](https://hub.docker.com/r/qdrant/qdrant)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [Qdrant GitHub Repository](https://github.com/qdrant/qdrant)
- [Qdrant Python Client](https://github.com/qdrant/qdrant-client)
