# Database Setup Guide

## Overview

Destiny Decoder now uses a persistent database to store:
- Device FCM tokens for push notifications
- User notification preferences (types, quiet hours)

The database layer uses SQLAlchemy ORM and supports both SQLite (development) and PostgreSQL (production).

---

## Quick Start (Development with SQLite)

The default configuration uses SQLite, which requires no setup:

```bash
# 1. Install dependencies
pip install -r requirements.txt

# 2. Initialize database
python backend/init_db.py

# 3. Start the server
uvicorn backend.main:app --reload
```

The database file will be created at `backend/destiny_decoder.db`.

---

## Production Setup (PostgreSQL)

### 1. Install PostgreSQL

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

**macOS:**
```bash
brew install postgresql
brew services start postgresql
```

**Windows:**
Download and install from https://www.postgresql.org/download/windows/

### 2. Create Database

```bash
# Connect to PostgreSQL
sudo -u postgres psql

# Create database and user
CREATE DATABASE destiny_decoder;
CREATE USER destiny_user WITH PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE destiny_decoder TO destiny_user;
\q
```

### 3. Set Environment Variable

```bash
# Linux/macOS
export DATABASE_URL="postgresql://destiny_user:your_secure_password@localhost/destiny_decoder"

# Windows PowerShell
$env:DATABASE_URL="postgresql://destiny_user:your_secure_password@localhost/destiny_decoder"

# Or add to .env file
echo "DATABASE_URL=postgresql://destiny_user:your_secure_password@localhost/destiny_decoder" >> .env
```

### 4. Initialize Database

```bash
python backend/init_db.py
```

---

## Database Schema

### devices table
Stores FCM tokens for push notifications.

| Column | Type | Description |
|--------|------|-------------|
| device_id | VARCHAR(255) PK | Unique device identifier (UUID) |
| fcm_token | VARCHAR(500) UNIQUE | Firebase Cloud Messaging token |
| device_type | VARCHAR(50) | android, ios, or web |
| active | BOOLEAN | Token active status |
| created_at | DATETIME | Device registration time |
| last_active | DATETIME | Last activity timestamp |
| topics | VARCHAR(500) | Comma-separated topic subscriptions |

### notification_preferences table
Stores notification settings per device.

| Column | Type | Description |
|--------|------|-------------|
| device_id | VARCHAR(255) PK FK | References devices.device_id |
| blessed_day_alerts | BOOLEAN | Enable blessed day notifications |
| daily_insights | BOOLEAN | Enable daily insights |
| lunar_phase_alerts | BOOLEAN | Enable lunar phase updates |
| motivational_quotes | BOOLEAN | Enable motivational quotes |
| quiet_hours_enabled | BOOLEAN | Enable quiet hours |
| quiet_hours_start | VARCHAR(5) | Quiet hours start time (HH:MM) |
| quiet_hours_end | VARCHAR(5) | Quiet hours end time (HH:MM) |
| created_at | DATETIME | Preference creation time |
| updated_at | DATETIME | Last update timestamp |

---

## Migrations (Future)

For database schema changes, we'll use Alembic:

```bash
# Initialize Alembic (if not done)
alembic init alembic

# Create a migration
alembic revision --autogenerate -m "Add new field"

# Apply migration
alembic upgrade head

# Rollback
alembic downgrade -1
```

---

## Environment Variables

### DATABASE_URL Format

**SQLite (Development):**
```
sqlite:///./destiny_decoder.db
```

**PostgreSQL (Production):**
```
postgresql://username:password@hostname:port/database_name
```

**PostgreSQL (Heroku/Railway):**
```
postgresql://user:pass@host:5432/dbname?sslmode=require
```

---

## Troubleshooting

### "FATAL: database does not exist"
Run `createdb destiny_decoder` or use the SQL commands above.

### "FATAL: password authentication failed"
Check your DATABASE_URL and ensure the password is correct.

### "connection to server failed"
Ensure PostgreSQL is running: `sudo service postgresql status`

### SQLite locked errors
Make sure only one process is accessing the database at a time.

### Migration conflicts
Reset database: `python backend/init_db.py` (WARNING: This drops all data)

---

## Health Check

Verify database connection:

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "database": "connected",
  "services": {
    "api": "running",
    "firebase": "initialized",
    "scheduler": "running"
  }
}
```

---

## Backup & Restore

### SQLite
```bash
# Backup
cp destiny_decoder.db destiny_decoder_backup_$(date +%Y%m%d).db

# Restore
cp destiny_decoder_backup_20260118.db destiny_decoder.db
```

### PostgreSQL
```bash
# Backup
pg_dump destiny_decoder > backup_$(date +%Y%m%d).sql

# Restore
psql destiny_decoder < backup_20260118.sql
```

---

## Next Steps

1. **Test the setup**: Start the server and register a test device
2. **Verify persistence**: Restart the server and check preferences are saved
3. **Monitor logs**: Watch for database connection issues
4. **Production**: Switch to PostgreSQL before deploying

---

## Support

For issues, check logs in the terminal where the server is running.
The application will log database connection status on startup.
