#!/bin/bash
# Daily backup of Clara workspace to GitHub
# Auto-commits with sanitized data (no API keys, passwords, or tokens)

set -e

REPO_OWNER="jadegaul"
REPO_NAME="CLARABOTAI"
REPO_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}"
WORKSPACE_DIR="/home/jeremygaul/.openclaw/workspace"
BACKUP_DIR="${HOME}/.clara-backup-repo"
DATE=$(date +%Y-%m-%d)
TIME=$(date +%H:%M:%S)

echo "=== Clara Daily Backup - ${DATE} ${TIME} ==="

# Clone or update the backup repository
if [ ! -d "$BACKUP_DIR/.git" ]; then
    echo "Cloning backup repository..."
    rm -rf "$BACKUP_DIR"
    git clone "$REPO_URL" "$BACKUP_DIR" 2>/dev/null || {
        echo "Repo may not exist or need auth. Creating fresh backup dir..."
        mkdir -p "$BACKUP_DIR"
        cd "$BACKUP_DIR"
        git init
        git remote add origin "$REPO_URL" 2>/dev/null || true
    }
fi

cd "$BACKUP_DIR"

# Pull latest changes first
git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || echo "No remote branches yet"

# Clear old backup files but keep .git
echo "Clearing old backup files..."
find . -mindepth 1 -not -path './.git/*' -not -name '.git' -delete 2>/dev/null || true

# Copy workspace contents
echo "Copying workspace files..."
cp -r "$WORKSPACE_DIR"/* . 2>/dev/null || true
cp -r "$WORKSPACE_DIR"/.* . 2>/dev/null || true

# Explicitly ensure critical files are backed up
echo "Verifying critical files..."
# Session state
if [ -f "$WORKSPACE_DIR/SESSION-STATE.md" ]; then
    cp "$WORKSPACE_DIR/SESSION-STATE.md" . 2>/dev/null || true
    echo "  ✓ SESSION-STATE.md"
fi

# Daily notes
if [ -d "$WORKSPACE_DIR/memory" ]; then
    mkdir -p memory
    cp -r "$WORKSPACE_DIR/memory"/* memory/ 2>/dev/null || true
    NOTE_COUNT=$(ls memory/ 2>/dev/null | wc -l)
    echo "  ✓ Daily notes: $NOTE_COUNT files"
fi

# Remove sensitive files/directories
echo "Removing sensitive files..."
# Remove common sensitive directories
rm -rf .bashrc .config .npm-global .local .cache .ssh 2>/dev/null || true

# Remove directories containing secrets (OAuth tokens, session data, etc.)
rm -rf agents/ 2>/dev/null || true
rm -rf browser/ 2>/dev/null || true  
rm -rf media/inbound/ 2>/dev/null || true
rm -rf identity/ 2>/dev/null || true
rm -rf credentials/ 2>/dev/null || true
rm -rf cron/runs/ 2>/dev/null || true

# Remove large files that exceed GitHub's 100MB limit
find . -type f -size +50M -delete 2>/dev/null || true

# Remove session transcripts (they grow large)
find . -name "*.jsonl" -delete 2>/dev/null || true
find . -name "transcript*" -delete 2>/dev/null || true

find . -name "*.key" -delete 2>/dev/null || true
find . -name "*.pem" -delete 2>/dev/null || true
find . -name "*token*" -delete 2>/dev/null || true
find . -name "*password*" -delete 2>/dev/null || true
find . -name "*secret*" -delete 2>/dev/null || true
find . -name ".env*" -delete 2>/dev/null || true
find . -name "*api-key*" -delete 2>/dev/null || true

# Sanitize content in files
echo "Sanitizing file contents..."
find . -type f \( -name "*.md" -o -name "*.json" -o -name "*.txt" -o -name "*.sh" -o -name "*.py" \) -print0 2>/dev/null | while IFS= read -r -d '' file; do
    # Skip binary files
    if file "$file" | grep -q "text"; then
        # Redact common sensitive patterns
        sed -i \
            -e 's/pk_[a-zA-Z0-9_-]\{20,\}/[REDACTED]/g' \
            -e 's/sk-[a-zA-Z0-9]\{40,\}/[REDACTED]/g' \
            -e 's/"password"[[:space:]]*:[[:space:]]*"[^"]*"/"password": "[REDACTED]"/g' \
            -e 's/password[[:space:]]*=[[:space:]]*[^[:space:]]*/password = [REDACTED] \
            -e 's/token[[:space:]]*=[[:space:]]*[^[:space:]]*/token = [REDACTED] \
            -e 's/api_key[[:space:]]*=[[:space:]]*[^[:space:]]*/api_key = [REDACTED] \
            -e 's/[REDACTED]/[REDACTED]/g' \
            -e 's/[0-9a-f]\{8\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{4\}-[0-9a-f]\{12\}/[UUID-REDACTED]/g' \
            "$file" 2>/dev/null || true
    fi
done

# Configure git
git config user.email "clara@openclaw.local" 2>/dev/null || true
git config user.name "Clara Backup Bot" 2>/dev/null || true

# Add all files
git add -A

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "No changes to backup."
    exit 0
fi

# Commit
COMMIT_MSG="Backup: ${DATE} ${TIME}

Automated daily backup of Clara workspace.

Included:
- ✓ SESSION-STATE.md (current session context)
- ✓ memory/*.md (${NOTE_COUNT:-0} daily notes)
- ✓ Configuration files (sanitized)
- ✓ Skills and scripts
- ✓ TOOLS.md, USER.md, SOUL.md, MEMORY.md

Sensitive data (API keys, passwords, tokens) has been redacted."

# Count daily notes if not already set
NOTE_COUNT=$(ls memory/ 2>/dev/null | wc -l)
export NOTE_COUNT

git commit -m "$COMMIT_MSG"

# Push
echo "Pushing to GitHub..."
git push origin HEAD:main 2>/dev/null || git push origin HEAD:master 2>/dev/null || {
    echo "Push failed. May need to setup upstream or authentication."
    exit 1
}

echo "=== Backup Complete ==="
echo "Pushed to: ${REPO_URL}"
echo "Timestamp: ${DATE} ${TIME}"
