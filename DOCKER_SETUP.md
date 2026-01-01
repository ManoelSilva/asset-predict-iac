[Leia em português](DOCKER_SETUP.pt-br.md)

# Docker Compose Setup Guide

This guide explains how to set up and run the Asset Predict application stack locally using Docker Compose.

## Overview

The `docker-compose.yml` file orchestrates three services:
- **asset-predict-model**: ML model API service (port 5001)
- **asset-data-lake**: Data lake API service (port 5002)
- **asset-predict-web**: Angular web frontend served via nginx (port 80)

## Prerequisites

- Docker and Docker Compose installed
- MotherDuck token for database access
- Git (to clone dependency projects)

## Initial Setup

1. **Clone this repository**:
   ```bash
   git clone <asset-predict-iac-repo-url>
   cd asset-predict-iac
   ```

2. **Clone the dependency projects** at the same level as this directory:
   ```bash
   cd ..
   git clone https://github.com/manoelsilva/asset-predict-model.git asset-predict-model
   git clone https://github.com/manoelsilva/asset-data-lake.git asset-data-lake
   git clone https://github.com/manoelsilva/asset-predict-web.git asset-predict-web
   cd asset-predict-iac
   ```

   Your directory structure should look like:
   ```
   projects/
   ├── asset-predict-iac/
   │   └── docker-compose.yml
   ├── asset-predict-model/
   ├── asset-data-lake/
   └── asset-predict-web/
   ```

3. **Create a `.env` file** in the root directory:
   ```bash
   echo "MOTHERDUCK_TOKEN=your_motherduck_token_here" > .env
   ```
   Replace `your_motherduck_token_here` with your actual MotherDuck token.

4. **Ensure model files are available**: 
   Make sure your `.pt` and `.joblib` model files are in `../asset-predict-model/src/models/`. These will be mounted as a read-only volume into the container.

## Running the Services

### Start all services:
```bash
docker-compose up -d
```

### View logs:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f asset-predict-model
docker-compose logs -f asset-data-lake
docker-compose logs -f asset-predict-web
```

### Stop all services:
```bash
docker-compose down
```

### Restart a specific service:
```bash
docker-compose restart asset-predict-model
```

### Rebuild services after code changes:
```bash
docker-compose up -d --build
```

## Accessing the Services

After starting the services, you can access:

- **Frontend (Angular)**: `http://localhost`
- **Model API**: `http://localhost:5001`
- **Data Lake API**: `http://localhost:5002`

The web frontend automatically proxies API requests:
- `/api/b3/*` → `asset-predict-model:5001`
- `/asset/*` and `/assets` → `asset-data-lake:5002`

## Service Details

### asset-predict-model
- **Port**: 5001
- **Health Check**: Port connectivity check
- **Model Files**: Mounted from `../asset-predict-model/src/models` (read-only)
- **Environment Variables**: 
  - `MOTHERDUCK_TOKEN`: Required for database access
  - `ASSET_API_BASE_URL`: Automatically set to `http://asset-data-lake:5002/asset/` for Docker service communication

### asset-data-lake
- **Port**: 5002
- **Health Check**: `http://localhost:5002/health`
- **Environment Variables**: `MOTHERDUCK_TOKEN`

### asset-predict-web
- **Port**: 80
- **Health Check**: `http://localhost/health`
- **Dependencies**: Waits for asset-predict-model and asset-data-lake to be ready

## Network

All services communicate through a Docker bridge network (`asset-predict-network`), allowing them to reference each other by service name (e.g., `asset-predict-model:5001`).

## Troubleshooting

### Check service health:
```bash
docker-compose ps
```

### View service logs for errors:
```bash
docker-compose logs asset-predict-model
docker-compose logs asset-data-lake
docker-compose logs asset-predict-web
```

### Restart all services:
```bash
docker-compose restart
```

### Remove all containers and networks:
```bash
docker-compose down -v
```

### Check if ports are already in use:
```bash
# Windows
netstat -ano | findstr :5001
netstat -ano | findstr :5002
netstat -ano | findstr :80

# Linux/Mac
lsof -i :5001
lsof -i :5002
lsof -i :80
```

## Environment Variables

The `.env` file should contain:
```
MOTHERDUCK_TOKEN=your_motherduck_token_here
```

This token is automatically passed to both Python services (asset-predict-model and asset-data-lake).

### Service Communication

The `asset-predict-model` service needs to communicate with `asset-data-lake` to fetch asset data. In Docker Compose, this is configured via the `ASSET_API_BASE_URL` environment variable, which is automatically set to `http://asset-data-lake:5002/asset/` in the docker-compose.yml file. This allows services to communicate using Docker service names instead of `localhost`.

**Important**: If you're running services outside of Docker Compose, you may need to set `ASSET_API_BASE_URL` manually to point to the correct asset-data-lake service URL.

## Volume Mounts

- **Model files**: `../asset-predict-model/src/models` → `/app/src/models` (read-only)
  - This allows you to update model files on the host without rebuilding the container

## Development Workflow

1. Make changes to the code in the dependency project folders
2. Rebuild the affected service: `docker-compose up -d --build <service-name>`
3. Or rebuild all services: `docker-compose up -d --build`
4. Check logs to verify the changes: `docker-compose logs -f <service-name>`

## Notes

- Model files are mounted as read-only volumes, so you can update them without rebuilding containers
- The `docker-compose.yml` file uses relative paths (`../`) to reference the dependency projects at the same directory level

