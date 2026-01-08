#!/bin/bash
# Fix permissions issue for existing venv
# Run this on the Ubuntu server if you're getting permission errors

set -e

echo "=== Fixing Permission Issues ==="

# Fix ownership of entire project directory
echo "Setting correct ownership for /var/www/destiny-decoder..."
sudo chown -R www-data:www-data /var/www/destiny-decoder

# Also fix log directory
echo "Setting correct ownership for /var/log/destiny-backend..."
sudo mkdir -p /var/log/destiny-backend
sudo chown -R www-data:www-data /var/log/destiny-backend

# If venv exists, ensure it has correct permissions
if [ -d "/var/www/destiny-decoder/backend/venv" ]; then
    echo "Fixing virtual environment permissions..."
    sudo chown -R www-data:www-data /var/www/destiny-decoder/backend/venv
    sudo chmod -R u+rwX /var/www/destiny-decoder/backend/venv
fi

echo ""
echo "✓ Permissions fixed!"
echo ""
echo "Now run the deployment script again:"
echo "  cd /var/www/destiny-decoder"
echo "  sudo -u www-data ./deploy_ubuntu.sh"
