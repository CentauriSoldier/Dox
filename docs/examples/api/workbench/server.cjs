// Optional static server. The bundled website also opens directly from disk.
// Uses the portable Node binary in examples/api/node and built-in APIs only.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const {execFile} = require('node:child_process');
const {root} = require('./catalog.cjs');
require('./bundle.cjs').generateBundle();
const types = {'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.json':'application/json','.wasm':'application/wasm','.png':'image/png','.lua':'text/plain; charset=utf-8','.md':'text/plain; charset=utf-8'};
const server = http.createServer((request,response)=>{
  let relative;
  try {relative=decodeURIComponent(new URL(request.url,'http://localhost').pathname);} catch {response.writeHead(400);response.end();return;}
  if(relative==='/')relative='/Examples.html';
  const file=path.resolve(root,'.'+relative);
  const parts=path.relative(root,file).split(path.sep);
  if(!file.startsWith(root+path.sep)||parts.some(part=>part.startsWith('.'))||file.endsWith('.exe')){response.writeHead(403);response.end('Forbidden');return;}
  if(!['GET','HEAD'].includes(request.method)){response.writeHead(405);response.end();return;}
  fs.stat(file,(error,stat)=>{
    if(error||!stat.isFile()){response.writeHead(404);response.end('Not found');return;}
    response.writeHead(200,{'Content-Type':types[path.extname(file)]||'application/octet-stream','Content-Length':stat.size,'Cache-Control':'no-store','X-Content-Type-Options':'nosniff'});
    if(request.method==='HEAD')response.end();else fs.createReadStream(file).pipe(response);
  });
});
server.listen(0,'127.0.0.1',()=>{
  const url=`http://127.0.0.1:${server.address().port}/Examples.html`;
  console.log(`Dox Examples: ${url}\nLocal files only. Press Ctrl+C to stop.`);
  if(process.argv.includes('--open'))execFile('rundll32.exe',['url.dll,FileProtocolHandler',url]);
});
