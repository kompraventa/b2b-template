# syntax = docker/dockerfile:1

# Adjust NODE_VERSION as desired
ARG NODE_VERSION=20.9.0
FROM node:${NODE_VERSION}-slim AS base

LABEL fly_launch_runtime="Node.js"

# Node.js app lives here
WORKDIR /app
ENV NODE_ENV="production"
ENV PORT=9000
ENV DO_NOT_TRACK=1
ENV TURBO_TELEMETRY_DISABLED=1

# Enable Corepack to manage Yarn versions
RUN corepack enable && corepack prepare yarn@4.5.0 --activate

# Install turbo globally
RUN npm install -g turbo

# Install necessary build tools in a separate layer
FROM base AS build-tools
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential node-gyp pkg-config python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

# Build stage
FROM build-tools AS build
COPY package.json yarn.lock .yarnrc.yml ./

# Copy the shell script into the image
COPY start-backend.sh /app/start-backend.sh
RUN chmod +x /app/start-backend.sh

COPY . .

# Install node modules
# COPY .yarnrc.yml package.json yarn.lock ./
RUN yarn install

# Copy application code
COPY . .

# Final stage for app image
FROM base

# Copy built application
COPY --from=build /app /app

# Start the server by default, this can be overwritten at runtime
EXPOSE 9000

# CMD [ "yarn", "run", "start-backend" ]
CMD ["sh", "/app/start-backend.sh"]
