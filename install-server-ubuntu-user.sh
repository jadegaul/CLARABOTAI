#!/bin/bash
# Mission Control Server Setup Script for Ubuntu (User-level, no sudo required)

set -e

SERVER_DIR="$HOME/.mission-control"
NODE_PATH=$(which node)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Mission Control Server Setup for Ubuntu (User Service)"
echo "========================================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Installing..."
    sudo apt update && sudo apt install -y nodejs npm
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

# Create user systemd directory
mkdir -p "$HOME/.config/systemd/user"

# Create user service file
SERVICE_PATH="$HOME/.config/systemd/user/mission-control.service"
cat > "$SERVICE_PATH" << EOF
[Unit]
Description=Mission Control Server
After=network.target

[Service]
Type=simple
WorkingDirectory=$SERVER_DIR
ExecStart=$NODE_PATH $SERVER_DIR/server.js
Restart=always
RestartSec=10
StandardOutput=append:$SERVER_DIR/server.log
StandardError=append:$SERVER_DIR/server.error.log

[Install]
WantedBy=default.target
EOF

echo "✓ Created user service: $SERVICE_PATH"

# Enable and start the service
echo ""
echo "🔧 Enabling and starting service..."
systemctl --user daemon-reload
systemctl --user enable mission-control.service
systemctl --user start mission-control.service

sleep 2
if systemctl --user is-active --quiet mission-control; then
    echo "${GREEN}✓ Server is running!${NC}"
else
    echo "${YELLOW}⚠ Server may still be starting...${NC}"
fi

echo ""
echo "${GREEN}🎉 Mission Control Server installed!${NC}"
echo ""
echo "📍 Server directory: $SERVER_DIR"
echo "🌐 Dashboard URL: http://localhost:8899"
echo ""
echo "Commands (no sudo needed):"
echo "  Status:  systemctl --user status mission-control"
echo "  Start:   systemctl --user start mission-control"
echo "  Stop:    systemctl --user stop mission-control"
echo "  Restart: systemctl --user restart mission-control"
echo "  Logs:    journalctl --user -u mission-control -f"
echo ""
echo "To enable auto-start on login:"
echo "  sudo loginctl enable-linger $USER"
echo ""
echo "The server will auto-start when you log in (after enabling linger)."
echo ""
