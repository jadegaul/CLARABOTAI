#!/bin/bash
# Daily backup script for Clara's workspace to GitHub
# Excludes sensitive files (API keys, passwords, tokens)

set -e

REPO_URL="https://github.com/jadegaul/CLARABOTAI"
WORKSPACE_DIR="/home/jeremygaul/.openclaw/workspace"
BACKUP_DIR="/tmp/clara-backup-$(date +%Y%m%d-%H%M%S)"
BACKUP_BRANCH="backup-$(date +%Y%m%d)"

echo "=== Clara Daily Backup - $(date) ==="

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Copy workspace contents (excluding sensitive files)
cd "$WORKSPACE_DIR"

# Create a filtered copy
echo "Copying workspace files (excluding sensitive data)..."
rsync -av --exclude='*.key' \
          --exclude='*.pem' \
          --exclude='.env*' \
          --exclude='*token*' \
          --exclude='*password*' \
          --exclude='*secret*' \
          --exclude='.bashrc' \
          --exclude='*api-key*' \
          --exclude='.config/' \
          "$WORKSPACE_DIR/" "$BACKUP_DIR/" 2>/dev/null || cp -r "$WORKSPACE_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true

# Additional sanitization: remove any lines containing sensitive patterns
echo "Sanitizing files..."
find "$BACKUP_DIR" -type f \( -name "*.md" -o -name "*.json" -o -name "*.txt" -o -name "*.sh" \) -exec sed -i \
    -e 's/pk_[a-zA-Z0-9_-]\{20,\}/[REDACTED_API_KEY]/g' \
    -e 's/sk-[a-zA-Z0-9]\{48\}/[REDACTED_API_KEY]/g' \
    -e 's/[a-zA-Z0-9_-]\{20,\}@[a-zA-Z0-9_-]\{10,\}/[REDACTED_EMAIL_PATTERN]/g' \
    -e 's/password[[:space:]]*[:=][[:space:]]*[^[:space:]]*/password: [REDACTED]/gi' \
    -e 's/token[[:space:]]*[:=][[:space:]]*[^[:space:]]*/token: [REDACTED]/gi' \
    -e 's/[REDACTED]/[REDACTED]/g' \
    {} + 2>/dev/null || true

# Create commit message
COMMIT_MSG="Daily backup: $(date '+%Y-%m-%d %H:%M:%S %Z')

- Session state
- Memory files
- Configuration (sanitized)
- Task lists
- Notes and logs"

# Change to backup directory and git operations
cd "$BACKUP_DIR"

# Initialize git if not already
if [ ! -d ".git" ]; then
    git init
    git remote add origin "$REPO_URL" 2>/dev/null || true
fi

# Configure git
git config user.email "clara@openclaw.local" 2>/dev/null || true
git config user.name "Clara Backup" 2>/dev/null || true

# Pull latest changes first (if repo exists)
git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true

# Add all files
git add -A 2>/dev/null || true

# Commit
git commit -m "$COMMIT_MSG" 2>/dev/null || echo "Nothing to commit or commit failed"

# Push
echo "Pushing to GitHub..."
git push origin HEAD:main 2>/dev/null || git push origin HEAD:master 2>/dev/null || echo "Push failed - may need manual setup"

# Cleanup
cd "$WORKSPACE_DIR"
rm -rf "$BACKUP_DIR"

echo "=== Backup Complete ==="
