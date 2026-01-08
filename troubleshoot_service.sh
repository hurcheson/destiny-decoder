#!/bin/bash
# Troubleshoot systemd service issues
# Run this on the Ubuntu server

echo "=== Destiny Backend Service Troubleshooting ==="
echo ""

# Check if service file exists
if [ ! -f "/etc/systemd/system/destiny-backend.service" ]; then
    echo "❌ Service file not found at /etc/systemd/system/destiny-backend.service"
    exit 1
fi
echo "✓ Service file exists"

# Check service status
echo ""
echo "=== Service Status ==="
sudo systemctl status destiny-backend.service --no-pager -l

# Check for errors in journal
echo ""
echo "=== Recent Journal Errors ==="
sudo journalctl -u destiny-backend.service -n 20 --no-pager

# Check if gunicorn exists
echo ""
echo "=== Checking Gunicorn ==="
if [ -f "/var/www/destiny-decoder/backend/venv/bin/gunicorn" ]; then
    echo "✓ Gunicorn found"
    ls -la /var/www/destiny-decoder/backend/venv/bin/gunicorn
else
    echo "❌ Gunicorn not found at /var/www/destiny-decoder/backend/venv/bin/gunicorn"
fi

# Check working directory
echo ""
echo "=== Checking Working Directory ==="
if [ -d "/var/www/destiny-decoder/backend" ]; then
    echo "✓ Working directory exists"
    ls -la /var/www/destiny-decoder/backend/main.py 2>/dev/null || echo "❌ main.py not found!"
else
    echo "❌ Working directory not found"
fi

# Check log directory
echo ""
echo "=== Checking Log Directory ==="
if [ -d "/var/log/destiny-backend" ]; then
    echo "✓ Log directory exists"
    ls -la /var/log/destiny-backend/
else
    echo "❌ Log directory not found"
    echo "Creating it now..."
    sudo mkdir -p /var/log/destiny-backend
    sudo chown -R www-data:www-data /var/log/destiny-backend
fi

# Check permissions
echo ""
echo "=== Checking Permissions ==="
echo "Project directory:"
ls -la /var/www/destiny-decoder/backend | head -5
echo ""
echo "Venv directory:"
ls -la /var/www/destiny-decoder/backend/venv/bin/gunicorn 2>/dev/null || echo "❌ Can't check gunicorn"

# Try to run gunicorn manually
echo ""
echo "=== Testing Gunicorn Manually ==="
echo "Attempting to run gunicorn as www-data..."
cd /var/www/destiny-decoder/backend
sudo -u www-data venv/bin/gunicorn --version
echo ""
echo "If you see a version number above, gunicorn works."
echo ""

# Suggestions
echo "=== Suggested Fixes ==="
echo ""
echo "1. If gunicorn is missing:"
echo "   cd /var/www/destiny-decoder/backend"
echo "   sudo -u www-data venv/bin/pip install gunicorn"
echo ""
echo "2. If permissions are wrong:"
echo "   sudo chown -R www-data:www-data /var/www/destiny-decoder"
echo "   sudo chown -R www-data:www-data /var/log/destiny-backend"
echo ""
echo "3. If main.py is missing:"
echo "   Make sure you uploaded the backend directory correctly"
echo ""
echo "4. After fixing, reload the service:"
echo "   sudo systemctl daemon-reload"
echo "   sudo systemctl restart destiny-backend.service"
echo "   sudo systemctl status destiny-backend.service"
