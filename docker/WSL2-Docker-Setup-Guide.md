# WSL2 and Docker Setup Guide for Windows 11 Professional

Complete guide for setting up WSL2 and Docker CLI (without Docker Desktop) on Windows 11 Professional, including instructions for building and packaging Docker images for AstroJS and .NET 10 applications.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Install WSL2](#install-wsl2)
3. [Install Docker in WSL2](#install-docker-in-wsl2)
4. [Configure Docker](#configure-docker)
5. [Build AstroJS Docker Image](#build-astrojs-docker-image)
6. [Build .NET 10 Docker Image](#build-net-10-docker-image)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Windows 11 Professional
- Administrator access
- Virtualization enabled in BIOS/UEFI
- At least 8GB RAM (16GB recommended)
- 20GB free disk space

---

## Install WSL2

### Step 1: Enable WSL2

1. Open PowerShell as Administrator
2. Run the following command: 

```powershell
wsl --install
```

3.  Restart your computer when prompted

### Step 2: Verify Installation

After restart, open PowerShell and check WSL version:

```powershell
wsl --version
```

### Step 3: Set WSL2 as Default

```powershell
wsl --set-default-version 2
```

### Step 4: Install Ubuntu (Recommended Distribution)

```powershell
wsl --install -d Ubuntu-22.04
```

### Step 5: Complete Ubuntu Setup

1. Launch Ubuntu from Start menu
2. Create your UNIX username and password when prompted
3. Update packages: 

```bash
sudo apt update && sudo apt upgrade -y
```

---

## Install Docker in WSL2

### Step 1: Remove Old Docker Versions (if any)

```bash
sudo apt remove docker docker-engine docker.io containerd runc
```

### Step 2: Install Prerequisites

```bash
sudo apt update
sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

### Step 3: Add Docker's Official GPG Key

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

### Step 4: Set Up Docker Repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 5: Install Docker Engine

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 6: Verify Docker Installation

```bash
docker --version
```

---

## Configure Docker

### Step 1: Start Docker Service

```bash
sudo service docker start
```

### Step 2: Enable Docker to Start Automatically

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
echo '# Start Docker daemon automatically' >> ~/.bashrc
echo 'if [ ! -S /var/run/docker.sock ]; then' >> ~/.bashrc
echo '    sudo service docker start > /dev/null 2>&1' >> ~/.bashrc
echo 'fi' >> ~/.bashrc
source ~/.bashrc
```

### Step 3: Add Your User to Docker Group (Avoid using sudo)

```bash
sudo usermod -aG docker $USER
```

**Important:** Log out and log back into WSL2 for group changes to take effect: 

```bash
exit
# Then reopen Ubuntu from Start menu
```

### Step 4: Verify Docker Works Without Sudo

```bash
docker run hello-world
```

You should see a "Hello from Docker!" message.

### Step 5: Configure Docker for WSL2 Performance

Create or edit `/etc/docker/daemon.json`:

```bash
sudo nano /etc/docker/daemon.json
```

Add the following configuration:

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

## Build AstroJS Docker Image

### Step 1: Create Dockerfile for AstroJS

Navigate to your AstroJS project directory in WSL2:

```bash
cd /mnt/c/path/to/your/astrojs-project
# or if project is in WSL filesystem
cd ~/projects/astrojs-app
```

Create a `Dockerfile`:

```bash
nano Dockerfile
```

Add the following content:

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy project files
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:20-alpine AS runner

WORKDIR /app

# Copy built files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# Expose port (adjust if your app uses different port)
EXPOSE 4321

# Set environment to production
ENV NODE_ENV=production

# Start the application
CMD ["node", "./dist/server/entry.mjs"]
```

**Note:** If using static site generation (SSG), use this alternative Dockerfile:

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Production stage with nginx
FROM nginx:alpine

# Copy built static files
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config (optional)
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

### Step 2: Create .dockerignore

```bash
nano .dockerignore
```

Add:

```
node_modules
.git
.gitignore
.env
.env.*
*.log
dist
.vscode
.idea
README.md
```

### Step 3: Build the Docker Image

```bash
docker build -t astrojs-app:latest .
```

### Step 4: Test the Docker Image

```bash
docker run -p 4321:4321 --name astrojs-container astrojs-app:latest
```

Open browser and navigate to `http://localhost:4321`

### Step 5: Stop and Remove Test Container

```bash
docker stop astrojs-container
docker rm astrojs-container
```

### Step 6: Save Docker Image (Optional)

To export the image for deployment:

```bash
docker save astrojs-app:latest | gzip > astrojs-app.tar.gz
```

---

## Build .NET 10 Docker Image

### Step 1: Navigate to .NET Project

```bash
cd /mnt/c/path/to/your/dotnet-api
# or
cd ~/projects/dotnet-api
```

### Step 2: Create Dockerfile for .NET 10

```bash
nano Dockerfile
```

Add the following content:

```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

# Copy csproj and restore dependencies
COPY ["YourProject.csproj", "./"]
RUN dotnet restore "YourProject.csproj"

# Copy everything else and build
COPY . .
RUN dotnet build "YourProject.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "YourProject.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

WORKDIR /app

# Copy published files
COPY --from=publish /app/publish .

# Expose ports (adjust as needed)
EXPOSE 8080
EXPOSE 8081

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Start the application
ENTRYPOINT ["dotnet", "YourProject.dll"]
```

**Important:** Replace `YourProject` with your actual project name.

### Step 3: Create .dockerignore

```bash
nano .dockerignore
```

Add:

```
**/.classpath
**/.dockerignore
**/.env
**/.git
**/.gitignore
**/.project
**/.settings
**/.toolstarget
**/.vs
**/.vscode
**/*.*proj.user
**/*.dbmdl
**/*.jfm
**/bin
**/charts
**/docker-compose*
**/compose*
**/Dockerfile*
**/node_modules
**/npm-debug.log
**/obj
**/secrets.dev.yaml
**/values.dev.yaml
LICENSE
README.md
```

### Step 4: Build the Docker Image

```bash
docker build -t dotnet-api:latest .
```

### Step 5: Test the Docker Image

```bash
docker run -p 8080:8080 --name dotnet-container dotnet-api:latest
```

Test the API: 

```bash
curl http://localhost:8080/api/health
# or use browser/Postman
```

### Step 6: Stop and Remove Test Container

```bash
docker stop dotnet-container
docker rm dotnet-container
```

### Step 7: Save Docker Image (Optional)

```bash
docker save dotnet-api:latest | gzip > dotnet-api.tar.gz
```

---

## Troubleshooting

### Docker Service Won't Start

```bash
# Check service status
sudo service docker status

# View logs
sudo journalctl -u docker

# Restart service
sudo service docker restart
```

### Permission Denied Errors

```bash
# Verify you're in docker group
groups

# If not, add yourself again
sudo usermod -aG docker $USER

# Log out and back in
exit
```

### WSL2 Integration Issues

```bash
# Restart WSL2 from PowerShell (as Administrator)
wsl --shutdown
# Then reopen Ubuntu
```

### Docker Build Fails for .NET

Ensure you have the correct project name in the Dockerfile. Check with:

```bash
ls *.csproj
```

### Port Already in Use

```bash
# Find what's using the port
sudo lsof -i :8080

# Or use netstat
sudo netstat -tulpn | grep 8080

# Kill the process
sudo kill -9 <PID>
```

### Access Windows Files from WSL2

Windows drives are mounted under `/mnt/`:

```bash
cd /mnt/c/Users/YourUsername/Projects
```

### Improve WSL2 Performance

Create or edit `.wslconfig` in your Windows user directory (`C:\Users\YourUsername\.wslconfig`):

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true
```

Restart WSL2 for changes to take effect:

```powershell
wsl --shutdown
```

---

## Useful Docker Commands

### Image Management

```bash
# List images
docker images

# Remove image
docker rmi <image-id>

# Remove unused images
docker image prune -a
```

### Container Management

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# Stop container
docker stop <container-name>

# Remove container
docker rm <container-name>

# View container logs
docker logs <container-name>

# Execute command in running container
docker exec -it <container-name> /bin/sh
```

### Docker Compose (Bonus)

To run both applications together, create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  astrojs-app:
    build: ./astrojs-project
    ports:
      - "4321:4321"
    restart: unless-stopped

  dotnet-api:
    build: ./dotnet-project
    ports:
      - "8080:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
    restart: unless-stopped
```

Run with:

```bash
docker compose up -d
```

---

## Next Steps

1. Consider setting up a container registry (Docker Hub, GitHub Container Registry, or Azure Container Registry)
2. Implement CI/CD pipelines for automated builds
3. Learn about Docker networking for multi-container applications
4. Explore Kubernetes for orchestration (if needed)
5. Set up monitoring and logging for your containers

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [WSL2 Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [AstroJS Docker Guide](https://docs.astro.build/en/guides/deploy/)
- [.NET Docker Documentation](https://docs.microsoft.com/en-us/dotnet/core/docker/)

---

**Last Updated:** 2025-12-19