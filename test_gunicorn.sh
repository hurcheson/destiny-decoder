#!/bin/bash
# Test Gunicorn with Uvicorn Workers
# Run this after deploy_ubuntu.sh succeeds

set -e

cd /var/www/destiny-decoder/backend

# Activate virtual environment
source venv/bin/activate

echo "=== Testing Gunicorn with Uvicorn Workers ==="
echo "Starting gunicorn on 127.0.0.1:8000..."
echo "Press Ctrl+C after verifying it starts successfully"
echo ""

gunicorn main:app \
    --workers 2 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 127.0.0.1:8000 \
    --access-logfile - \
    --error-logfile -
