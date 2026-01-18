# Start Destiny Decoder Backend Server
# Binds to 0.0.0.0:8001 to allow phone connections

Write-Host "Starting Destiny Decoder Backend Server" -ForegroundColor Green
Write-Host "Server will be accessible at:" -ForegroundColor Cyan
Write-Host "  - Local: http://localhost:8001" -ForegroundColor Yellow
Write-Host "  - Network: http://192.168.100.197:8001" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Gray
Write-Host ""

Set-Location $PSScriptRoot
python -m uvicorn run_server:app --host 0.0.0.0 --port 8001 --reload
