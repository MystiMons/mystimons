# MystiMons Developer Workflow

## Quick Start

```powershell
# 1. Environment starten (öffnet /docs im Browser)
.\tools\dev.ps1 -Open

# 2. Arbeiten...

# 3. Changes committen + PR erstellen
.\tools\flow.ps1 -Branch feature/xyz -Message "feat: xyz" -Files @("path/to/file.md") -AutoPR -OpenPR
```

## Commands

### `dev.ps1` – Environment Management

```powershell
.\tools\dev.ps1              # Check tools, start server, show status
.\tools\dev.ps1 -Open        # + open /docs in browser
.\tools\dev.ps1 -Check       # Only check tools, don't start server
.\tools\dev.ps1 -Stop        # Stop server (safe - only Python processes)
.\tools\dev.ps1 -Stop -Force # Force stop any process on port
.\tools\dev.ps1 -Foreground  # Run server in this window (for debugging)
```

### `flow.ps1` – Git Workflow

```powershell
# Basic: commit + push
.\tools\flow.ps1 -Branch feature/name -Message "type: description" -Files @("file1.md", "file2.md")

# With PR creation
.\tools\flow.ps1 -Branch feature/name -Message "feat: add feature" -Files @("src/app.py") -AutoPR

# With PR creation + open in browser
.\tools\flow.ps1 -Branch feature/name -Message "fix: bug" -Files @("tools/dev.ps1") -AutoPR -OpenPR

# Dry run (no push)
.\tools\flow.ps1 -Branch test -Message "test" -Files @("README.md") -NoPush
```

## Default Port

Both scripts default to **port 8001** (not 8000).

If you need a different port:
```powershell
.\tools\dev.ps1 -Port 9000
.\tools\flow.ps1 -Port 9000 -Branch ... -Message ... -Files @(...)
```

## Troubleshooting

### "Port already in use" / Zombie Socket

If a port shows as used but `Stop-Process` fails:

```powershell
# Option A: Use different port (fastest)
.\tools\dev.ps1 -Port 8002

# Option B: Wait 30-60 seconds (Windows cleans up zombie sockets)
Start-Sleep -Seconds 45
.\tools\dev.ps1

# Option C: Check what's on the port
Get-NetTCPConnection -LocalPort 8001 -State Listen
```

### "Server running but for WRONG repo"

You have a server running for a different repository. Fix:

```powershell
.\tools\dev.ps1 -Stop -Force
.\tools\dev.ps1 -Open
```

### Scripts not running (Execution Policy)

```powershell
Unblock-File -Path .\tools\dev.ps1
Unblock-File -Path .\tools\flow.ps1
```

Or set policy for your user:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

## API Endpoints

When server is running (`http://127.0.0.1:8001`):

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check + repo info |
| GET | `/git/status` | Repository status |
| POST | `/git/push` | Push to remote |
| GET | `/docs` | Swagger API documentation |
| GET | `/artifact` | Read artifact |
| POST | `/artifact/write` | Write artifact |
| POST | `/validate/set` | Validate TCG set |
| POST | `/validate/all` | Validate all sets |

## Typical Session

```powershell
# Morning: Start environment
.\tools\dev.ps1 -Open

# Work on feature
# ... edit files ...

# Commit + PR
.\tools\flow.ps1 -Branch feature/chapter-1 -Message "feat: add chapter 1 draft" -Files @("02_NARRATIVE/book_01/CHAPTERS/CH01.md") -AutoPR -OpenPR

# More work...
.\tools\flow.ps1 -Branch feature/chapter-1 -Message "fix: typo in chapter 1" -Files @("02_NARRATIVE/book_01/CHAPTERS/CH01.md")
# (PR updates automatically)

# Evening: Stop server
.\tools\dev.ps1 -Stop
```
