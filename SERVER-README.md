# 🚀 Mission Control Server

A lightweight local server to power your Mission Control dashboard with live data.

## Features

- ⚡ **Lightweight** - Pure Node.js, no heavy frameworks
- 🔌 **REST API** - Full CRUD for dashboard data
- 🌤️ **Weather** - Live weather via wttr.in
- 📝 **Activity Log** - Track recent actions
- 🔄 **Auto-sync** - Backup localStorage to server
- 🍎 **Auto-start** - macOS LaunchAgent for login startup

## Quick Start

### macOS

```bash
# Navigate to your Mission Control folder
cd ~/.openclaw/workspace

# Make install script executable
chmod +x install-server.sh

# Run the installer
./install-server.sh
```

### Ubuntu/Linux (User Service - Recommended)

```bash
# Navigate to your Mission Control folder
cd ~/.openclaw/workspace

# Make install script executable
chmod +x install-server-ubuntu-user.sh

# Run the installer (no sudo required)
./install-server-ubuntu-user.sh

# Enable auto-start on login (run once)
sudo loginctl enable-linger $(whoami)
```

### Ubuntu/Linux (System Service)

```bash
# Navigate to your Mission Control folder
cd ~/.openclaw/workspace

# Make install script executable
chmod +x install-server-ubuntu.sh

# Run the installer (requires sudo for system service)
./install-server-ubuntu.sh
```

### 2. Manual Setup (Alternative)

If you prefer manual setup:

```bash
# 1. Save server.js to a folder
mkdir -p ~/.mission-control
cp server.js ~/.mission-control/

# 2. Run the server
cd ~/.mission-control
node server.js

# 3. Open the dashboard
open http://localhost:8899
```

### 3. Install Auto-Start

**macOS:**
```bash
# Copy the plist to LaunchAgents
cp com.missioncontrol.server.plist ~/Library/LaunchAgents/

# Edit it to point to your server directory
# Replace SERVER_PATH with actual path: /Users/YOURNAME/.mission-control

# Load the LaunchAgent
launchctl load ~/Library/LaunchAgents/com.missioncontrol.server.plist

# Or use the install script which does this automatically:
./install-server.sh
```

**Ubuntu (User Service):**
```bash
# Copy service file
mkdir -p ~/.config/systemd/user
cp mission-control.service ~/.config/systemd/user/

# Edit to set correct paths
sed -i "s|SERVER_PATH|$HOME/.mission-control|g" ~/.config/systemd/user/mission-control.service
sed -i "s|USERNAME|$USER|g" ~/.config/systemd/user/mission-control.service

# Enable and start
systemctl --user daemon-reload
systemctl --user enable mission-control
systemctl --user start mission-control

# Enable auto-start on login (run once with sudo)
sudo loginctl enable-linger $USER
```

**Ubuntu (System Service):**
```bash
# Copy service file (requires sudo)
sudo cp mission-control.service /etc/systemd/system/

# Edit to set correct paths
sudo sed -i "s|SERVER_PATH|$HOME/.mission-control|g" /etc/systemd/system/mission-control.service
sudo sed -i "s|USERNAME|$USER|g" /etc/systemd/system/mission-control.service

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable mission-control
sudo systemctl start mission-control
```

## API Endpoints

### GET /mc/status
Returns server health and uptime.

```json
{
  "status": "online",
  "uptime": 3600,
  "uptime_formatted": "1h 0m 0s",
  "last_data_refresh": "2026-02-20T16:30:00.000Z",
  "port": 8899,
  "version": "1.0.0"
}
```

### GET /mc/data
Returns all dashboard data from `mc-data.json`.

### POST /mc/data
Save dashboard data (sync localStorage to server).

```bash
curl -X POST http://localhost:8899/mc/data \
  -H "Content-Type: application/json" \
  -d '{"revenueGoal": 15000, "clients": [...]}'
```

Response:
```json
{
  "success": true,
  "timestamp": "2026-02-20T16:30:00.000Z"
}
```

### GET /mc/weather?city=Portland
Fetch current weather for any city.

```json
{
  "temperature": "72",
  "condition": "Sunny",
  "feels_like": "74",
  "humidity": "45",
  "city": "Portland"
}
```

