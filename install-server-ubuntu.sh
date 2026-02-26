#!/bin/bash
# Mission Control Server Setup Script for Ubuntu/Linux

set -e

SERVER_DIR="$HOME/.mission-control"
NODE_PATH=$(which node)
USERNAME=$(whoami)

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Mission Control Server Setup for Ubuntu"
echo "=========================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Installing..."
    echo "   Run: sudo apt update && sudo apt install -y nodejs npm"
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

# Create systemd service file
SERVICE_PATH="/tmp/mission-control.service"
sed "s|SERVER_PATH|$SERVER_DIR|g" "$SCRIPT_DIR/mission-control.service" > "$SERVICE_PATH"
sed -i "s|USERNAME|$USERNAME|g" "$SERVICE_PATH"
sed -i "s|/usr/bin/node|$NODE_PATH|g" "$SERVICE_PATH"

# Install the service
echo ""
echo "🔧 Installing systemd service..."
sudo cp "$SERVICE_PATH" /etc/systemd/system/mission-control.service
sudo systemctl daemon-reload
sudo systemctl enable mission-control.service
sudo systemctl start mission-control.service

echo "✓ Service installed and started"

# Check status
sleep 2
if sudo systemctl is-active --quiet mission-control; then
    echo "${GREEN}✓ Server is running!${NC}"
else
    echo "${YELLOW}⚠ Server status unknown - check logs with: sudo journalctl -u mission-control${NC}"
fi

echo ""
echo "${GREEN}🎉 Mission Control Server installed!${NC}"
echo ""
echo "📍 Server directory: $SERVER_DIR"
echo "🌐 Dashboard URL: http://localhost:8899"
echo ""
echo "Commands:"
echo "  Status:  sudo systemctl status mission-control"
echo "  Start:   sudo systemctl start mission-control"
echo "  Stop:    sudo systemctl stop mission-control"
echo "  Restart: sudo systemctl restart mission-control"
echo "  Logs:    sudo journalctl -u mission-control -f"
echo ""
echo "The server will auto-start on boot."
echo ""
