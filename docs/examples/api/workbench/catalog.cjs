// Assemble this repository's examples and their current source dependencies.
// Virtual filenames stay portable; physical sibling paths are build-time details.
const fs=require('node:fs'),path=require('node:path');
const root=path.resolve(__dirname,'../../..');
const repository=path.dirname(root),project=path.basename(repository);
function sourcePath(file){
 if(file.startsWith('LuaEx/'))return path.join(repository,'../LuaEx',file);
 if(file.startsWith('cog/'))return path.join(repository,file);
 if(file.startsWith('dox/'))return path.join(repository,'Dox',file.slice(4));
 return path.join(root,file);
}
function readSource(file){return fs.readFileSync(sourcePath(file));}
function walk(directory){
 return fs.readdirSync(directory,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(entry=>{
  const file=path.join(directory,entry.name);
  if(entry.isDirectory())return ['api','saved','check'].includes(entry.name)?[]:walk(file);
  return [file];
 });
}
function sources(directory,prefix){return walk(directory).filter(file=>/\.(lua|lxc|lxe)$/.test(file)).map(file=>prefix+path.relative(directory,file).split(path.sep).join('/'));}
function generate(){
 const library=sources(path.join(repository,'../LuaEx/LuaEx'),'LuaEx/');
 if(project==='CoG')library.push(...sources(path.join(repository,'cog'),'cog/'));
 if(project==='Dox')library.push(...sources(path.join(repository,'Dox'),'dox/'));
 const examples=walk(path.join(root,'examples')).filter(file=>/\.(lua|lxc|lxe|csv|ini|png|tmx|tsx)$/.test(file)).map(file=>path.relative(root,file).split(path.sep).join('/'));
 const entries=JSON.parse(fs.readFileSync(path.join(root,'examples/catalog.json'),'utf8'));
 for(const entry of entries)for(const key of ['path','codePath','visualPath'])if(entry[key]&&!examples.includes(entry[key]))throw Error('Missing '+key+': '+entry[key]);
 const manifest={version:2,project,runtime:'Lua 5.4 / Wasmoon 1.16.0',library,files:[...new Set([...library,...examples])],entries};
 fs.writeFileSync(path.join(root,'examples/manifest.json'),JSON.stringify(manifest,null,2)+'\n');return manifest;
}
if(require.main===module)console.log('Catalog:',generate().entries.length,'examples');
module.exports={generate,root,project,readSource};
