#!/bin/bash
# Open Clara Dashboard in default browser

echo "🤖 Opening Clara Dashboard..."

WORKSPACE_DIR="/home/jeremygaul/.openclaw/workspace"
DASHBOARD_FILE="$WORKSPACE_DIR/dashboard/index.html"

if [[ -f "$DASHBOARD_FILE" ]]; then
    # Try different methods based on OS
    if command -v xdg-open > /dev/null 2>&1; then
        xdg-open "$DASHBOARD_FILE"
    elif command -v open > /dev/null 2>&1; then
        open "$DASHBOARD_FILE"
    elif command -v explorer.exe > /dev/null 2>&1; then
        # WSL
        explorer.exe "$DASHBOARD_FILE"
    else
        echo "Dashboard location: $DASHBOARD_FILE"
        echo "Please open this file in your browser manually."
    fi
    
    echo "✅ Dashboard opened!"
else
    echo "❌ Dashboard not found at: $DASHBOARD_FILE"
    exit 1
fi
