const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = path.resolve(__dirname, 'build/web');

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.mjs': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.webp': 'image/webp',
  '.wasm': 'application/wasm',
  '.map': 'application/json',
  '.pdf': 'application/pdf',
  '.txt': 'text/plain; charset=utf-8',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf'
};

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url);
  let pathname = decodeURIComponent(parsedUrl.pathname);

  // Prevent directory traversal
  let safePath = path.normalize(path.join(PUBLIC_DIR, pathname));
  if (!safePath.startsWith(PUBLIC_DIR)) {
    res.writeHead(403, { 'Content-Type': 'text/plain' });
    return res.end('403 Forbidden');
  }

  // Check if file exists
  fs.stat(safePath, (err, stats) => {
    if (!err && stats.isDirectory()) {
      safePath = path.join(safePath, 'index.html');
      return serveFile(safePath, res);
    }

    if (!err && stats.isFile()) {
      return serveFile(safePath, res);
    }

    // SPA fallback: If no file extension or route, serve index.html
    const ext = path.extname(pathname);
    if (!ext) {
      const indexPath = path.join(PUBLIC_DIR, 'index.html');
      return serveFile(indexPath, res);
    }

    // Static asset not found
    res.writeHead(404, { 'Content-Type': 'text/plain' });
    res.end('404 Not Found');
  });
});

function serveFile(filePath, res) {
  const ext = path.extname(filePath).toLowerCase();
  const contentType = MIME_TYPES[ext] || 'application/octet-stream';

  const headers = {
    'Content-Type': contentType,
    'Access-Control-Allow-Origin': '*'
  };

  // Cache settings
  if (ext === '.html') {
    headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
  } else if (['.js', '.wasm', '.png', '.jpg', '.webp', '.svg', '.woff2', '.ttf', '.otf'].includes(ext)) {
    headers['Cache-Control'] = 'public, max-age=604800';
  }

  // PDF attachment header if in documents
  if (ext === '.pdf') {
    headers['Content-Disposition'] = 'inline; filename="Muhammed_Faisal_V_Resume.pdf"';
  }

  const stream = fs.createReadStream(filePath);
  stream.on('open', () => {
    res.writeHead(200, headers);
    stream.pipe(res);
  });
  stream.on('error', (err) => {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('500 Internal Server Error');
  });
}

server.listen(PORT, '0.0.0.0', () => {
  console.log(`\n🚀 Portfolio website is running locally!`);
  console.log(`   - Local:    http://localhost:${PORT}`);
  console.log(`   - Network:  http://127.0.0.1:${PORT}`);
  console.log(`   - Serving:  ${PUBLIC_DIR}\n`);
});
