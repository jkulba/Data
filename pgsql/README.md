# PostgreSQL

PostgreSQL is a powerful open-source relational database. This setup runs a single PostgreSQL instance as a Docker container managed by a systemd service with persistent data storage and health checks.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Files](#files)
4. [Installation](#installation)
5. [Managing the Service](#managing-the-service)
6. [Management Script Commands](#management-script-commands)
7. [Running with Docker Compose](#running-with-docker-compose)
8. [Connecting to PostgreSQL](#connecting-to-postgresql)
9. [Example Runbook](#example-runbook)
10. [Data Persistence](#data-persistence)
11. [Health Checks](#health-checks)
12. [Troubleshooting](#troubleshooting)
13. [Security Notes](#security-notes)
14. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Container image | `postgres:latest` |
| Container name | `pgsql` |
| Service user | `pgsql` |
| Port | `5432` |
| Database name | `default_database` |
| Username | `admin` |
| Password | `P@ssword92` |
| Data path | `/home/pgsql/.local/share/pgsql-data` |

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Docker | Container runtime |
| Root / sudo | Required for installation and systemd setup |
| Linux system | Tested on Debian / Ubuntu |
| systemd | For service management |

---

## Files

| File | Description |
|------|-------------|
| `pgsql.sh` | Container management script (start/stop/status/health) |
| `pgsql.service` | systemd service unit file |
| `install.sh` | One-time installation script (requires root) |
| `compose.yml` | Docker Compose alternative to systemd service |
| `README.md` | This file |

---

## Installation

Run the install script once to set up the service:

```bash
cd /path/to/Data/pgsql
sudo ./install.sh
```

**What the install script does:**

1. Creates a `pgsql` system user with home directory at `/opt/pgsql`
2. Adds the `pgsql` user to the `docker` group
3. Enables user lingering (`loginctl enable-linger pgsql`)
4. Copies `pgsql.sh` to `/opt/pgsql/` with execute permissions
5. Copies `pgsql.service` to `/etc/systemd/system/`
6. Runs `systemctl daemon-reload` and enables the service to start on boot

After installation, start the service manually for the first time:

```bash
sudo systemctl start pgsql.service
```

---

## Managing the Service

```bash
# Start
sudo systemctl start pgsql.service

# Stop
sudo systemctl stop pgsql.service

# Check status
sudo systemctl status pgsql.service

# Enable auto-start on boot (done by install script)
sudo systemctl enable pgsql.service

# Disable auto-start
sudo systemctl disable pgsql.service

# View logs
sudo journalctl -xeu pgsql.service

# Follow real-time logs
sudo journalctl -fu pgsql.service
```

---

## Management Script Commands

The `pgsql.sh` script can also be called directly as the `pgsql` user:

```bash
sudo -u pgsql /opt/pgsql/pgsql.sh start
sudo -u pgsql /opt/pgsql/pgsql.sh stop
sudo -u pgsql /opt/pgsql/pgsql.sh status
sudo -u pgsql /opt/pgsql/pgsql.sh health
```

---

## Running with Docker Compose

As an alternative to the systemd service:

```bash
cd /path/to/Data/pgsql
docker compose up -d
```

Stop and remove containers (data is preserved):

```bash
docker compose down
```

Stop and remove containers and volumes (data is deleted):

```bash
docker compose down -v
```

---

## Connecting to PostgreSQL

### From the Host Machine

```bash
psql -h localhost -p 5432 -U admin -d default_database
```

Enter the password `P@ssword92` when prompted.

### From Inside the Container

```bash
docker exec -it pgsql psql -U admin -d default_database
```

### Connection Details

| Field | Value |
|-------|-------|
| Host | `localhost` |
| Port | `5432` |
| Database | `default_database` |
| Username | `admin` |
| Password | `P@ssword92` |

### Connection Strings

```
# URI format
postgresql://admin:P@ssword92@localhost:5432/default_database

# DSN format
host=localhost port=5432 dbname=default_database user=admin password=P@ssword92

# .NET connection string
Host=localhost;Port=5432;Database=default_database;Username=admin;Password=P@ssword92
```

---

## Example Runbook

```sql
-- Create a database
CREATE DATABASE myapp;

-- Connect to it
\c myapp

-- Create a table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert records
INSERT INTO users (name, email) VALUES
    ('Alice Johnson', 'alice@example.com'),
    ('Bob Smith', 'bob@example.com');

-- Query records
SELECT * FROM users;

-- Update a record
UPDATE users SET name = 'Alice J. Johnson' WHERE id = 1;

-- Delete a record
DELETE FROM users WHERE id = 2;
```

---

## Data Persistence

Database files are stored on the host at `/home/pgsql/.local/share/pgsql-data` and mounted into the container at `/var/lib/postgresql/data`.

| Scenario | Data preserved? |
|----------|----------------|
| Container stopped | ✅ Yes |
| Container removed | ✅ Yes |
| System reboot | ✅ Yes |

**Backup:**

```bash
docker exec pgsql pg_dump -U admin default_database > backup.sql
```

**Restore:**

```bash
docker exec -i pgsql psql -U admin default_database < backup.sql
```

---

## Health Checks

```bash
# Check service status
sudo systemctl status pgsql.service

# Run the built-in health check
sudo -u pgsql /opt/pgsql/pgsql.sh health

# Check if PostgreSQL is accepting connections
docker exec pgsql pg_isready -U admin

# View container logs
docker logs pgsql
```

Expected output from `pg_isready`: `localhost:5432 - accepting connections`

---

## Troubleshooting

**Check Docker is installed and running:**

```bash
docker --version
sudo systemctl status docker
```

**Verify the pgsql user has Docker group access:**

```bash
groups pgsql
```

**Container fails to start:**
- View service logs: `sudo journalctl -xeu pgsql.service`
- View container logs: `docker logs pgsql`
- Ensure port 5432 is free: `sudo lsof -i :5432`

**Data directory permissions error:**

```bash
sudo chown -R pgsql:pgsql /home/pgsql/.local/share/pgsql-data
```

**Reset everything and start fresh:**

```bash
sudo systemctl stop pgsql.service
sudo systemctl disable pgsql.service
docker rm -f pgsql
sudo rm -rf /home/pgsql/.local/share/pgsql-data
sudo ./install.sh
sudo systemctl start pgsql.service
```

---

## Security Notes

> ⚠️ **Warning:** The default password (`P@ssword92`) is hardcoded in the scripts. Before using in any shared or production-like environment:

1. Change the password in `pgsql.sh` before installation.
2. Use environment variables or a secrets manager instead of hardcoded credentials.
3. Restrict network access to port `5432`.

---

## Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Hub – postgres](https://hub.docker.com/_/postgres)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
