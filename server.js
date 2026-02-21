#!/usr/bin/env node
/**
 * Mission Control Server
 * Lightweight local server for the Mission Control dashboard
 * Port: 8899
 */

const http = require('http');
const fs = require('fs').promises;
const path = require('path');
const { existsSync } = require('fs');

// Configuration
const PORT = 8899;
const DATA_FILE = path.join(__dirname, 'mc-data.json');
const ACTIVITY_FILE = path.join(__dirname, 'mc-activity.json');

// Find mission-control.html in multiple possible locations
function findHtmlFile() {
  const possiblePaths = [
    path.join(__dirname, 'mission-control.html'),
    path.join(__dirname, '..', 'workspace', 'mission-control.html'),
    path.join(process.env.HOME, '.openclaw', 'workspace', 'mission-control.html'),
    path.join(process.cwd(), 'mission-control.html'),
    '/home/jeremygaul/.openclaw/workspace/mission-control.html'
  ];
  
  for (const p of possiblePaths) {
    if (existsSync(p)) {
      console.log('✓ Found mission-control.html at:', p);
      return p;
    }
  }
  return possiblePaths[0]; // Default to first path even if not found
}

const HTML_FILE = findHtmlFile();

// Server start time
const START_TIME = Date.now();

// Ensure data files exist
async function initDataFiles() {
  const defaultData = {
    priorities: [],
    activities: [],
    notes: '',
    income: 0,
    tasks: [],
    milestones: {},
    clients: [],
    revenueGoal: 10000,
    revenueHistory: [],
    agents: [],
    decisions: [],
    videoIdeas: [],
    youtubeStats: { subscriberCount: 0, totalViews: 0, videosPublished: 0 },
    meetings: [],
    intelItems: [],
    lastSync: null
  };

  const defaultActivity = { entries: [] };

  try {
    if (!existsSync(DATA_FILE)) {
      await fs.writeFile(DATA_FILE, JSON.stringify(defaultData, null, 2));
      console.log('✓ Created mc-data.json');
    }
    if (!existsSync(ACTIVITY_FILE)) {
      await fs.writeFile(ACTIVITY_FILE, JSON.stringify(defaultActivity, null, 2));
      console.log('✓ Created mc-activity.json');
    }
  } catch (err) {
    console.error('Error initializing data files:', err.message);
  }
}

// CORS Headers
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Content-Type': 'application/json'
};

// Parse JSON body
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (err) {
        reject(err);
      }
    });
  });
}

// Fetch weather from wttr.in
async function getWeather(city) {
  try {
    const https = require('https');
    const url = `https://wttr.in/${encodeURIComponent(city)}?format=j1`;
    
    return new Promise((resolve, reject) => {
      https.get(url, { timeout: 5000 }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const parsed = JSON.parse(data);
            const current = parsed.current_condition[0];
            resolve({
              temperature: current.temp_F,
              condition: current.weatherDesc[0].value,
              feels_like: current.FeelsLikeF,
              humidity: current.humidity,
              city: city
            });
          } catch (err) {
            reject(new Error('Failed to parse weather data'));
          }
        });
      }).on('error', reject).on('timeout', () => reject(new Error('Weather request timeout')));
    });
  } catch (err) {
    throw new Error(`Weather fetch failed: ${err.message}`);
  }
}

