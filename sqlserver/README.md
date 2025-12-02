# SQL Server Container Setup

This directory contains scripts and configuration files to run Microsoft SQL Server 2022 in a Podman container with systemd service management.

## Prerequisites

**Required:**
- **Podman** - Container runtime (rootless or rootful)
- **Root/sudo access** - Required for installation and systemd service setup

**System Requirements:**
- Linux system (tested on Debian)
- Minimum 2GB RAM for SQL Server
- systemd for service management

---

## Files Overview

### 1. install.sh

**Purpose:** Automated installation script that sets up the SQL Server container as a systemd service.

**What it does:**
- Verifies the script is run with root/sudo privileges
- Creates the `mssql` user (if it doesn't exist) with home directory at `/opt/mssql`
- Enables user lingering for the `mssql` user (allows services to run when user is not logged in)
- Copies `mssql.sh` script to `/opt/mssql/` and makes it executable
- Copies `mssql.service` to `/etc/systemd/system/` and makes it executable
- Reloads systemd and enables the service to start on boot
- Starts the SQL Server service immediately
- Displays service status

**Usage:**
```bash
sudo ./install.sh
```

**Notes:**
- Must be run as root or with sudo
- If the `mssql` user already exists, the script will display a message and continue
- The service will automatically start on system boot after installation

---

### 2. mssql.sh

**Purpose:** Container management script for starting, stopping, and monitoring the SQL Server container.

**Configuration:**
- **Container Name:** `mssql-server`
- **Image:** `mcr.microsoft.com/mssql/server:2022-latest`
- **SA Password:** `P@ssword92`
- **Port:** `1433` (default SQL Server port)
- **Data Path:** `/opt/mssql/mssql-data` (persistent storage)

**Commands:**
- `start` - Creates and starts the SQL Server container
- `stop` - Stops and removes the container
- `status` - Shows container status
- `health` - Checks if SQL Server is responding to queries

**Usage:**
```bash
# Start SQL Server
./mssql.sh start

# Stop SQL Server
./mssql.sh stop

# Check container status
./mssql.sh status

# Check SQL Server health
./mssql.sh health
```

**Features:**
- **Persistent Data:** Database files are stored in `/opt/mssql/mssql-data` and persist when the container is stopped or removed
- **Auto-restart:** Container configured with `--restart=unless-stopped` policy
- **Host Networking:** Uses `--network host` for direct port access

**Important:** The container runs as root inside, and data is persisted to the host filesystem. The script references undefined `HOST_UID` and `HOST_GID` variables on line 15 which may cause issues.

---

### 3. mssql.service

**Purpose:** systemd service unit file that manages the SQL Server container lifecycle.

**Service Configuration:**
- **Type:** `oneshot` (service starts and exits, container runs in background)
- **User/Group:** Runs as `mssql` user
- **ExecStart:** Calls `mssql.sh start`
- **ExecStop:** Calls `mssql.sh stop`
- **ExecReload:** Calls `mssql.sh status`
- **RemainAfterExit:** `true` (systemd considers service active after start script completes)
- **Restart:** `on-failure` (automatically restarts if the script fails)
- **Timeouts:** 60s for start, 30s for stop

**systemd Commands:**
```bash
# Start the service
sudo systemctl start mssql.service

# Stop the service
sudo systemctl stop mssql.service

# Check service status
sudo systemctl status mssql.service

# View logs
sudo journalctl -xeu mssql.service

# Enable on boot
sudo systemctl enable mssql.service

# Disable on boot
sudo systemctl disable mssql.service
```

---

### 4. setup-acmedb.sh & setup-acmedb.sql

**Purpose:** Database initialization scripts for creating a sample database with test data.

#### setup-acmedb.sh (Bash Script)

**What it does:**
1. Copies `setup-acmedb.sql` into the running container at `/tmp/setup-acmedb-database.sql`
2. Executes the SQL script using `sqlcmd` inside the container
3. Reports success or failure

**Usage:**
```bash
# Ensure SQL Server container is running first
./mssql.sh start

# Run the database setup script
./setup-acmedb.sh
```

**Connection Details:**
- **Container:** `mssql-server`
- **Username:** `sa`
- **Password:** `P@ssword92`
- **Tool:** `/opt/mssql-tools18/bin/sqlcmd` (inside container)

#### setup-acmedb.sql (SQL Script)

**What it creates:**
- **Database:** `AcmeDB`
- **Schema:** `Recruits`
- **Table:** `Recruits.Users` with the following structure:
  - `UserID` - UNIQUEIDENTIFIER (UUID) primary key
  - `FirstName` - NVARCHAR(50)
  - `LastName` - NVARCHAR(50)
  - `Email` - NVARCHAR(100) (unique)
  - `RegistrationDate` - DATETIME2 (defaults to current time)

**Sample Data:**
- Inserts 25 test records with Star Wars character names
- Each record has a unique email address and auto-generated UUID

**Why use these scripts:**
- Quick database setup for development/testing
- Demonstrates SQL Server features (schemas, UUIDs, constraints)
- Provides realistic test data for application development
- Can be customized for your own database initialization needs

---

## Quick Start

### Full Installation (Recommended)

```bash
# 1. Run the installation script
sudo ./install.sh

# 2. Verify the service is running
sudo systemctl status mssql.service

# 3. (Optional) Create sample database
./setup-acmedb.sh
```

### Manual Start (Without systemd)

```bash
# Start SQL Server
./mssql.sh start

# Check if it's healthy
./mssql.sh health

# Connect to SQL Server (from host)
sqlcmd -S localhost -U sa -P 'P@ssword92' -N -C
```

---

## Data Persistence

Database files are stored in `/opt/mssql/mssql-data` and are mounted into the container at `/var/opt/mssql`. This means:

- ✅ Data persists when the container is stopped
- ✅ Data persists when the container is removed
- ✅ Data persists across system reboots
- ✅ You can backup the data directory for disaster recovery

**Backup Example:**
```bash
sudo systemctl stop mssql.service
sudo tar -czf mssql-backup-$(date +%Y%m%d).tar.gz /opt/mssql/mssql-data
sudo systemctl start mssql.service
```

---

## Troubleshooting

### Check if Podman is installed
```bash
podman --version
```

### View container logs
```bash
podman logs mssql-server
```

### View service logs
```bash
sudo journalctl -xeu mssql.service -f
```

### Manually connect to SQL Server
```bash
podman exec -it mssql-server /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'P@ssword92' -N -C
```

### Remove everything and start fresh
```bash
sudo systemctl stop mssql.service
sudo systemctl disable mssql.service
podman rm -f mssql-server
sudo rm -rf /opt/mssql/mssql-data
sudo ./install.sh
```

---

## Security Notes

⚠️ **WARNING:** The default SA password (`P@ssword92`) is hardcoded in the scripts. For production use:

1. Change the password in `mssql.sh` before installation
2. Use environment variables or secrets management
3. Restrict network access to port 1433
4. Consider using certificate-based authentication


