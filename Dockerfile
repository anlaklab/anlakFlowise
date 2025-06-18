# Build local monorepo image optimized for Coolify
# docker build --no-cache -t  flowise .

# Run image
# docker run -d -p 3000:3000 flowise

FROM node:20-alpine

# Install system dependencies in one layer
RUN apk add --update --no-cache \
    libc6-compat \
    python3 \
    make \
    g++ \
    build-base \
    cairo-dev \
    pango-dev \
    chromium \
    curl

# Install PNPM globally
RUN npm install -g pnpm

# Set environment variables
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV NODE_OPTIONS=--max-old-space-size=4096
ENV NODE_ENV=production

WORKDIR /usr/src

# Copy package files first for better caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages/*/package.json ./packages/*/

# Install dependencies
RUN pnpm install --frozen-lockfile --prod=false

# Copy source code
COPY . .

# Build the application
RUN pnpm build

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:3000/api/v1/ping || exit 1

# Copy and set up startup script
COPY start.sh /usr/src/start.sh
RUN chmod +x /usr/src/start.sh

# Start the application
CMD [ "/usr/src/start.sh" ]