// Request handler
async function handleRequest(req, res) {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const pathname = url.pathname;
  const method = req.method;

  console.log(`${new Date().toISOString()} ${method} ${pathname}`);

  // CORS preflight
  if (method === 'OPTIONS') {
    res.writeHead(204, CORS_HEADERS);
    return res.end();
  }

  // Serve HTML at root
  if (pathname === '/' && method === 'GET') {
    try {
      const html = await fs.readFile(HTML_FILE, 'utf8');
      res.writeHead(200, { 'Content-Type': 'text/html' });
      return res.end(html);
    } catch (err) {
      res.writeHead(404, CORS_HEADERS);
      return res.end(JSON.stringify({ error: 'mission-control.html not found' }));
    }
  }

  // API: GET /mc/status
  if (pathname === '/mc/status' && method === 'GET') {
    const stats = await fs.stat(DATA_FILE).catch(() => ({ mtime: new Date(0) }));
    res.writeHead(200, CORS_HEADERS);
    return res.end(JSON.stringify({
      status: 'online',
      uptime: Math.floor((Date.now() - START_TIME) / 1000),
      uptime_formatted: formatUptime(Date.now() - START_TIME),
      last_data_refresh: stats.mtime.toISOString(),
      port: PORT,
      version: '1.0.0'
    }));
  }

  // API: GET /mc/data
  if (pathname === '/mc/data' && method === 'GET') {
    try {
      const data = await fs.readFile(DATA_FILE, 'utf8');
      res.writeHead(200, CORS_HEADERS);
      return res.end(data);
    } catch (err) {
      res.writeHead(500, CORS_HEADERS);
      return res.end(JSON.stringify({ error: 'Failed to read data file' }));
    }
  }

  // API: POST /mc/data
  if (pathname === '/mc/data' && method === 'POST') {
    try {
      const body = await parseBody(req);
      body.lastSync = new Date().toISOString();
      await fs.writeFile(DATA_FILE, JSON.stringify(body, null, 2));
      res.writeHead(200, CORS_HEADERS);
      return res.end(JSON.stringify({ success: true, timestamp: body.lastSync }));
    } catch (err) {
      res.writeHead(400, CORS_HEADERS);
      return res.end(JSON.stringify({ error: err.message }));
    }
  }

  // API: GET /mc/weather
  if (pathname === '/mc/weather' && method === 'GET') {
    const city = url.searchParams.get('city') || 'Portland';
    try {
      const weather = await getWeather(city);
      res.writeHead(200, CORS_HEADERS);
      return res.end(JSON.stringify(weather));
    } catch (err) {
      res.writeHead(500, CORS_HEADERS);
      return res.end(JSON.stringify({ error: err.message }));
    }
  }

  // API: GET /mc/activity
  if (pathname === '/mc/activity' && method === 'GET') {
    try {
      const data = await fs.readFile(ACTIVITY_FILE, 'utf8');
      const parsed = JSON.parse(data);
      const last50 = parsed.entries.slice(-50);
      res.writeHead(200, CORS_HEADERS);
      return res.end(JSON.stringify({ entries: last50, total: parsed.entries.length }));
    } catch (err) {
      res.writeHead(500, CORS_HEADERS);
      return res.end(JSON.stringify({ error: 'Failed to read activity file' }));
    }
  }

  // API: POST /mc/activity
  if (pathname === '/mc/activity' && method === 'POST') {
    try {
      const body = await parseBody(req);
      const data = await fs.readFile(ACTIVITY_FILE, 'utf8').catch(() => '{"entries":[]}');
      const parsed = JSON.parse(data);
      
      const entry = {
        id: Date.now().toString(36),
        text: body.text || 'Activity logged',
        type: body.type || 'default',
        icon: body.icon || '📝',
        timestamp: new Date().toISOString()
      };
      
      parsed.entries.push(entry);
      await fs.writeFile(ACTIVITY_FILE, JSON.stringify(parsed, null, 2));
      
      res.writeHead(200, CORS_HEADERS);
      return res.end(JSON.stringify({ success: true, entry }));
    } catch (err) {
      res.writeHead(400, CORS_HEADERS);
      return res.end(JSON.stringify({ error: err.message }));
    }
  }

  // 404
  res.writeHead(404, CORS_HEADERS);
  res.end(JSON.stringify({ error: 'Not found', path: pathname }));
}

// Format uptime
function formatUptime(ms) {
  const seconds = Math.floor(ms / 1000);
  const minutes = Math.floor(seconds / 60);
  const hours = Math.floor(minutes / 60);
  const days = Math.floor(hours / 24);
  
  if (days > 0) return `${days}d ${hours % 24}h ${minutes % 60}m`;
  if (hours > 0) return `${hours}h ${minutes % 60}m ${seconds % 60}s`;
  if (minutes > 0) return `${minutes}m ${seconds % 60}s`;
  return `${seconds}s`;
}

// Start server
async function start() {
  await initDataFiles();
  
  const server = http.createServer(handleRequest);
  
  server.listen(PORT, () => {
    console.log('\n🚀 Mission Control Server running!\n');
    console.log(`📍 Local:   http://localhost:${PORT}`);
    console.log(`📁 Data:    ${DATA_FILE}`);
    console.log(`📝 Activity: ${ACTIVITY_FILE}`);
    console.log('\n📡 API Endpoints:');
    console.log(`   GET  http://localhost:${PORT}/mc/status`);
    console.log(`   GET  http://localhost:${PORT}/mc/data`);
    console.log(`   POST http://localhost:${PORT}/mc/data`);
    console.log(`   GET  http://localhost:${PORT}/mc/weather?city=Portland`);
    console.log(`   GET  http://localhost:${PORT}/mc/activity`);
    console.log(`   POST http://localhost:${PORT}/mc/activity`);
    console.log('\n⚡ Press Ctrl+C to stop\n');
  });
  
  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.error(`❌ Port ${PORT} is already in use. Is the server already running?`);
      process.exit(1);
    }
    console.error('Server error:', err);
  });
}

start();
