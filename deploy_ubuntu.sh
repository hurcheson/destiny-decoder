#!/bin/bash
# Ubuntu Server Deployment Script for Destiny Decoder Backend
# Run this script on the Ubuntu 22.04 droplet

set -e  # Exit on any error

echo "=== Destiny Decoder Backend Deployment ==="
echo "Target: /var/www/destiny-decoder/backend"
echo ""

# Check if we're in the right directory
if [ ! -d "/var/www/destiny-decoder" ]; then
    echo "ERROR: /var/www/destiny-decoder does not exist"
    exit 1
fi

cd /var/www/destiny-decoder

# Check if backend directory exists
if [ ! -d "backend" ]; then
    echo "ERROR: backend directory not found. Please upload the backend code first."
    exit 1
fi

# Fix ownership of the entire project directory first
echo "Ensuring correct ownership..."
sudo chown -R www-data:www-data /var/www/destiny-decoder

# Check if virtualenv exists
if [ ! -d "backend/venv" ]; then
    echo "Virtual environment not found. Creating it..."
    cd backend
    sudo -u www-data python3 -m venv venv
    cd ..
else
    echo "✓ Virtual environment found"
    # Ensure venv has correct ownership
    sudo chown -R www-data:www-data backend/venv
fi

# Activate virtual environment (for compatibility checks)
source backend/venv/bin/activate

# Ensure pip is up to date (run as www-data)
echo "Updating pip..."
sudo -u www-data backend/venv/bin/pip install --upgrade pip

# Check if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "Installing dependencies from requirements.txt..."
    sudo -u www-data backend/venv/bin/pip install -r requirements.txt
else
    echo "ERROR: requirements.txt not found in /var/www/destiny-decoder"
    echo "Please ensure requirements.txt is in the project root"
    exit 1
fi

echo ""
echo "=== Dependency Installation Complete ==="
echo ""

# Test uvicorn locally
echo "=== Testing Backend with Uvicorn ==="
echo "Starting uvicorn on 127.0.0.1:8000..."
echo "Press Ctrl+C after verifying it starts successfully"
echo ""

cd backend
sudo -u www-data venv/bin/uvicorn main:app --host 127.0.0.1 --port 8000
