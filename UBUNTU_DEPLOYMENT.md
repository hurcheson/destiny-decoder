# Ubuntu 22.04 Deployment Instructions
# Destiny Decoder FastAPI Backend

## Prerequisites on Ubuntu Server

Ensure you have:
- Ubuntu 22.04 DigitalOcean droplet with SSH access
- Python 3.10+ installed: `python3 --version`
- Root or sudo access

## Step-by-Step Deployment

### Step 1: Upload Backend Code to Server

From your local machine, upload the backend directory to the server:

```bash
# Option A: Using scp (from Windows/WSL or Git Bash)
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder
scp -r backend requirements.txt root@YOUR_SERVER_IP:/var/www/destiny-decoder/

# Option B: Using rsync (more efficient, from Linux/WSL)
rsync -avz --exclude '__pycache__' --exclude '*.pyc' \
    backend/ requirements.txt \
    root@YOUR_SERVER_IP:/var/www/destiny-decoder/
```

### Step 2: SSH into the Ubuntu Server

```bash
ssh root@YOUR_SERVER_IP
```

### Step 3: Install System Dependencies

```bash
# Update system packages
sudo apt update
sudo apt upgrade -y

# Install Python 3 and pip
sudo apt install -y python3 python3-pip python3-venv

# Install build essentials (needed for some Python packages)
sudo apt install -y build-essential python3-dev
```

### Step 4: Set Up Directory Structure

```bash
# Ensure directory exists
sudo mkdir -p /var/www/destiny-decoder
cd /var/www/destiny-decoder

# Create log directory for the service
sudo mkdir -p /var/log/destiny-backend

# Set ownership (we'll run as www-data)
sudo chown -R www-data:www-data /var/www/destiny-decoder
sudo chown -R www-data:www-data /var/log/destiny-backend
```

### Step 5: Create Virtual Environment

```bash
cd /var/www/destiny-decoder/backend
sudo -u www-data python3 -m venv venv
```

### Step 6: Upload and Run Deployment Script

Upload the deployment scripts from your local machine:

```bash
# From local machine (Windows/WSL/Git Bash)
scp deploy_ubuntu.sh test_gunicorn.sh root@YOUR_SERVER_IP:/var/www/destiny-decoder/

# On Ubuntu server, make scripts executable
cd /var/www/destiny-decoder
chmod +x deploy_ubuntu.sh test_gunicorn.sh
```

Run the deployment script:

```bash
sudo -u www-data ./deploy_ubuntu.sh
```

**Expected output:** Uvicorn should start and show:
```
INFO:     Started server process [XXXX]
INFO:     Waiting for application startup.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:8000
```

**Press Ctrl+C** after confirming it starts successfully.

### Step 7: Test Gunicorn

```bash
sudo -u www-data ./test_gunicorn.sh
```

**Expected output:** Gunicorn should start with workers:
```
[INFO] Starting gunicorn 21.2.0
[INFO] Listening at: http://127.0.0.1:8000
[INFO] Using worker: uvicorn.workers.UvicornWorker
[INFO] Booting worker with pid: XXXX
[INFO] Booting worker with pid: YYYY
```

**Press Ctrl+C** after confirming it works.

### Step 8: Install Systemd Service

Upload the service file:

```bash
# From local machine
scp destiny-backend.service root@YOUR_SERVER_IP:/tmp/

# On Ubuntu server, install the service
sudo cp /tmp/destiny-backend.service /etc/systemd/system/
sudo systemctl daemon-reload
```

### Step 9: Enable and Start the Service

```bash
# Enable service to start on boot
sudo systemctl enable destiny-backend.service

# Start the service
sudo systemctl start destiny-backend.service

# Check status
sudo systemctl status destiny-backend.service
```

**Expected output:**
```
● destiny-backend.service - Destiny Decoder FastAPI Backend
     Loaded: loaded (/etc/systemd/system/destiny-backend.service; enabled)
     Active: active (running) since ...
```

### Step 10: Verify the Service is Running

```bash
# Check if the service is active
sudo systemctl is-active destiny-backend.service
# Should output: active

# Check if it's listening on port 8000
sudo netstat -tlnp | grep 8000
# Should show: tcp 0 0 127.0.0.1:8000 0.0.0.0:* LISTEN

# Or using ss
sudo ss -tlnp | grep 8000

# Test the API endpoint
curl http://127.0.0.1:8000/docs
# Should return HTML for FastAPI docs
```

### Step 11: View Logs (if needed)

```bash
# View service logs
sudo journalctl -u destiny-backend.service -f

# View application logs
sudo tail -f /var/log/destiny-backend/access.log
sudo tail -f /var/log/destiny-backend/error.log
```

## Service Management Commands

```bash
# Start service
sudo systemctl start destiny-backend.service

# Stop service
sudo systemctl stop destiny-backend.service

# Restart service
sudo systemctl restart destiny-backend.service

# Reload (graceful restart)
sudo systemctl reload destiny-backend.service

# Check status
sudo systemctl status destiny-backend.service

# View logs
sudo journalctl -u destiny-backend.service -n 50
```

## Verification Checklist

- [ ] Backend code uploaded to /var/www/destiny-decoder/backend
- [ ] Virtual environment exists at /var/www/destiny-decoder/backend/venv
- [ ] Dependencies installed from requirements.txt
- [ ] Uvicorn test successful (Step 6)
- [ ] Gunicorn test successful (Step 7)
- [ ] Systemd service file installed
- [ ] Service is enabled: `sudo systemctl is-enabled destiny-backend.service` → enabled
- [ ] Service is active: `sudo systemctl is-active destiny-backend.service` → active
- [ ] Port 8000 is listening: `sudo ss -tlnp | grep 8000` shows LISTEN
- [ ] API responds: `curl http://127.0.0.1:8000/docs` returns content

## Troubleshooting

### Service fails to start

```bash
# Check detailed status
sudo systemctl status destiny-backend.service -l

# Check logs
sudo journalctl -u destiny-backend.service -n 100 --no-pager

# Check if port is already in use
sudo netstat -tlnp | grep 8000

# Check permissions
ls -la /var/www/destiny-decoder/backend
# Should be owned by www-data:www-data
```

### Permission errors

```bash
# Fix ownership
sudo chown -R www-data:www-data /var/www/destiny-decoder
sudo chown -R www-data:www-data /var/log/destiny-backend
```

### Python import errors

```bash
# Verify dependencies are installed
cd /var/www/destiny-decoder/backend
source venv/bin/activate
pip list
# Should show fastapi, uvicorn, pydantic, reportlab, etc.
```

### Service won't stop

```bash
# Force stop
sudo systemctl stop destiny-backend.service
sudo pkill -f gunicorn
```

## End Condition

✅ **Success:** Running FastAPI backend accessible at `http://127.0.0.1:8000` via Gunicorn and systemd.

Test:
```bash
curl http://127.0.0.1:8000/docs
```

Should return the FastAPI OpenAPI documentation page.

## Next Steps (Outside Scope)

After the backend is running, you may want to:
- Set up Nginx as reverse proxy
- Configure SSL/TLS
- Set up firewall rules
- Configure domain name
- Set up monitoring

(These are not part of this deployment task)
