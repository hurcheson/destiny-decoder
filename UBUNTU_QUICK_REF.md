# Ubuntu Deployment - Quick Reference

## Files to Upload to Server

```
From: c:\Users\ix_hurcheson\Desktop\destiny-decoder\
To: YOUR_SERVER_IP:/var/www/destiny-decoder/

Required files:
├── backend/                    (entire directory)
├── requirements.txt
├── deploy_ubuntu.sh           (deployment script)
├── test_gunicorn.sh           (gunicorn test script)
└── destiny-backend.service    (systemd service file)
```

## Upload Command (From Windows)

```bash
# Using SCP (Git Bash or WSL)
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder
scp -r backend requirements.txt deploy_ubuntu.sh test_gunicorn.sh destiny-backend.service fix_permissions.sh root@YOUR_SERVER_IP:/var/www/destiny-decoder/
```

## Server Setup Commands (Run on Ubuntu)

```bash
# 1. SSH into server
ssh root@YOUR_SERVER_IP

# 2. Install system dependencies
sudo apt update
sudo apt install -y python3 python3-pip python3-venv build-essential

# 3. Create directories
sudo mkdir -p /var/www/destiny-decoder
sudo mkdir -p /var/log/destiny-backend

# 3a. Fix permissions (IMPORTANT!)
cd /var/www/destiny-decoder
chmod +x fix_permissions.sh
sudo ./fix_permissions.sh

# 4. Make scripts executable
cd /var/www/destiny-decoder
chmod +x deploy_ubuntu.sh test_gunicorn.sh

# 5. Run deployment (installs deps, creates venv)
sudo -u www-data ./deploy_ubuntu.sh
# Press Ctrl+C after it starts successfully

# 6. Test gunicorn
sudo -u www-data ./test_gunicorn.sh
# Press Ctrl+C after it starts successfully

# 7. Install systemd service
sudo cp destiny-backend.service /etc/systemd/system/
sudo systemctl daemon-reload

# 8. Enable and start service
sudo systemctl enable destiny-backend.service
sudo systemctl start destiny-backend.service

# 9. Verify it's running
sudo systemctl status destiny-backend.service
curl http://127.0.0.1:8000/docs
```

## Verification Commands

```bash
# Service status
sudo systemctl is-active destiny-backend.service    # Should return: active
sudo systemctl is-enabled destiny-backend.service   # Should return: enabled

# Port check
sudo ss -tlnp | grep 8000                          # Should show LISTEN on 127.0.0.1:8000

# Test API
curl http://127.0.0.1:8000/docs                    # Should return HTML
```

## Service Management

```bash
sudo systemctl start destiny-backend.service       # Start
sudo systemctl stop destiny-backend.service        # Stop
sudo systemctl restart destiny-backend.service     # Restart
sudo systemctl status destiny-backend.service      # Check status
sudo journalctl -u destiny-backend.service -f      # View logs (live)
```

## Troubleshooting

### Permission Errors During Installation

If you get "Permission denied" errors during pip install:

```bash
# Upload and run the fix script
# From local machine:
scp fix_permissions.sh root@YOUR_SERVER_IP:/var/www/destiny-decoder/

# On server:
cd /var/www/destiny-decoder
chmod +x fix_permissions.sh
sudo ./fix_permissions.sh

# Then retry deployment
sudo -u www-data ./deploy_ubuntu.sh
```

Or manually fix:
```bash
sudo chown -R www-data:www-data /var/www/destiny-decoder
sudo chown -R www-data:www-data /var/log/destiny-backend
```

### Other Issues

```bash
# View recent logs
sudo journalctl -u destiny-backend.service -n 50

# Check error logs
sudo tail -f /var/log/destiny-backend/error.log

# Check if port is in use
sudo netstat -tlnp | grep 8000

# Fix permissions
sudo chown -R www-data:www-data /var/www/destiny-decoder
sudo chown -R www-data:www-data /var/log/destiny-backend

# Restart service
sudo systemctl restart destiny-backend.service
```

## Expected Results

✅ **Success Indicators:**
- `systemctl status destiny-backend.service` shows "active (running)"
- `curl http://127.0.0.1:8000/docs` returns FastAPI documentation
- `ss -tlnp | grep 8000` shows gunicorn listening on 127.0.0.1:8000
- No errors in: `journalctl -u destiny-backend.service`

## Important Notes

- Backend runs on 127.0.0.1:8000 (localhost only)
- Service runs as `www-data` user
- Logs are in `/var/log/destiny-backend/`
- 2 Gunicorn workers with Uvicorn worker class
- Service auto-starts on server reboot
- NO code changes made to backend application

## What NOT to Do

❌ Do NOT modify any Python files in backend/
❌ Do NOT change the numerology logic
❌ Do NOT alter PDF generation code
❌ Do NOT add new packages (unless already imported)
❌ Do NOT rename files or endpoints

This is a deployment-only task - the application code remains unchanged.
