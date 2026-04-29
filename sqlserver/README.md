# SQL Server

Microsoft SQL Server 2025 runs as a Docker container managed by a systemd service. Includes automated installation, persistent data storage, and sample database setup scripts.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Files](#files)
4. [Installation](#installation)
5. [Managing the Service](#managing-the-service)
6. [Management Script Commands](#management-script-commands)
7. [Connecting to SQL Server](#connecting-to-sql-server)
8. [Sample Database Setup](#sample-database-setup)
9. [Data Persistence](#data-persistence)
10. [Health Checks](#health-checks)
11. [Troubleshooting](#troubleshooting)
12. [Security Notes](#security-notes)
13. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Container image | `mcr.microsoft.com/mssql/server:2025-latest` |
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
| Linux system | Tested on Debian / Ubuntu |
| RAM | Minimum 2 GB (SQL Server requirement) |
| systemd | For service management |

---

## Files

| File | Description |
|------|-------------|
| `mssql.sh` | Container management script (start/stop/status/health) |
| `mssql.service` | systemd service unit file |
| `install.sh` | One-time installation script (requires root) |
| `setup-acmedb.sh` | Creates the sample AcmeDB database |
| `setup-acmedb.sql` | SQL script run by setup-acmedb.sh |
| `README.md` | This file |

---

## Installation

Run the install script once to set up the service:

```bash
cd /path/to/Data/sqlserver
sudo ./install.sh
```

**What the install script does:**

1. Creates an `mssql` system user with home directory at `/opt/mssql`
2. Adds the `mssql` user to the `docker` group
3. Enables user lingering (`loginctl enable-linger mssql`)
4. Copies `mssql.sh` to `/opt/mssql/` with execute permissions
5. Copies `mssql.service` to `/etc/systemd/system/`
6. Runs `systemctl daemon-reload` and enables the service to start on boot

After installation, start the service manually for the first time:

```bash
sudo systemctl start mssql.service
```

> **Note:** SQL Server 2025 will run an in-place upgrade of any existing SQL Server 2022 data files on first start. Back up your data volume before upgrading.

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

The `mssql.sh` script can also be called directly as the `mssql` user:

```bash
sudo -u mssql /opt/mssql/mssql.sh start
sudo -u mssql /opt/mssql/mssql.sh stop
sudo -u mssql /opt/mssql/mssql.sh status
sudo -u mssql /opt/mssql/mssql.sh health
```

---

## Connecting to SQL Server

### From Inside the Container

```bash
docker exec -it mssql-server \
  /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'P@ssword92' -N -C
```

### From the Host Machine

```bash
sqlcmd -S localhost -U sa -P 'P@ssword92' -N -C
```

### Connection Details

| Field | Value |
|-------|-------|
| Server | `localhost` |
| Port | `1433` |
| Username | `sa` |
| Password | `P@ssword92` |

### .NET Connection String

```
Server=localhost,1433;Database=master;User Id=sa;Password=P@ssword92;TrustServerCertificate=True;
```

---

## Sample Database Setup

The `setup-acmedb.sh` script creates a sample `AcmeDB` database with test data.

```bash
# Ensure SQL Server is running first
sudo systemctl status mssql.service

# Run the setup script
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

```sql
USE AcmeDB;
SELECT * FROM Recruits.Users;
```

---

## Data Persistence

Database files are stored on the host at `/home/mssql/.local/share/mssql-data` and mounted into the container at `/var/opt/mssql`.

| Scenario | Data preserved? |
|----------|----------------|
| Container stopped | ✅ Yes |
| Container removed | ✅ Yes |
| System reboot | ✅ Yes |

**Backup:**

```bash
sudo systemctl stop mssql.service
sudo tar -czf mssql-backup-$(date +%Y%m%d).tar.gz /home/mssql/.local/share/mssql-data
sudo systemctl start mssql.service
```

---

## Health Checks

```bash
# Check service status
sudo systemctl status mssql.service

# Run the built-in health check
sudo -u mssql /opt/mssql/mssql.sh health

# View container logs
docker logs mssql-server

# Verify connectivity manually
docker exec -it mssql-server \
  /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'P@ssword92' -N -C \
  -Q "SELECT @@VERSION"
```

Expected: SQL Server version string in the output.

---

## Troubleshooting

**Check Docker is installed and running:**

```bash
docker --version
sudo systemctl status docker
```

**Verify the mssql user has Docker group access:**

```bash
groups mssql
```

**View container logs:**

```bash
docker logs mssql-server
```

**Reset everything and start fresh:**

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
