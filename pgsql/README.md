# PostgreSQL

PostgreSQL is a powerful open-source relational database. This setup runs PostgreSQL together with pgAdmin (a web-based administration tool) using Docker Compose.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Files](#files)
4. [Starting the Services](#starting-the-services)
5. [Managing the Services](#managing-the-services)
6. [Connecting to PostgreSQL](#connecting-to-postgresql)
7. [Using pgAdmin](#using-pgadmin)
8. [Example Runbook](#example-runbook)
9. [Data Persistence](#data-persistence)
10. [Health Checks](#health-checks)
11. [Troubleshooting](#troubleshooting)
12. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| PostgreSQL image | `postgres:latest` |
| PostgreSQL port | `5432` |
| Database name | `default_database` |
| Username | `admin` |
| Password | `Password1` |
| Data volume | `./db-data/` |

---

## Prerequisites

- Docker and Docker Compose installed on your system
- No root access required (runs as your current user)

---

## Files

| File | Description |
|------|-------------|
| `compose.yml` | Docker Compose service definition |
| `README.md` | This file |

---

## Starting the Services

```bash
cd /path/to/Data/pgsql
docker compose up -d
```

This starts PostgreSQL in the background. Data is persisted in the `db-data/` directory created automatically by Docker Compose.

---

## Managing the Services

```bash
# Start services in the background
docker compose up -d

# Stop services (data is preserved)
docker compose down

# Stop services and remove volumes (data is deleted)
docker compose down -v

# View running containers
docker compose ps

# View logs
docker compose logs

# Follow real-time logs
docker compose logs -f

# Restart services
docker compose restart
```

---

## Connecting to PostgreSQL

### From the Host Machine

```bash
psql -h localhost -p 5432 -U admin -d default_database
```

Enter the password `Password1` when prompted.

### From Inside the Container

```bash
docker exec -it $(docker compose ps -q database) psql -U admin -d default_database
```

### Connection Strings

```
# URI format
postgresql://admin:Password1@localhost:5432/default_database

# DSN format
host=localhost port=5432 dbname=default_database user=admin password=Password1
```

---

## Using pgAdmin

To add pgAdmin, update `compose.yml` with the following service:

```yaml
services:
  database:
    image: postgres:latest
    ports:
      - 5432:5432
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: Password1
      POSTGRES_DB: default_database
    volumes:
      - ./db-data:/var/lib/postgresql/data

  pgadmin:
    image: dpage/pgadmin4:latest
    ports:
      - 5050:80
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: Password1
    depends_on:
      - database
```

Access pgAdmin at **[http://localhost:5050](http://localhost:5050)** and log in with `admin@example.com` / `Password1`. Add a server connection using:
- **Host:** `database` (the Compose service name)
- **Port:** `5432`
- **Username:** `admin`
- **Password:** `Password1`

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
```

---

## Data Persistence

The `db-data/` directory contains all PostgreSQL data files and persists across container restarts as long as you do not run `docker compose down -v`.

**Backup:**

```bash
docker compose exec database pg_dump -U admin default_database > backup.sql
```

**Restore:**

```bash
docker compose exec -T database psql -U admin default_database < backup.sql
```

---

## Health Checks

```bash
# Check if PostgreSQL is accepting connections
docker compose exec database pg_isready -U admin

# Check container status
docker compose ps
```

Expected: `localhost:5432 - accepting connections`

---

## Troubleshooting

**Cannot connect to PostgreSQL:**
- Confirm the container is running: `docker compose ps`
- Check container logs: `docker compose logs database`
- Ensure port 5432 is free: `sudo lsof -i :5432`

**Data directory permissions error:**

```bash
sudo chown -R $USER:$USER db-data/
```

**Forgotten password** — stop and remove the volume, then restart (this deletes all data):

```bash
docker compose down -v
docker compose up -d
```

---

## Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Hub – postgres](https://hub.docker.com/_/postgres)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
