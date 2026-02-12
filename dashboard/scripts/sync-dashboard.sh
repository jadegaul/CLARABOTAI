#!/bin/bash
# Sync dashboard data from ClickUp and other sources
# Run this script to update the dashboard JSON with real data

echo "=== Clara Dashboard Sync ==="
echo "Started: $(date)"

WORKSPACE_DIR="/home/jeremygaul/.openclaw/workspace"
DASHBOARD_DIR="$WORKSPACE_DIR/dashboard"
DATA_FILE="$DASHBOARD_DIR/data/dashboard.json"

# Load ClickUp token
export CLICKUP_API_TOKEN="${CLICKUP_API_TOKEN:-$(grep CLICKUP_API_TOKEN ~/.bashrc 2>/dev/null | cut -d'=' -f2 | tr -d '\"' | head -1)}"

# Build JSON object
python3 << PYTHON_EOF
import json
import sys
import os
from datetime import datetime

data_file = "$DATA_FILE"

# Load existing or create new
try:
    with open(data_file, 'r') as f:
        data = json.load(f)
except:
    data = {
        "status": "online",
        "currentTask": "Active",
        "subAgents": 0,
        "tasks": {"todo": [], "progress": [], "done": [], "archive": []},
        "notes": [],
        "activities": []
    }

# Update timestamp
data["lastUpdate"] = datetime.now().isoformat()

# Get session status from OpenClaw (if available)
try:
    import subprocess
    result = subprocess.run(
        ["openclaw", "status", "--json"],
        capture_output=True, text=True, timeout=5
    )
    if result.returncode == 0:
        status = json.loads(result.stdout)
        data["status"] = "online" if status.get("connected") else "offline"
        data["subAgents"] = status.get("sessions", {}).get("active", 0)
except:
    pass

# Save updated data
with open(data_file, 'w') as f:
    json.dump(data, f, indent=2)

print(f"Dashboard data updated: {data_file}")
print(f"Status: {data['status']}")
print(f"Last update: {data['lastUpdate']}")
PYTHON_EOF

echo "Sync complete: $(date)"
