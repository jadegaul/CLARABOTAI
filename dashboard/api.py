#!/usr/bin/env python3
"""Simple API server for dashboard updates"""

import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse

DATA_FILE = 'data/dashboard.json'

class APIHandler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        pass  # Suppress logs
    
    def _set_headers(self, status=200):
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_OPTIONS(self):
        self._set_headers()
    
    def do_GET(self):
        parsed = urlparse(self.path)
        
        if parsed.path == '/api/data':
            try:
                with open(DATA_FILE, 'r') as f:
                    data = json.load(f)
                self._set_headers()
                self.wfile.write(json.dumps(data).encode())
            except Exception as e:
                self._set_headers(500)
                self.wfile.write(json.dumps({'error': str(e)}).encode())
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({'error': 'Not found'}).encode())
    
    def do_POST(self):
        parsed = urlparse(self.path)
        
        if parsed.path == '/api/update':
            try:
                content_length = int(self.headers.get('Content-Length', 0))
                post_data = self.rfile.read(content_length)
                data = json.loads(post_data.decode('utf-8'))
                
                # Write to JSON file
                with open(DATA_FILE, 'w') as f:
                    json.dump(data, f, indent=2)
                
                self._set_headers()
                self.wfile.write(json.dumps({'success': True}).encode())
            except Exception as e:
                self._set_headers(500)
                self.wfile.write(json.dumps({'error': str(e)}).encode())
        else:
            self._set_headers(404)
            self.wfile.write(json.dumps({'error': 'Not found'}).encode())

if __name__ == '__main__':
    os.chdir('/home/jeremygaul/.openclaw/workspace/dashboard')
    server = HTTPServer(('localhost', 8091), APIHandler)
    print('API server running on port 8091')
    server.serve_forever()