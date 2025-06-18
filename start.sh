#!/bin/bash

# Flowise startup script for Coolify deployment
echo "🚀 Starting Flowise deployment..."

# Set environment variables
export NODE_ENV=production
export NODE_OPTIONS="--max-old-space-size=4096"

# Check if database directory exists
if [ ! -d "/root/.flowise" ]; then
    echo "📁 Creating Flowise data directory..."
    mkdir -p /root/.flowise
fi

# Wait for potential database initialization
echo "⏳ Initializing database..."
sleep 5

# Start Flowise
echo "🎯 Starting Flowise server..."
cd /usr/src
exec pnpm start 