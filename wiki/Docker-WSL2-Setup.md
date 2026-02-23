# Docker / WSL2 Setup

Complete guide for setting up WSL2 and Docker CLI (without Docker Desktop) on Windows 11 Professional, including instructions for building and packaging Docker images for AstroJS and .NET 10 applications.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Install WSL2](#install-wsl2)
4. [Install Docker in WSL2](#install-docker-in-wsl2)
5. [Configure Docker](#configure-docker)
6. [Build an AstroJS Docker Image](#build-an-astrojs-docker-image)
7. [Build a .NET 10 Docker Image](#build-a-net-10-docker-image)
8. [Useful Docker Commands](#useful-docker-commands)
9. [Troubleshooting](#troubleshooting)
10. [Additional Resources](#additional-resources)

---

## Overview

This guide walks through installing **WSL2** (Windows Subsystem for Linux 2) and the **Docker Engine** (CLI-only, no Docker Desktop required) on a Windows 11 Professional machine. Once installed, Docker is available inside your WSL2 Linux environment and can run any of the services in this project.

---

## Prerequisites

| Requirement | Details |
|-------------|---------|
| Operating system | Windows 11 Professional |
| Access level | Administrator |
| BIOS / UEFI | Virtualization enabled |
| RAM | 8 GB minimum (16 GB recommended) |
| Disk space | 20 GB free |

---

## Install WSL2

### Step 1: Enable WSL2

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

Restart your computer when prompted.

### Step 2: Verify Installation

```powershell
wsl --version
```

### Step 3: Set WSL2 as Default

```powershell
wsl --set-default-version 2
```

### Step 4: Install Ubuntu

```powershell
wsl --install -d Ubuntu-22.04
```

### Step 5: Complete Ubuntu Setup

1. Launch Ubuntu from the Start menu.
2. Create a UNIX username and password when prompted.
3. Update packages:

```bash
sudo apt update && sudo apt upgrade -y
```

---

## Install Docker in WSL2

### Step 1: Remove Old Docker Versions

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

### Step 2: Install Prerequisites

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

### Step 3: Add Docker's Official GPG Key

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### Step 4: Set Up the Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 5: Install Docker Engine

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 6: Verify the Installation

```bash
docker --version
```

---

## Configure Docker

### Step 1: Start the Docker Service

```bash
sudo service docker start
```

### Step 2: Enable Docker to Start Automatically

Add the following to `~/.bashrc` (or `~/.zshrc`):

```bash
# Start Docker daemon automatically when WSL2 starts
if [ ! -S /var/run/docker.sock ]; then
    sudo service docker start > /dev/null 2>&1
fi
```

Reload the shell:

```bash
source ~/.bashrc
```

### Step 3: Add Your User to the Docker Group

```bash
sudo usermod -aG docker $USER
```

> **Important:** Log out of WSL2 and reopen Ubuntu for the group change to take effect.

### Step 4: Verify Docker Works Without sudo

```bash
docker run hello-world
```

You should see a **Hello from Docker!** message.

### Step 5: Tune Docker for WSL2 Performance

Create or edit `/etc/docker/daemon.json`:

```bash
sudo nano /etc/docker/daemon.json
```

Add:

```json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

Restart Docker:

```bash
sudo service docker restart
```

---

## Build an AstroJS Docker Image

### Step 1: Create a Dockerfile

Navigate to your AstroJS project directory and create a `Dockerfile`:

**Server-side rendering (SSR) Dockerfile:**

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine AS runner
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm ci --only=production
EXPOSE 4321
ENV NODE_ENV=production
CMD ["node", "./dist/server/entry.mjs"]
```

**Static site generation (SSG) Dockerfile (nginx):**

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Step 2: Create a .dockerignore

```
node_modules
.git
.env
.env.*
*.log
dist
.vscode
README.md
```

### Step 3: Build and Test the Image

```bash
# Build
docker build -t astrojs-app:latest .

# Test
docker run -p 4321:4321 --name astrojs-container astrojs-app:latest

# Verify at http://localhost:4321

# Cleanup
docker stop astrojs-container && docker rm astrojs-container
```

---

## Build a .NET 10 Docker Image

### Step 1: Create a Dockerfile

Replace `YourProject` with your actual `.csproj` project name:

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["YourProject.csproj", "./"]
RUN dotnet restore "YourProject.csproj"
COPY . .
RUN dotnet build "YourProject.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "YourProject.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENTRYPOINT ["dotnet", "YourProject.dll"]
```

### Step 2: Create a .dockerignore

```
**/.git
**/.vs
**/.vscode
**/bin
**/obj
**/node_modules
**/docker-compose*
**/compose*
**/Dockerfile*
LICENSE
README.md
```

### Step 3: Build and Test the Image

```bash
# Build
docker build -t dotnet-api:latest .

# Test
docker run -p 8080:8080 --name dotnet-container dotnet-api:latest

# Verify
curl http://localhost:8080/api/health

# Cleanup
docker stop dotnet-container && docker rm dotnet-container
```

---

## Useful Docker Commands

### Image Management

```bash
docker images                  # List images
docker rmi <image-id>          # Remove an image
docker image prune -a          # Remove all unused images
```

### Container Management

```bash
docker ps                                  # List running containers
docker ps -a                               # List all containers
docker stop <container-name>               # Stop a container
docker rm <container-name>                 # Remove a container
docker logs <container-name>               # View container logs
docker logs -f <container-name>            # Follow live logs
docker exec -it <container-name> /bin/sh   # Open a shell inside the container
```

### Docker Compose

```bash
docker compose up -d    # Start services in the background
docker compose down     # Stop and remove services
docker compose logs -f  # Follow logs from all services
```

---

## Troubleshooting

### Docker Service Won't Start

```bash
sudo service docker status
sudo journalctl -u docker
sudo service docker restart
```

### Permission Denied

```bash
groups                          # Verify you are in the docker group
sudo usermod -aG docker $USER   # Re-add if missing, then log out/in
```

### WSL2 Integration Issues

From PowerShell (as Administrator):

```powershell
wsl --shutdown   # Restart WSL2
```

Then reopen Ubuntu.

### .NET Build Fails

Verify the project name in your Dockerfile matches the actual `.csproj` file:

```bash
ls *.csproj
```

### Port Already in Use

```bash
sudo lsof -i :8080          # Find what is using the port
sudo kill -9 <PID>          # Kill the process
```

### Access Windows Files from WSL2

Windows drives are mounted under `/mnt/`:

```bash
cd /mnt/c/Users/YourUsername/Projects
```

### Improve WSL2 Performance

Create `C:\Users\YourUsername\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true
```

Restart WSL2:

```powershell
wsl --shutdown
```

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [WSL2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [AstroJS Docker Guide](https://docs.astro.build/en/guides/deploy/)
- [.NET Docker Documentation](https://docs.microsoft.com/en-us/dotnet/core/docker/)
