# syntax=docker/dockerfile:1

# ---------------------------------
# Stage 1: Build Dependencies
# ---------------------------------
FROM node:20-alpine AS dependencies
WORKDIR /app

# Copy package manifests first to leverage Docker layer caching
COPY package*.json ./

# Install only  dependencies to keep the image minimal and secure
RUN npm ci --omit=dev

# ---------------------------------
# Stage 2: Final Runtime
# ---------------------------------
FROM node:20-alpine AS runtime

# Enforce  mode and configure the default application port
ENV NODE_ENV=production PORT=3000
WORKDIR /app

# Copy  node_modules from the dependencies stage with proper file ownership
COPY --from=dependencies --chown=node:node /app/node_modules ./node_modules

# Copy application source code with non-root ownership
COPY --chown=node:node package.json ./package.json
COPY --chown=node:node src ./src

# Switch to the built-in non-root user for security (container hardening)
USER node

# Inform Docker that the container listens on port 3000 at runtime
EXPOSE 3000

# Container liveness/readiness engine probe linked directly to the README endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["node", "src/healthcheck.js"]

# Start the application using the preferred array/exec syntax
CMD ["node", "src/app.js"]
