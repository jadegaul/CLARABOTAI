#!/bin/bash
# Mission Control Server Setup Script for macOS

set -e

SERVER_DIR="$HOME/.mission-control"
NODE_PATH=$(which node)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "🚀 Mission Control Server Setup"
echo "================================"
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install it first:"
    echo "   brew install node"
    exit 1
fi

echo "✓ Node.js found: $(node --version)"

# Create server directory
mkdir -p "$SERVER_DIR"
echo "✓ Created directory: $SERVER_DIR"

# Copy server files
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cp "$SCRIPT_DIR/server.js" "$SERVER_DIR/"
echo "✓ Installed server.js"

# Also copy mission-control.html if it exists in the same directory
if [ -f "$SCRIPT_DIR/mission-control.html" ]; then
    cp "$SCRIPT_DIR/mission-control.html" "$SERVER_DIR/"
    echo "✓ Installed mission-control.html"
fi

# Create LaunchAgent plist
PLIST_PATH="$HOME/Library/LaunchAgents/com.missioncontrol.server.plist"
sed "s|SERVER_PATH|$SERVER_DIR|g" "$SCRIPT_DIR/com.missioncontrol.server.plist" > "$PLIST_PATH"
sed -i '' "s|/usr/local/bin/node|$NODE_PATH|g" "$PLIST_PATH"
echo "✓ Created LaunchAgent: $PLIST_PATH"

# Load the LaunchAgent
launchctl load "$PLIST_PATH" 2>/dev/null || launchctl bootstrap gui/$(id -u) "$PLIST_PATH"
echo "✓ LaunchAgent loaded"

echo ""
echo "${GREEN}🎉 Mission Control Server installed!${NC}"
echo ""
echo "📍 Server directory: $SERVER_DIR"
echo "🌐 Dashboard URL: http://localhost:8899"
echo ""
echo "Commands:"
echo "  Start:  launchctl start com.missioncontrol.server"
echo "  Stop:   launchctl stop com.missioncontrol.server"
echo "  Logs:   tail -f $SERVER_DIR/server.log"
echo ""
echo "The server will auto-start on login."
echo ""
