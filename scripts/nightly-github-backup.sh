#!/bin/bash
# Nightly Clawbot Backup to GitHub
# Runs at 5:00 AM daily

export PATH="/home/jeremygaul/.npm-global/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

REPO_URL="https://github.com/jeremygaul/CLARABOTAI.git"
BACKUP_DIR="/tmp/clawbot-nightly-backup"
LOG_FILE="/tmp/clawbot-backup.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting nightly backup..." >> "$LOG_FILE"

# Clean up old backup dir and clone fresh
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

# Clone the repo
if ! gh repo clone jeremygaul/CLARABOTAI "$BACKUP_DIR" 2>&1 >> "$LOG_FILE"; then
    echo "[$DATE] Failed to clone repo" >> "$LOG_FILE"
    exit 1
fi

cd "$BACKUP_DIR" || exit 1

# Configure git
git config user.email "me@jadegaul.com"
git config user.name "Jade Gaul"
gh auth setup-git

# Create workspace directory if it doesn't exist
mkdir -p workspace

# Copy updated files
cp ~/.openclaw/workspace/SOUL.md workspace/ 2>/dev/null
cp ~/.openclaw/workspace/USER.md workspace/ 2>/dev/null
cp ~/.openclaw/workspace/AGENTS.md workspace/ 2>/dev/null
cp ~/.openclaw/workspace/TOOLS.md workspace/ 2>/dev/null
cp ~/.openclaw/workspace/HEARTBEAT.md workspace/ 2>/dev/null
cp ~/.openclaw/workspace/IDENTITY.md workspace/ 2>/dev/null

# Check if there are changes
if git diff --quiet && git diff --staged --quiet; then
    echo "[$DATE] No changes to backup" >> "$LOG_FILE"
    rm -rf "$BACKUP_DIR"
    exit 0
fi

# Add, commit, and push
git add .
git commit -m "Nightly backup - $DATE" 2>&1 >> "$LOG_FILE"

if git push origin main 2>&1 >> "$LOG_FILE"; then
    echo "[$DATE] Backup completed successfully" >> "$LOG_FILE"
else
    echo "[$DATE] Backup failed - push error" >> "$LOG_FILE"
fi

# Clean up
rm -rf "$BACKUP_DIR"
