# Backend Server Connection Issues - SOLVED

## Problem
The Flask app was timing out when trying to reach the backend because the server was only listening on `127.0.0.1:8001` (localhost only) instead of `0.0.0.0:8001` (all network interfaces).

**Error seen:**
```
The request connection took longer than 0:00:15.000000 and it was aborted
```

## Root Cause
When you run the server with:
```bash
python run_server.py
```

...it defaults to localhost binding, which blocks external connections from your phone.

## Solution

### Step 1: Stop the current server
Press `Ctrl+C` in the terminal where the server is running.

### Step 2: Start the server correctly

**Option A - Windows Batch File:**
```batch
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder\backend
start_server.bat
```

**Option B - PowerShell Script:**
```powershell
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder\backend
.\start_server.ps1
```

**Option C - Manual command:**
```bash
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder\backend
python -m uvicorn run_server:app --host 0.0.0.0 --port 8001 --reload
```

### Step 3: Verify the server is accessible

**From your PC:**
Open browser to: http://localhost:8001/health

**From your phone:**
Open browser to: http://192.168.100.197:8001/health

Both should show:
```json
{"status":"ok","service":"Destiny Decoder API"}
```

### Step 4: Test the app
- Hot reload or restart the Flutter app
- Try clicking "Reveal Your Destiny" again
- Should complete in ~2-3 seconds

## Verification Commands

**Check if server is bound correctly:**
```powershell
netstat -an | Select-String "8001"
```

Should show:
```
TCP    0.0.0.0:8001           0.0.0.0:0              LISTENING
```

NOT:
```
TCP    127.0.0.1:8001         0.0.0.0:0              LISTENING
```

**Test decode endpoint from phone's IP perspective:**
```bash
curl http://192.168.100.197:8001/health
```

## Windows Firewall Note
If the phone still can't connect after fixing the binding, you may need to allow port 8001 through Windows Firewall:

```powershell
New-NetFirewallRule -DisplayName "Destiny Decoder API" -Direction Inbound -LocalPort 8001 -Protocol TCP -Action Allow
```
