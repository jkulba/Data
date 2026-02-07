# Copilot Instructions for Data Tools

This repository contains management scripts and utilities for running development infrastructure services in Docker containers on Linux systems using systemd.

## Project Architecture

### Service Structure Pattern

Each service directory follows a consistent pattern:

```
service-name/
├── README.md              # Service-specific documentation
├── install.sh             # Installation script (requires root/sudo)
├── service-name.sh        # Container management script
└── service-name.service   # systemd service file
```

**Key architectural principles:**
- **Dedicated system users**: Each service runs as its own Linux user (e.g., `azurite`, `mssql`, `seq`) created at `/opt/service-name/`
- **User lingering**: All services use `loginctl enable-linger` to allow the service to run when the user is not logged in
- **Docker group membership**: Service users are added to the `docker` group for container access
- **Persistent data**: Services store data in `$HOME/.local/share/service-name-data` directories
- **Network mode**: Services use `--network host` for simplified networking
- **Container lifecycle**: Containers use `--restart=unless-stopped` policy
- **Security**: Services run as non-root users where possible (e.g., SQL Server runs as UID 10001)

### Management Script Pattern

All service management scripts (`*.sh`) follow this interface:

```bash
./service-name.sh {start|stop|status|health}
```

- `start`: Removes existing container (if present) and starts a new one
- `stop`: Stops and removes the container
- `status`: Shows container status via `docker ps -a`
- `health`: Performs service-specific health checks (e.g., HTTP endpoint tests)

### systemd Service Pattern

All `.service` files share common configuration:

- **Type**: `oneshot` with `RemainAfterExit=true`
- **Dependencies**: `After=network-online.target docker.service`, `Requires=docker.service`
- **ExecStart/Stop/Reload**: Calls the management script with appropriate command
- **Timeouts**: 60s start timeout, 30s stop timeout
- **Restart**: `Restart=on-failure`
- **User/Group**: Runs as dedicated service user

## Installation Workflow

All services follow this installation pattern:

1. Run `install.sh` with sudo/root
2. Script creates dedicated system user (if not exists)
3. Script adds user to docker group and enables lingering
4. Copies management script to `/opt/service-name/` with execute permissions
5. Copies systemd service file to `/etc/systemd/system/`
6. Runs `systemctl daemon-reload` and `systemctl enable`
7. User manually starts with `sudo systemctl start service-name.service`

**Important**: Installation scripts must be run as root/sudo and check for this at the start.

## Services Overview

### azurite/
Azure Storage Emulator - ports 10000 (Blob), 10001 (Queue), 10002 (Table)

### aspire-dashboard/
.NET Aspire dashboard for application monitoring

### json-server/
RESTful API mock server with multiple instances on ports 3010, 3011, 3012
- Uses separate systemd service files for each port
- Shares `db.json` database file

### pgsql/
PostgreSQL database with pgAdmin
- Uses docker-compose instead of systemd
- Run with `docker-compose up -d` in the directory

### seq/
Datalust SEQ logging server
- Web dashboard on port 8081 (maps to container port 80)
- Ingestion API on port 5341

### sqlserver/
SQL Server 2022 container
- Port 1433
- Includes sample database setup scripts (`setup-acmedb.sh`, `setup-acmedb.sql`)

### valkey/
Valkey (Redis-compatible) in-memory data store

## Conventions

### File Naming
- Management scripts: `service-name.sh` (lowercase with hyphens)
- systemd files: `service-name.service` (must match for systemd)
- Installation scripts: Always named `install.sh`

### Script Requirements
- All scripts use `#!/bin/bash` or `#!/usr/bin/bash` shebang
- Installation scripts check for root with: `if [ "$EUID" -ne 0 ]`
- Management scripts define configuration variables at the top (CONTAINER_NAME, IMAGE, PORTS, DATA_PATH)
- All scripts provide helpful echo messages for user feedback

### Container Configuration
- Container names match the service name (e.g., `azurite`, `mssql-server`)
- Data persistence uses named volumes mapped to user's home directory
- Images pulled from official sources (MCR, Docker Hub)
- Containers removed before starting to ensure clean state (`docker rm -f`)

### Health Checks
- HTTP services use `curl` to test endpoints
- Health check functions return 0 for healthy, 1 for unhealthy
- Health checks verify both container running and endpoint responsiveness

## Version Management

- Uses PowerShell script `git-tag.ps1` for annotated Git tags
- Follows Semantic Versioning (MAJOR.MINOR.PATCH)
- CHANGELOG.md follows Keep a Changelog format

## Documentation Standards

Each service directory must have:
- README.md with Prerequisites, Files Overview, Installation, Usage, and Troubleshooting sections
- Clear distinction between installation (one-time) and usage (ongoing) commands
- Examples of systemd commands (start, stop, status, journalctl)
- Port numbers and access URLs prominently displayed