### GET /mc/activity
Returns last 50 activity entries.

```json
{
  "entries": [
    {
      "id": "abc123",
      "text": "Added new client",
      "type": "revenue",
      "icon": "💰",
      "timestamp": "2026-02-20T16:30:00.000Z"
    }
  ],
  "total": 127
}
```

### POST /mc/activity
Add a new activity entry.

```bash
curl -X POST http://localhost:8899/mc/activity \
  -H "Content-Type: application/json" \
  -d '{"text": "Completed milestone", "type": "milestone", "icon": "✅"}'
```

## Mission Control Integration

Add this JavaScript to your Mission Control dashboard to sync with the server:

```javascript
// Sync localStorage to server every 30 seconds
setInterval(syncToServer, 30000);

async function syncToServer() {
  const data = {
    priorities: AppState.priorities,
    activities: AppState.activities,
    notes: AppState.notes,
    income: AppState.income,
    tasks: AppState.tasks,
    milestones: AppState.milestones,
    clients: AppState.clients,
    revenueGoal: AppState.revenueGoal,
    agents: AppState.agents,
    decisions: AppState.decisions,
    videoIdeas: AppState.videoIdeas,
    youtubeStats: AppState.youtubeStats,
    meetings: AppState.meetings,
    intelItems: AppState.intelItems
  };
  
  try {
    await fetch('http://localhost:8899/mc/data', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
    });
    console.log('✓ Synced to server');
  } catch (err) {
    console.log('Sync failed:', err.message);
  }
}

// Fetch weather on dashboard load
async function loadWeather(city = 'Portland') {
  try {
    const res = await fetch(`http://localhost:8899/mc/weather?city=${city}`);
    const weather = await res.json();
    document.getElementById('weatherDisplay').textContent = 
      `${weather.temperature}°F ${weather.condition}`;
  } catch (err) {
    console.log('Weather fetch failed:', err.message);
  }
}
```

## File Structure

```
~/.mission-control/
├── server.js              # The server
├── mc-data.json           # Dashboard state backup
├── mc-activity.json       # Activity log
├── server.log             # Server output log
└── server.error.log       # Error log
```

## Commands

### Manual
```bash
# Start server manually
node server.js
```

### macOS (LaunchAgent)
```bash
# Stop server
launchctl stop com.missioncontrol.server

# Start server
launchctl start com.missioncontrol.server

# View logs
tail -f ~/.mission-control/server.log

# Uninstall auto-start
launchctl unload ~/Library/LaunchAgents/com.missioncontrol.server.plist
rm ~/Library/LaunchAgents/com.missioncontrol.server.plist
```

### Ubuntu (User Service)
```bash
# Stop server
systemctl --user stop mission-control

# Start server
systemctl --user start mission-control

# Restart server
systemctl --user restart mission-control

# View logs
journalctl --user -u mission-control -f

# Check status
systemctl --user status mission-control

# Uninstall auto-start
systemctl --user disable mission-control
rm ~/.config/systemd/user/mission-control.service
systemctl --user daemon-reload
```

### Ubuntu (System Service)
```bash
# Stop server
sudo systemctl stop mission-control

# Start server
sudo systemctl start mission-control

# Restart server
sudo systemctl restart mission-control

# View logs
sudo journalctl -u mission-control -f

# Check status
sudo systemctl status mission-control

# Uninstall auto-start
sudo systemctl disable mission-control
sudo rm /etc/systemd/system/mission-control.service
sudo systemctl daemon-reload
```

## Troubleshooting

### Port 8899 is in use
```bash
# Find what's using the port
lsof -i :8899

# Kill the process
kill -9 <PID>
```

### Server won't start
Check the error log:
```bash
cat ~/.mission-control/server.error.log
```

### Node.js not found
**macOS:**
```bash
brew install node
```

**Ubuntu:**
```bash
sudo apt update
sudo apt install -y nodejs npm
```

## Customization

Edit `server.js` to change:
- Port number (default: 8899)
- Data file locations
- Weather default city
- CORS settings

---

Built for Mission Control Dashboard 🚀
