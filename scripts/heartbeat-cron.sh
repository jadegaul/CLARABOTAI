#!/bin/bash
# OpenClaw Heartbeat Script - Runs every minute via system cron
# Checks Kanban board, calendar, and reports status

export CLICKUP_API_TOKEN="[REDACTED]"
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/jeremygaul/.npm-global/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

LOG_FILE="/tmp/openclaw-heartbeat.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Heartbeat starting..." >> "$LOG_FILE"

# Change to workspace directory
cd /home/jeremygaul/.openclaw/workspace || exit 1

# Check Kanban board for tasks
TASKS=$(python3 skills/clickup-skill/scripts/clickup_client.py get_tasks list_id="901710515957" 2>/tmp/clickup-error.log)
if [ -z "$TASKS" ]; then
    TASK_COUNT=0
    echo "[$DATE] ClickUp API error - check /tmp/clickup-error.log" >> "$LOG_FILE"
else
    TASK_COUNT=$(echo "$TASKS" | grep -c '"name":' 2>/dev/null)
    TASK_COUNT=${TASK_COUNT:-0}
fi

# Check calendar for today and tomorrow
TODAY=$(date -I)
TOMORROW=$(date -I -d '+1 day')
CALENDAR_EVENTS=$(gog calendar events jeremylgaul@gmail.com --from "$TODAY" --to "$TOMORROW" 2>/dev/null || echo "")
EVENT_COUNT=$(echo "$CALENDAR_EVENTS" | grep -c "Title:" 2>/dev/null)
EVENT_COUNT=${EVENT_COUNT:-0}

# Log results
echo "[$DATE] Tasks: $TASK_COUNT, Events: $EVENT_COUNT" >> "$LOG_FILE"

# Only send Telegram message if there are new tasks or upcoming events
# This prevents spam - you can adjust the logic as needed
if [ "$TASK_COUNT" -gt 0 ] || [ "$EVENT_COUNT" -gt 0 ]; then
    # Use openclaw CLI to send a message
    # For now, just log it - you can uncomment the line below when ready to enable notifications
    echo "[$DATE] Would notify: $TASK_COUNT tasks, $EVENT_COUNT events" >> "$LOG_FILE"
    # openclaw message send --channel telegram --target "7152537300" "📊 Heartbeat: $TASK_COUNT tasks on board, $EVENT_COUNT events upcoming"
fi

echo "[$DATE] Heartbeat complete." >> "$LOG_FILE"
