#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

# Dictionary of file extensions and their MIME types
MIME_TYPES = {
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.gif': 'image/gif',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.woff': 'font/woff',
    '.woff2': 'font/woff2',
    '.ttf': 'font/ttf',
    '.eot': 'application/vnd.ms-fontobject',
    '.otf': 'font/otf',
    '.map': 'application/json'
}

class FlutterHTTPRequestHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        # Enable CORS
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET')
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        return super().end_headers()

    def guess_type(self, path):
        # Extract file extension
        base, ext = os.path.splitext(path)
        
        # For .dart.js files, use JavaScript MIME type
        if path.endswith('.dart.js'):
            return 'application/javascript'
            
        # Return the MIME type from our dictionary or the default
        return MIME_TYPES.get(ext.lower(), super().guess_type(path))

    def do_GET(self):
        # Serve custom_index.html if the path is the root
        if self.path == '/':
            self.path = '/web/custom_index.html'
        # Ensure paths to Flutter assets work
        elif self.path.startswith('/assets/'):
            # Remove leading slash to match local directory structure
            self.path = self.path[1:]
        
        return SimpleHTTPRequestHandler.do_GET(self)

# Create and start the server
port = 5000
handler = FlutterHTTPRequestHandler
server = HTTPServer(('0.0.0.0', port), handler)

print(f"Server started at http://0.0.0.0:{port}")
try:
    server.serve_forever()
except KeyboardInterrupt:
    print("Server stopped.")
    server.server_close()