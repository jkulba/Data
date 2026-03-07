# SQL Server

Microsoft SQL Server 2022 runs as a Docker container managed by a systemd service. Includes automated installation, persistent data storage, and sample database setup scripts.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Managing the Service](#managing-the-service)
5. [Management Script Commands](#management-script-commands)
6. [Connecting to SQL Server](#connecting-to-sql-server)
7. [Sample Database Setup](#sample-database-setup)
8. [Data Persistence](#data-persistence)
9. [Health Checks](#health-checks)
10. [Troubleshooting](#troubleshooting)
11. [Security Notes](#security-notes)
12. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Container image | `mcr.microsoft.com/mssql/server:2022-latest` |
| Container name | `mssql-server` |
| Service user | `mssql` |
| Port | `1433` |
| SA password | `P@ssword92` |
| Data path | `/home/mssql/.local/share/mssql-data` |

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Docker | Container runtime |
| Root / sudo | Required for installation and systemd setup |
| Linux system | Tested on Debian |
| RAM | Minimum 2 GB (SQL Server requirement) |
| systemd | For service management |

---

## Installation

Run the install script once:

```bash
cd /path/to/Data/sqlserver
sudo ./install.sh
```

**What the install script does:**

1. Verifies root / sudo privileges
2. Creates the `mssql` system user with home directory at `/opt/mssql`
3. Adds the `mssql` user to the `docker` group
4. Enables user lingering (`loginctl enable-linger mssql`)
5. Copies `mssql.sh` to `/opt/mssql/` with execute permissions
6. Copies `mssql.service` to `/etc/systemd/system/`
7. Runs `systemctl daemon-reload` and enables the service to start on boot

After installation, start the service manually for the first time:

```bash
sudo systemctl start mssql.service
```

---

## Managing the Service

```bash
# Start
sudo systemctl start mssql.service

# Stop
sudo systemctl stop mssql.service

# Check status
sudo systemctl status mssql.service

# Enable auto-start on boot (done by install script)
sudo systemctl enable mssql.service

# Disable auto-start
sudo systemctl disable mssql.service

# View logs
sudo journalctl -xeu mssql.service

# Follow real-time logs
sudo journalctl -fu mssql.service
```

---

## Management Script Commands

The `mssql.sh` script can be called directly as the `mssql` user:

```bash
# Start the container
sudo -u mssql /opt/mssql/mssql.sh start

# Stop the container
sudo -u mssql /opt/mssql/mssql.sh stop

# Check container status
sudo -u mssql /opt/mssql/mssql.sh status

# Run health check (tests SQL Server connectivity)
sudo -u mssql /opt/mssql/mssql.sh health
```

---

## Connecting to SQL Server

### From the Host Machine

Using `sqlcmd` (if installed on the host):

```bash
sqlcmd -S localhost -U sa -P 'P@ssword92' -N -C
```

### From Inside the Container

```bash
docker exec -it mssql-server \
  /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'P@ssword92' -N -C
```

### Connection String (.NET)

```
Server=localhost,1433;Database=master;User Id=sa;Password=P@ssword92;TrustServerCertificate=True;
```

### Connection Details

| Field | Value |
|-------|-------|
| Server | `localhost` |
| Port | `1433` |
| Username | `sa` |
| Password | `P@ssword92` |

---

## Sample Database Setup

The `setup-acmedb.sh` script creates a sample `AcmeDB` database with test data.

### Prerequisites

The SQL Server container must be running:

```bash
sudo systemctl status mssql.service
```

### Run the Setup Script

```bash
cd /path/to/Data/sqlserver
./setup-acmedb.sh
```

**What the script creates:**

| Object | Details |
|--------|---------|
| Database | `AcmeDB` |
| Schema | `Recruits` |
| Table | `Recruits.Users` |
| Columns | `UserID` (UUID PK), `FirstName`, `LastName`, `Email` (unique), `RegistrationDate` |
| Sample data | 25 rows with Star Wars character names |

### Query the Sample Data

```sql
USE AcmeDB;
SELECT * FROM Recruits.Users;
SELECT FirstName, LastName, Email FROM Recruits.Users ORDER BY LastName;
```

---

## Data Persistence

Database files are stored on the host at:

```
/home/mssql/.local/share/mssql-data
```

This directory is mounted into the container at `/var/opt/mssql`.

| Scenario | Data preserved? |
|----------|----------------|
| Container stopped | ✅ Yes |
| Container removed | ✅ Yes |
| System reboot | ✅ Yes |

### Backup

```bash
sudo systemctl stop mssql.service
sudo tar -czf mssql-backup-$(date +%Y%m%d).tar.gz /home/mssql/.local/share/mssql-data
sudo systemctl start mssql.service
```

### Restore

```bash
sudo systemctl stop mssql.service
sudo rm -rf /home/mssql/.local/share/mssql-data
sudo tar -xzf mssql-backup-YYYYMMDD.tar.gz -C /
sudo systemctl start mssql.service
```

---

## Health Checks

```bash
# Check service status
sudo systemctl status mssql.service

# Run the built-in health check
sudo -u mssql /opt/mssql/mssql.sh health

# Check container logs
docker logs mssql-server

# Verify connectivity manually
docker exec -it mssql-server \
  /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'P@ssword92' -N -C \
  -Q "SELECT @@VERSION"
```

Expected: SQL Server version string in the output.

---

## Troubleshooting

### Check if Docker is installed

```bash
docker --version
```

### Verify Docker service is running

```bash
sudo systemctl status docker
```

### View container logs

```bash
docker logs mssql-server
```

### Verify the mssql user is in the docker group

```bash
groups mssql
```

### Reset everything and start fresh

```bash
sudo systemctl stop mssql.service
sudo systemctl disable mssql.service
docker rm -f mssql-server
sudo rm -rf /home/mssql/.local/share/mssql-data
sudo ./install.sh
sudo systemctl start mssql.service
```

---

## Security Notes

> ⚠️ **Warning:** The default SA password (`P@ssword92`) is hardcoded in the scripts. Before using in any shared or production-like environment:

1. Change the password in `mssql.sh` before installation.
2. Use environment variables or a secrets manager instead of hardcoded credentials.
3. Restrict network access to port `1433`.
4. Consider certificate-based authentication.

---

## Additional Resources

- [SQL Server on Linux – Docker Quickstart](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker)
- [SQL Server Docker Hub](https://hub.docker.com/_/microsoft-mssql-server)
- [sqlcmd Reference](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility)
