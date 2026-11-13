# Stage 1: Build / Dependencies
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev

# Stage 2: Production Runtime
FROM node:20-alpine AS runner
WORKDIR /app
# Copy installed production node_modules from builder
COPY --from=builder /app/node_modules ./node_modules
COPY server.js package.json ./

# Run as non-root user for security best practices
USER node

EXPOSE 3000
CMD ["npm", "start"]
