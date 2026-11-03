// Build the browser-local payload so Examples.html also opens directly from disk.
// Uses only the portable Node runtime and built-in modules.
const fs = require('node:fs');
const path = require('node:path');
const {generate,root,readSource} = require('./catalog.cjs');
function generateBundle() {
  const manifest = generate();
  const base = 'examples/api/workbench/';
  const payload = {
    manifest,
    verification:JSON.parse(fs.readFileSync(path.join(root,'examples/verification.json'),'utf8')),
    files:Object.fromEntries(manifest.files.map(file=>[file,readSource(file).toString('base64')])),
    scripts:{
      wasmoon:fs.readFileSync(path.join(root,'examples/api/wasmoon/package/dist/index.js'),'utf8'),
      runtime:fs.readFileSync(path.join(root,base+'runtime.js'),'utf8'),
      worker:fs.readFileSync(path.join(root,base+'worker.js'),'utf8'),
    },
    wasm:fs.readFileSync(path.join(root,'examples/api/wasmoon/package/dist/glue.wasm')).toString('base64'),
  };
  fs.writeFileSync(path.join(root,base+'bundle.js'),'// Generated from the repository. No file permissions or network required.\nwindow.ExampleBundle = '+JSON.stringify(payload)+';\n');
  return payload;
}
if(require.main===module){const payload=generateBundle();console.log(`Bundled ${payload.manifest.entries.length} examples for direct browser launch.`);}
module.exports={generateBundle};
