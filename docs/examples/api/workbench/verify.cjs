// Verify each shipped tutorial and visual against the current bundled sources.
const fs=require('node:fs'),path=require('node:path'),assert=require('node:assert/strict');
const {generate,root,readSource}=require('./catalog.cjs');
const {LuaSession}=require('./runtime.js');
const wasmoon=require('../wasmoon/package/dist/index.js');
(async()=>{
 const manifest=generate(),results=[];
 for(const entry of manifest.entries.filter(entry=>!process.argv[2]||entry.id.includes(process.argv[2]))){
  const runs=[];
  for(const file of [...new Set([entry.path,entry.codePath,entry.visualPath].filter(Boolean))]){
   const output=[];
   const engine=new LuaSession(wasmoon,new Uint8Array(fs.readFileSync(path.join(root,'examples/api/wasmoon/package/dist/glue.wasm'))),line=>output.push(line));
   try{
    await engine.boot(Object.fromEntries(manifest.files.map(file=>[file,new Uint8Array(readSource(file))])));
    const result=await engine.run(file,readSource(file).toString());
    if(file===entry.visualPath){assert(result && typeof result==='object','Visual returned no state');await engine.action('view');}
    else assert(output.some(line=>line.includes('[SUMMARY]')),'Missing tutorial summary');
    runs.push({file,result:'passed'});
   }catch(error){runs.push({file,result:'error',message:error.message});}
   finally{engine.close();}
  }
  const failed=runs.find(run=>run.result==='error');
  results.push({id:entry.id,result:failed?'error':'passed',runs,...(failed?{message:failed.message}:{})});
  console.log(failed?'FAIL':'PASS',entry.id,failed?failed.message.split('\n').slice(0,2).join(' '):'source, code and visual');
 }
 fs.writeFileSync(path.join(root,'examples/verification.json'),JSON.stringify(results,null,2)+'\n');
 if(results.some(result=>result.result==='error'))process.exitCode=1;
})().catch(error=>{console.error(error);process.exitCode=1;});
