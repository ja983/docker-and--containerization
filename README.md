Docker & Containerization Guide

A comprehensive reference covering Docker theory, architecture, core commands, and a step-by-step practical tutorial to containerize a Node.js web application.

Table of Contents

Objective 1: Containers vs. VMs, Architecture & Optimization

Objective 2: Commands, Networking, Volumes & Compose

Objective 3: Step-by-Step Practical Guide

Objective 1: Containers vs. VMs, Architecture & Optimization

1. Containers vs. Virtual Machines (VMs)

The fundamental difference lies in how virtualization is achieved:

Feature

Virtual Machines (VMs)

Containers

Virtualization Level

Hardware-level (Hypervisor / Type 1 or 2)

Operating System-level (Docker Engine)

Guest OS

Full guest OS required for each VM (heavy)

Shares the host OS kernel (lightweight)

Startup Time

Minutes (boots a full OS)

Milliseconds to seconds

Resource Overhead

High (GBs of RAM, dedicated vCPUs)

Low (MBs of RAM, shared resources)

2. Docker Architecture

Docker uses a Client-Server architecture:

Docker Client (docker CLI): The primary interface through which users interact with Docker (e.g., typing docker run). It sends commands to the daemon via a REST API.

Docker Daemon (dockerd): Runs on the host machine, listens for Docker API requests, and manages Docker objects (images, containers, networks, and volumes).

Docker Registry: A storage and distribution system for named Docker images (e.g., Docker Hub, Amazon ECR, GitHub Container Registry).

3. Images vs. Containers

Docker Image: A read-only template containing instructions for creating a container (application code, runtime, libraries, environment variables, and configuration files). Built in layers.

Docker Container: A runnable, isolated instance of an image. You can create, start, stop, move, or delete a container using the Docker API or CLI.

4. Dockerfile Optimization Best Practices

Leverage Layer Caching: Order your Dockerfile instructions from least frequently changed (e.g., copying package.json and installing dependencies) to most frequently changed (copying source code). This ensures Docker reuses cached layers efficiently.

Use Multi-Stage Builds: Separate your build environment from your production runtime environment to drastically reduce the final image size.

Use Minimal Base Images: Prefer lightweight variants like -alpine or -slim over full OS distributions where appropriate.

Always use .dockerignore: Prevent unnecessary files (like node_modules, .git, local logs, and environment secrets) from being sent to the Docker daemon build context.

Objective 2: Commands, Networking, Volumes & Compose

1. Essential Docker Commands

Operation

Command

Description

Build Image

docker build -t my-app:1.0 .

Builds an image from a Dockerfile in the current directory.

Run Container

docker run -d -p 8080:80 --name web-app my-app:1.0

Runs container in background (-d), mapping host port 8080 to container port 80.

List Containers

docker ps -a

Lists all running and stopped containers.

List Images

docker images

Lists all locally stored Docker images.

View Logs

docker logs -f web-app

Streams live console output/logs from a running container.

Execute Shell

docker exec -it web-app /bin/sh

Opens an interactive shell inside a running container.

Stop & Remove

docker stop web-app && docker rm web-app

Stops a running container and removes it.

2. Container Networking

Docker provides isolated networking so containers can communicate securely:

Bridge (Default): Creates a private internal network on the host. Containers on the same user-defined bridge network can communicate using their container names as hostnames.

Host: Removes network isolation between the container and the Docker host, using the host's networking directly.

None: Disables all networking for the container.

Port Mapping (-p HOST:CONTAINER): Exposes a container's internal port to the host machine so external traffic can reach it.

3. Volumes & Persistent Data

Containers are ephemeral—any data written inside a container's writable layer is lost when the container is removed.

Named Volumes: Managed by Docker (docker volume create my-data). Ideal for databases and persistent state.

Bind Mounts: Maps a specific file or directory on the host machine directly into the container (-v /host/path:/container/path). Ideal for live-reloading source code during development.

4. Environment Variables

Pass configuration dynamically without hardcoding secrets into your image:

Inline Flag: docker run -e PORT=3000 -e NODE_ENV=production my-app

Env File: docker run --env-file .env my-app

5. Docker Compose

Docker Compose is a tool for defining and running multi-container Docker applications using a single YAML configuration file (docker-compose.yml).

docker compose up -d: Builds images (if needed), creates networks/volumes, and starts all services in detached mode.

docker compose down: Stops and removes containers and networks created by up (add -v to also remove named volumes).

Objective 3: Step-by-Step Practical Guide

Follow this workflow to containerize a Node.js (Express) web application from scratch:

Source Code → Dockerfile → Image → Container → Docker Compose → Running Application

Step 1: Create the Source Code

Create a project directory and set up a minimal Express application:

mkdir my-node-app && cd my-node-app


Create package.json:

{
  "name": "my-node-app",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.19.2"
  }
}


Create server.js:

const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from inside a Docker container! 🐳');
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});


Step 2: Create .dockerignore and Dockerfile

Create a .dockerignore file to keep the build context clean and fast:

node_modules
Dockerfile
.dockerignore
docker-compose.yml
*.log
.git


Create an optimized multi-stage Dockerfile:

# Stage 1: Install Production Dependencies
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
# Uses npm install --omit=dev so it works even without a pre-existing package-lock.json
RUN npm install --omit=dev

# Stage 2: Production Runtime
FROM node:20-alpine AS runner
WORKDIR /app

# Copy installed production node_modules from builder stage
COPY --from=builder /app/node_modules ./node_modules
COPY server.js package.json ./

# Run as non-root user for security best practices
USER node

EXPOSE 3000
CMD ["npm", "start"]


Step 3: Build the Docker Image

Run the build command in your project root directory:

docker build -t my-web-app:1.0 .


Verify the image was created:

docker images


Step 4: Run and Test the Container

Start a container from your image, mapping port 3000 on your host to port 3000 inside the container:

docker run -d -p 3000:3000 --name my-running-app my-web-app:1.0


Verify the container is running and inspect logs:

docker ps
docker logs my-running-app


Visit http://localhost:3000 in your browser to see your running containerized application.

Step 5: Orchestrate with Docker Compose

First, stop and remove the standalone container you started in Step 4:

docker stop my-running-app && docker rm my-running-app


Create a docker-compose.yml file in your project root:

services:
  web:
    build: .
    container_name: my-web-app
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
    restart: unless-stopped


Start the application using Docker Compose:

docker compose up -d


Check the running status:

docker compose ps


When you are finished and want to tear down the environment:

docker compose down
