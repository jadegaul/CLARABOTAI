#!/bin/bash
# OpenClaw Cron Runner - Runs every minute via system cron
# Checks if OpenClaw cron jobs are due and triggers them

export PATH="/home/jeremygaul/.npm-global/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export OPENCLAW_GATEWAY_URL="http://127.0.0.1:18789"
export OPENCLAW_GATEWAY_TOKEN="11044fb46152c915f389bcb91f14816ac3362717d7d119f6"

LOG_FILE="/tmp/openclaw-cron-runner.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')
NOW_MS=$(date +%s000)

echo "[$DATE] Checking OpenClaw cron jobs..." >> "$LOG_FILE"

# Get cron status and check next wake time
CRON_STATUS=$(openclaw cron status 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "[$DATE] Failed to get cron status" >> "$LOG_FILE"
    exit 1
fi

# Get next wake time
NEXT_WAKE=$(echo "$CRON_STATUS" | grep -oP '"nextWakeAtMs":\s*\K[0-9]+')

if [ -z "$NEXT_WAKE" ]; then
    echo "[$DATE] No next wake time found" >> "$LOG_FILE"
    exit 0
fi

# Check if it's time to run (within 1 minute window)
# If nextWakeAtMs <= now, jobs are due
if [ "$NEXT_WAKE" -le "$NOW_MS" ]; then
    echo "[$DATE] Jobs are due! Next wake: $NEXT_WAKE, Now: $NOW_MS" >> "$LOG_FILE"
    
    # Send wake event to trigger jobs
    openclaw cron wake --mode now 2>&1 >> "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        echo "[$DATE] Wake event sent successfully" >> "$LOG_FILE"
    else
        echo "[$DATE] Failed to send wake event" >> "$LOG_FILE"
    fi
else
    # Calculate minutes until next wake
    DIFF=$(( (NEXT_WAKE - NOW_MS) / 60000 ))
    echo "[$DATE] No jobs due. Next wake in ~${DIFF}min" >> "$LOG_FILE"
fi

echo "[$DATE] Cron runner complete." >> "$LOG_FILE"
