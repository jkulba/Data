# JSON Server

JSON Server provides a full fake REST API with zero coding. It is ideal for front-end prototyping and API testing. This project runs multiple JSON Server instances as systemd services on separate ports.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Managing the Services](#managing-the-services)
5. [API Endpoints](#api-endpoints)
6. [Example Runbook](#example-runbook)
7. [Database File](#database-file)
8. [Health Checks](#health-checks)
9. [Troubleshooting](#troubleshooting)
10. [Additional Resources](#additional-resources)

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
sudo apt update
sudo apt install -y nodejs npm
```

---

## Installation

Copy the service files to `/etc/systemd/system/` and enable them:

```bash
sudo cp json-server-3010.service /etc/systemd/system/
sudo cp json-server-3011.service /etc/systemd/system/
sudo cp json-server-3012.service /etc/systemd/system/

sudo cp db.json /opt/json-server/db.json

sudo systemctl daemon-reload
sudo systemctl enable json-server-3010.service
sudo systemctl enable json-server-3011.service
sudo systemctl enable json-server-3012.service
```

Create the `jsonserver` user and working directory:

```bash
sudo useradd --system --home /opt/json-server --shell /usr/sbin/nologin jsonserver
sudo mkdir -p /opt/json-server
sudo chown jsonserver:jsonserver /opt/json-server
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

Each instance exposes a full REST API for each resource in `db.json`. With the default `db.json`, the `users` resource is available on all three ports.

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

## Example Runbook

### Get All Users

```bash
curl http://localhost:3010/users
```

### Get a Single User

```bash
curl http://localhost:3010/users/1
```

### Add a New User

```bash
curl -X POST http://localhost:3010/users \
  -H "Content-Type: application/json" \
  -d '{
    "id": "10",
    "name": "Zoey Miller",
    "username": "zoey",
    "email": "zoey@mail.com",
    "phone": "1-608-555-1212",
    "website": "example.org"
  }'
```

### Update a User (full replace)

```bash
curl -X PUT http://localhost:3010/users/3 \
  -H "Content-Type: application/json" \
  -d '{
    "id": "3",
    "name": "Oscar Hendrickx Smith",
    "username": "oscarhkx",
    "email": "oscarhkx@example.com"
  }'
```

### Partially Update a User

```bash
curl -X PATCH http://localhost:3010/users/3 \
  -H "Content-Type: application/json" \
  -d '{"email": "newemail@example.com"}'
```

### Delete a User

```bash
curl -X DELETE http://localhost:3010/users/3
```

### Filter Users

```bash
# Filter by username
curl "http://localhost:3010/users?username=catalins"

# Pagination (page 1, limit 2)
curl "http://localhost:3010/users?_page=1&_limit=2"

# Sort by name ascending
curl "http://localhost:3010/users?_sort=name&_order=asc"
```

---

## Database File

The `db.json` file defines the data served by all instances. The default file contains a `users` resource:

```json
{
  "users": [
    {
      "id": "1",
      "name": "Catalina Watkins",
      "username": "catalins",
      "email": "tommie28@blick.com"
    },
    {
      "id": "2",
      "name": "Amelia Ryan",
      "username": "amelyan",
      "email": "hand.katelyn@kuhlman.edu.au"
    },
    {
      "id": "3",
      "name": "Oscar Hendrickx",
      "username": "oscarhkx",
      "email": "janssens.noemie@advalvas.be"
    }
  ]
}
```

> **Note:** JSON Server does not persist changes to `db.json` when running as a service — it serves the file as-is and caches mutations in memory. Restart the service to reset data to the original file.

---

## Health Checks

```bash
# Verify the service is running
sudo systemctl status json-server-3010.service

# Test the endpoint
curl http://localhost:3010/users

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

### Service fails to start

- Confirm `npx` is available: `which npx`
- Check that `/opt/json-server/db.json` exists and is readable by the `jsonserver` user
- View logs: `sudo journalctl -xeu json-server-3010.service`

### Port already in use

Find and stop the conflicting process:

```bash
sudo lsof -i :3010
sudo kill -9 <PID>
```

### Data not persisting between requests

JSON Server caches writes in memory only. To persist data, update `db.json` directly and restart the service:

```bash
sudo systemctl restart json-server-3010.service
```

---

## Additional Resources

- [JSON Server GitHub Repository](https://github.com/typicode/json-server)
- [My JSON Server (hosted demo)](https://my-json-server.typicode.com/)
