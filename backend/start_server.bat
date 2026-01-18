@echo off
echo Starting Destiny Decoder Backend Server on 0.0.0.0:8001
echo This allows access from your phone at http://192.168.100.197:8001
echo.
echo Press Ctrl+C to stop the server
echo.
cd /d "%~dp0"
python -m uvicorn run_server:app --host 0.0.0.0 --port 8001 --reload
