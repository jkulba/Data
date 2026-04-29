# JSON Server

JSON Server provides a full fake REST API with zero coding. Ideal for front-end prototyping and API testing. This project runs multiple JSON Server instances as systemd services on separate ports.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Files](#files)
4. [Installation](#installation)
5. [Managing the Services](#managing-the-services)
6. [API Endpoints](#api-endpoints)
7. [Example Requests](#example-requests)
8. [Database File](#database-file)
9. [Health Checks](#health-checks)
10. [Troubleshooting](#troubleshooting)
11. [Additional Resources](#additional-resources)

---

## Overview

| Property | Value |
|----------|-------|
| Runtime | Node.js / npx |
| Service user | `jsonserver` |
| Instances | 3 (ports 3010, 3011, 3012) |
| Database file | `/opt/json-server/db.json` |
| Service files | `json-server-3010.service`, `json-server-3011.service`, `json-server-3012.service` |

Each instance serves the same `db.json` file on a different port, giving you multiple isolated endpoints for parallel testing.

---

## Prerequisites

- Node.js and `npx` installed on your system
- Root / sudo access (for systemd installation)

Install Node.js on Debian / Ubuntu:

```bash
sudo apt update && sudo apt install -y nodejs npm
```

---

## Files

| File | Description |
|------|-------------|
| `db.json` | The data file served by all instances |
| `json-server-3010.service` | systemd service for port 3010 |
| `json-server-3011.service` | systemd service for port 3011 |
| `json-server-3012.service` | systemd service for port 3012 |
| `README.md` | This file |

---

## Installation

Create the service user and install directory:

```bash
sudo useradd --system --home /opt/json-server --shell /usr/sbin/nologin jsonserver
sudo mkdir -p /opt/json-server
sudo chown jsonserver:jsonserver /opt/json-server
sudo cp db.json /opt/json-server/db.json
```

Install and enable the systemd services:

```bash
sudo cp json-server-3010.service /etc/systemd/system/
sudo cp json-server-3011.service /etc/systemd/system/
sudo cp json-server-3012.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable json-server-3010.service json-server-3011.service json-server-3012.service
```

Start the services:

```bash
sudo systemctl start json-server-3010.service json-server-3011.service json-server-3012.service
```

---

## Managing the Services

Replace `3010` with `3011` or `3012` to manage the other instances.

```bash
# Start a single instance
sudo systemctl start json-server-3010.service

# Stop a single instance
sudo systemctl stop json-server-3010.service

# Check status
sudo systemctl status json-server-3010.service

# Enable auto-start on boot
sudo systemctl enable json-server-3010.service

# Disable auto-start
sudo systemctl disable json-server-3010.service

# View logs
sudo journalctl -xeu json-server-3010.service

# Follow real-time logs
sudo journalctl -fu json-server-3010.service
```

**Start all instances at once:**

```bash
sudo systemctl start json-server-3010.service json-server-3011.service json-server-3012.service
```

---

## API Endpoints

Each instance exposes a full REST API for every resource in `db.json`.

| Method | URL | Description |
|--------|-----|-------------|
| GET | `http://localhost:3010/users` | Get all users |
| GET | `http://localhost:3010/users/1` | Get user by ID |
| POST | `http://localhost:3010/users` | Create a user |
| PUT | `http://localhost:3010/users/1` | Replace a user |
| PATCH | `http://localhost:3010/users/1` | Update a user |
| DELETE | `http://localhost:3010/users/1` | Delete a user |

Replace `3010` with `3011` or `3012` for the other instances.

---

## Example Requests

```bash
# Get all users
curl http://localhost:3010/users

# Get a single user
curl http://localhost:3010/users/1

# Add a new user
curl -X POST http://localhost:3010/users \
  -H "Content-Type: application/json" \
  -d '{"id":"10","name":"Zoey Miller","username":"zoey","email":"zoey@mail.com"}'

# Partially update a user
curl -X PATCH http://localhost:3010/users/3 \
  -H "Content-Type: application/json" \
  -d '{"email":"newemail@example.com"}'

# Delete a user
curl -X DELETE http://localhost:3010/users/3

# Filter and paginate
curl "http://localhost:3010/users?_page=1&_limit=2&_sort=name&_order=asc"
```

---

## Database File

The `db.json` file defines the data served by all instances:

```json
{
  "users": [
    { "id": "1", "name": "Catalina Watkins", "username": "catalins", "email": "tommie28@blick.com" },
    { "id": "2", "name": "Amelia Ryan", "username": "amelyan", "email": "hand.katelyn@kuhlman.edu.au" },
    { "id": "3", "name": "Oscar Hendrickx", "username": "oscarhkx", "email": "janssens.noemie@advalvas.be" }
  ]
}
```

> **Note:** JSON Server does not persist writes to `db.json` — mutations are cached in memory only. Restart the service to reset data to the original file.

---

## Health Checks

```bash
# Check all three instances
for port in 3010 3011 3012; do
  echo -n "Port $port: "
  curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/users
  echo
done
```

Expected: HTTP `200` from each instance.

---

## Troubleshooting

**Service fails to start:**
- Confirm `npx` is available: `which npx`
- Confirm `/opt/json-server/db.json` exists: `ls -la /opt/json-server/`
- View logs: `sudo journalctl -xeu json-server-3010.service`

**Port already in use:**

```bash
sudo lsof -i :3010
sudo kill -9 <PID>
```

**Data not persisting between requests** — JSON Server caches writes in memory only. To persist changes, update `db.json` directly and restart the service.

---

## Additional Resources

- [JSON Server GitHub Repository](https://github.com/typicode/json-server)
- [My JSON Server (hosted demo)](https://my-json-server.typicode.com/)
