# PostgreSQL

PostgreSQL is a powerful, open-source relational database system. This section runs PostgreSQL together with pgAdmin (a web-based administration tool) using Docker Compose.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Starting the Services](#starting-the-services)
4. [Managing the Services](#managing-the-services)
5. [Connecting to PostgreSQL](#connecting-to-postgresql)
6. [Using pgAdmin](#using-pgadmin)
7. [Example Runbook](#example-runbook)
8. [Data Persistence](#data-persistence)
9. [Health Checks](#health-checks)
10. [Troubleshooting](#troubleshooting)
11. [Additional Resources](#additional-resources)

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

## Starting the Services

```bash
cd /path/to/Data/pgsql
docker compose up -d
```

This starts PostgreSQL in the background. Data is persisted in the `db-data/` directory that Docker Compose creates automatically.

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
# Using psql CLI (if installed)
psql -h localhost -p 5432 -U admin -d default_database
```

When prompted, enter the password: `Password1`

### From Inside the Container

```bash
docker exec -it <container-name> psql -U admin -d default_database
```

Find the container name with `docker compose ps`.

### Connection String

```
postgresql://admin:Password1@localhost:5432/default_database
```

### DSN Format (for applications)

```
host=localhost port=5432 dbname=default_database user=admin password=Password1
```

---

## Using pgAdmin

> pgAdmin is not included in the current `docker-compose.yml`. To add it, update the Compose file with the configuration below.

### Adding pgAdmin to docker-compose.yml

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

volumes:
  db-data:
```

After updating, restart services:

```bash
docker compose up -d
```

Access pgAdmin at: **[http://localhost:5050](http://localhost:5050)**

Login with `admin@example.com` / `Password1`, then add a server connection:
- **Host:** `database` (the Docker Compose service name)
- **Port:** `5432`
- **Username:** `admin`
- **Password:** `Password1`

---

## Example Runbook

### Create a New Database

```sql
-- Connect first, then run:
CREATE DATABASE myapp;
```

### Create a Table

```sql
\c myapp

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Insert Records

```sql
INSERT INTO users (name, email) VALUES
    ('Alice Johnson', 'alice@example.com'),
    ('Bob Smith', 'bob@example.com');
```

### Query Records

```sql
SELECT * FROM users;
SELECT * FROM users WHERE email = 'alice@example.com';
```

### Update a Record

```sql
UPDATE users SET name = 'Alice J. Johnson' WHERE id = 1;
```

### Delete a Record

```sql
DELETE FROM users WHERE id = 2;
```

---

## Data Persistence

The `db-data/` directory (created by Docker Compose) contains all PostgreSQL data files. This directory persists across container restarts and removals as long as you do not run `docker compose down -v`.

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

# Alternatively
docker compose ps
```

Expected output from `pg_isready`: `localhost:5432 - accepting connections`

---

## Troubleshooting

### Cannot connect to PostgreSQL

- Confirm the container is running: `docker compose ps`
- Check container logs: `docker compose logs database`
- Ensure port 5432 is not in use by another process: `sudo lsof -i :5432`

### Data directory permissions error

```bash
# Reset ownership of the data directory
sudo chown -R $USER:$USER db-data/
```

### Forgotten password

Stop the services, remove the data volume, and restart:

```bash
docker compose down -v
docker compose up -d
```

> **Warning:** This deletes all database data.

---

## Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Docker Hub – postgres](https://hub.docker.com/_/postgres)
- [pgAdmin Documentation](https://www.pgadmin.org/docs/)
- [docker-compose-postgres (reference)](https://github.com/felipewom/docker-compose-postgres)
