(() => {
  'use strict';
  const $ = id => document.getElementById(id);
  const panel = id => $(id) || {};
  let provider, manifest, verification = [], entry, originalSource = '', worker, state, playing = false;
  let requestId = 0, generation = 0, playTimer, nextPaint, paintKey, selecting = 0;
  let outputLines = 0, outputBytes = 0, objectURLs = [], savedMap;
  let mode='code',visualSource='',savedVisual=null;
  const codeDrafts=new Map();
  const pending = new Map();
  const array = value => Array.isArray(value) ? value : Object.values(value || {});
  function append(text) {
    if (outputLines >= 2000 || outputBytes >= 200000) return;
    const line = String(text); outputLines++; outputBytes += line.length;
    $('output').textContent += line + '\n';
    if (outputLines === 2000 || outputBytes >= 200000) $('output').textContent += '[Output limit reached]\n';
    $('output').scrollTop = $('output').scrollHeight;
  }
  function clearOutput() { $('output').textContent = ''; outputLines = outputBytes = 0; $('generated-files').replaceChildren(); $('generated-files').hidden = true; }
  function setStatus(text) { $('run-status').textContent = text; }
  function pause() { playing = false; clearTimeout(playTimer);  }
  function dispose(message = 'Stopped') {
    window.PoolView?.dispose();
    window.PotView?.dispose();
    window.ProteanView?.dispose();
    window.StackView?.dispose();
    window.EnumView?.dispose();
    window.ItemView?.dispose();
    window.CardView?.dispose();
    window.VehicleView?.dispose();
    window.TextCatalogView?.dispose();
    window.TiledView?.dispose();
    generation++; pause(); if (worker) worker.terminate(); worker = null;
    for (const request of pending.values()) { clearTimeout(request.timer); request.reject(Error(message)); }
    pending.clear(); for (const url of objectURLs) URL.revokeObjectURL(url); objectURLs = [];
    $('stop').disabled = true; $('run').disabled = !provider; state = null;
    $('visual-tab').disabled=$('code-tab').disabled=false;
  }
  function request(type, payload) {
    if (!worker) return Promise.reject(Error('Run the example first.'));
    const id = ++requestId;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => { dispose('Execution timed out'); setStatus('Timed out'); append('Execution timed out. Adjust the code and run again.'); }, 30000);
      pending.set(id,{resolve,reject,timer}); worker.postMessage({id,type,payload});
    });
  }
  function bytes(base64) { return Uint8Array.from(atob(base64),character=>character.charCodeAt(0)); }
  function makeProvider() {
    const bundle = window.ExampleBundle;
    if (!bundle) throw Error('The local example bundle is missing.');
    return {
      read:async file => {
        if(file==='examples/manifest.json')return new TextEncoder().encode(JSON.stringify(bundle.manifest));
        if(file==='examples/verification.json')return new TextEncoder().encode(JSON.stringify(bundle.verification));
        if(!bundle.files[file])throw Error('Missing bundled file: '+file);
        return bytes(bundle.files[file]);
      },
    };
  }
  const decode = bytes => new TextDecoder().decode(bytes);
  async function initialize(nextProvider) {
    dispose(); provider = nextProvider; $('run').disabled = false;
    $('runtime-status').innerHTML = '<i></i>Reading repository…';
    try {
      manifest = JSON.parse(decode(await provider.read('examples/manifest.json')));
      if (!Array.isArray(manifest.entries) || !manifest.files.includes('LuaEx/init.lua')) throw Error('Invalid example catalog');
      try { verification = JSON.parse(decode(await provider.read('examples/verification.json'))); } catch { verification = []; }
      $('runtime-status').innerHTML = '<i></i>Lua 5.4 · local runtime'; $('runtime-status').classList.add('ready');
      $('example-count').textContent = manifest.entries.length;
      renderList(); await select(manifest.entries[0].id); await run();
    } catch (error) {
      $('welcome').hidden = false; $('workbench').hidden = true;
      $('welcome-note').textContent = error.message;
      $('runtime-status').innerHTML = '<i></i>Could not load examples'; provider = null;
    }
  }
  function renderList() {
    const nav = $('example-list'); nav.replaceChildren();
    const query = $('search').value.toLowerCase();
    for (const group of [...new Set(manifest.entries.map(item => item.group))]) {
      const entries = manifest.entries.filter(item => item.group === group && (item.title + ' ' + item.description + ' ' + item.path).toLowerCase().includes(query));
      if (!entries.length) continue;
      const heading = document.createElement('h2'); heading.className = 'category'; heading.textContent = group; nav.append(heading);
      for (const item of entries) {
        const button = document.createElement('button'); button.className = 'example-link' + (item.id === entry?.id ? ' active' : '');
        button.setAttribute('aria-current',item.id === entry?.id ? 'true' : 'false');
        const name = document.createElement('span'); name.textContent = item.title.replace(' (legacy)',''); button.append(name);
        const result = verification.find(test => test.id === item.id);
        if (result?.result === 'error') {
          const badge = document.createElement('span'); badge.className = 'badge'; badge.textContent = 'ISSUE'; button.append(badge);
        }
        button.addEventListener('click',() => select(item.id).catch(error=>append(error.message))); nav.append(button);
      }
    }
    if (!nav.children.length) { const empty = document.createElement('p'); empty.className = 'sidebar-empty'; empty.textContent = 'No matching examples.'; nav.append(empty); }
  }
  function tab(visual) {
    if(!visual&&mode==='visual'&&worker&&state){pause();window.PoolView?.stop();window.PotView?.stop();generation++;for(const task of pending.values()){clearTimeout(task.timer);task.reject(Error('Tab changed'));}pending.clear();savedVisual={worker,state,urls:objectURLs};worker=null;state=null;objectURLs=[];}
    if(visual&&mode==='code'&&savedVisual){dispose();worker=savedVisual.worker;state=savedVisual.state;objectURLs=savedVisual.urls;savedVisual=null;update();action('view');}
    mode=visual?'visual':'code';const showVisual=visual;
    panel('visual-panel').hidden = !showVisual || entry?.visualType!=='astar';
    panel('pool-panel').hidden = !showVisual || entry?.visualType!=='pool'; panel('code-panel').hidden = showVisual;
    panel('pot-panel').hidden=!showVisual||entry?.visualType!=='pot';
    panel('protean-panel').hidden=!showVisual||entry?.visualType!=='protean';
    panel('stack-panel').hidden=!showVisual||entry?.visualType!=='stack';
    panel('enum-panel').hidden=!showVisual||entry?.visualType!=='enum';
    panel('items-panel').hidden=!showVisual||entry?.visualType!=='items';
    panel('cards-panel').hidden=!showVisual||entry?.visualType!=='cards';
    panel('vehicles-panel').hidden=!showVisual||entry?.visualType!=='vehicles';
    panel('textcatalog-panel').hidden=!showVisual||entry?.visualType!=='textcatalog';
    panel('tiled-panel').hidden=!showVisual||entry?.visualType!=='tiled';
    $('visual-empty').hidden=!showVisual||Boolean(entry?.visualPath);
    $('example-inputs').hidden=!showVisual||!entry?.inputs?.length;
    $('run').textContent=visual?'▶ Run visual':'▶ Run code';$('run').disabled=visual&&!entry?.visualPath;
    setStatus(visual?(entry?.visualPath?(worker?'Running · Lua 5.4':'Ready to run visual'):'No visual yet'):'Ready to run code');
    $('visual-tab').setAttribute('aria-selected',String(showVisual)); $('code-tab').setAttribute('aria-selected',String(!showVisual));
  }
  async function select(id) {
    if(entry)codeDrafts.set(entry.id,$('editor').value);
    if(savedVisual){savedVisual.worker.terminate();for(const url of savedVisual.urls)URL.revokeObjectURL(url);savedVisual=null;}
    const token = ++selecting; dispose(); entry = manifest.entries.find(item=>item.id===id);
    if (!entry) throw Error('Unknown example');
    clearOutput(); renderInputs(); $('welcome').hidden = true; $('workbench').hidden = false;
    $('example-title').textContent = entry.title; $('example-group').textContent = entry.group.toUpperCase();
    $('example-description').textContent = entry.description; $('example-kind').textContent = 'LUA EXAMPLES';
    const result = verification.find(test=>test.id===entry.id);
    const notes = [entry.note, result?.result === 'error' ? 'Last verification reported an existing example/API error: ' + result.message.split('\n')[0] : ''].filter(Boolean);
    $('example-note').textContent = notes.join(' '); $('example-note').hidden = !notes.length;
    mode='code';$('visual-tab').hidden = false; tab(Boolean(entry.visualPath));
    $('source-path').textContent = entry.codePath; renderList(); setStatus('Loading source…'); $('run').disabled = true;
    const bytes = await provider.read(entry.codePath);
    if (token !== selecting) return;
    originalSource = decode(bytes); $('editor').value = codeDrafts.get(entry.id)||originalSource;
    visualSource=entry.visualPath?decode(await provider.read(entry.visualPath)):'';
    if(token!==selecting)return;
    $('output-footer').textContent = 'Each run starts with a fresh Lua environment.';
    $('run').disabled = false; setStatus('Ready to run'); 
  }
  async function run() {
    if (!provider || !entry) return;
    const visual=mode==='visual';if(visual&&!entry.visualPath)return;
    if(visual&&!$('example-inputs').reportValidity())return;
    const inputs=visual?collectInputs():{};
    dispose(); const token = generation; clearOutput(); setStatus('Loading Dox…'); $('run').disabled = true; $('stop').disabled = false;
    $('visual-tab').disabled=$('code-tab').disabled=true;
    const selected = entry, source = visual?visualSource:$('editor').value, started = performance.now();
    const file=visual?entry.visualPath:entry.codePath;
    try {
      const files = {}; let cursor = 0;
      await Promise.all(Array.from({length:12},async()=>{
        while (cursor < manifest.files.length) { const file = manifest.files[cursor++]; files[file] = await provider.read(file); }
      }));
      if (token !== generation) return;
      const bundle = window.ExampleBundle;
      // One worker contains all its JavaScript. A file:// page has an opaque
      // origin, so nested blob importScripts/fetch calls are not reliable.
      const workerURL = URL.createObjectURL(new Blob([
        bundle.scripts.wasmoon, '\n;\n', bundle.scripts.runtime, '\n;\n', bundle.scripts.worker,
      ], {type:'text/javascript'}));
      objectURLs.push(workerURL);
      if (token !== generation) return;
      worker = new Worker(workerURL);
      worker.onmessage = event => {
        const message = event.data;
        if (message.type === 'output') { append(message.text); return; }
        const task = pending.get(message.id); if (!task) return;
        clearTimeout(task.timer); pending.delete(message.id);
        if (message.type === 'error') task.reject(Error(message.message)); else task.resolve(message.value);
      };
      worker.onerror = event => { append('Worker error: ' + event.message); dispose(); setStatus('Error'); };
      await request('boot',{files,wasmBytes:bytes(bundle.wasm)});
      if (token !== generation) return;
      setStatus('Executing…');
      if (visual) {
        state = await request('visual',{path:file,source,inputs}); update();
        append('Dox loaded. '+selected.title+' is running in Lua 5.4.');
      } else {
        const result = await request('run',{path:file,source,inputs});
        for (const file of result.files || []) {
          const label = document.createElement('span');
          label.textContent = 'Generated in memory: ' + file.name.split('/').pop();
          $('generated-files').append(label); $('generated-files').hidden = false;
        }
      }
      if (token !== generation) return;
      const elapsed = ((performance.now()-started)/1000).toFixed(2);
      setStatus(visual ? 'Running · Lua 5.4' : 'Completed · ' + elapsed + 's');
      $('output-footer').textContent = 'Lua 5.4 · fresh environment · completed in ' + elapsed + 's';
      if (!outputLines) append('Completed successfully. This example does not print output.');
    } catch(error) {
      if (token !== generation) return;
      append('ERROR\n' + error.message); setStatus('Example error'); pause();
      if (visual) {  tab(false); }
    } finally { if (token === generation){$('run').disabled = false;$('visual-tab').disabled=$('code-tab').disabled=false;} }
  }
  async function action(name,data = {}) {
    if (!state || !worker) return;
    const token=generation;
    try {
      const value = await request('action',{action:name,data});
      if(token!==generation)return;
      if (name === 'save') return value;
      state = value; update(); return state;
    } catch(error) { if(token!==generation)return;pause();window.PoolView?.stop();append('ERROR\n' + error.message); }
  }
  function update() {
    if (!state) return;
    if(state.visual==='pool'){window.PoolView?.render(state,action);return;}
    if(state.visual==='potentiometer'){window.PotView?.render(state,action);return;}
    if(state.visual==='protean'){window.ProteanView?.render(state,action);return;}
    if(state.visual==='stack'){window.StackView?.render(state,action);return;}
    if(state.visual==='enum'){window.EnumView?.render(state,action);return;}
    if(state.visual==='items'){window.ItemView?.render(state,action);return;}
    if(state.visual==='cards'){window.CardView?.render(state,action);return;}
    if(state.visual==='vehicles'){window.VehicleView?.render(state,action);return;}
    if(state.visual==='textcatalog'){window.TextCatalogView?.render(state,action);return;}
    if(state.visual==='tiled'){window.TiledView?.render(state,action);return;}
  }
  function renderInputs() {
    const fields=$('input-fields');fields.replaceChildren();$('example-inputs').hidden=!entry.inputs?.length;
    for(const field of entry.inputs || []) {
      const label=document.createElement('label');label.textContent=field.label;
      const input=document.createElement(field.options?'select':'input');input.name=field.name;
      if(field.options)for(const option of field.options){const item=document.createElement('option');item.value=item.textContent=option;input.append(item);}
      else input.type=field.type==='boolean'?'checkbox':field.type==='number'?'number':'text';
      if(field.type==='boolean')input.checked=field.default;else input.value=String(field.default);
      for(const key of ['min','max','step','maxLength','pattern','required'])if(field[key]!==undefined)input[key]=field[key];
      input.dataset.valueType=field.type;label.append(input);fields.append(label);
    }
  }
  function collectInputs() {
    const result={};
    for(const input of $('input-fields').querySelectorAll('input,select')) {
      result[input.name]=input.dataset.valueType==='boolean'?input.checked:input.dataset.valueType==='number'?Number(input.value):input.value;
      if(input.dataset.valueType==='number'&&!Number.isFinite(result[input.name]))throw Error('Enter a finite number for '+input.name);
    }
    return result;
  }
  $('reset-inputs').onclick=renderInputs;
  $('example-inputs').onsubmit=event=>{event.preventDefault();run();};
  $('search').oninput = ()=>{if(manifest)renderList();};
  $('run').onclick = run; $('stop').onclick = ()=>{dispose();setStatus('Stopped');append('Stopped. Run again to start a fresh environment.');};
  $('visual-tab').onclick = ()=>tab(true); $('code-tab').onclick = ()=>tab(false);
  $('restore-source').onclick = ()=>$('editor').value=originalSource;
  $('clear-output').onclick = clearOutput;
  document.addEventListener('keydown',event=>{
    if(event.ctrlKey&&event.key==='Enter'){event.preventDefault();run();return;}
  });
  document.addEventListener('visibilitychange',()=>{if(document.hidden)pause();});
  $('run').disabled=true;
  initialize(makeProvider());
})();
