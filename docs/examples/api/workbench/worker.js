'use strict';
let session;
let sequence = Promise.resolve();
self.onmessage = event => {
  sequence = sequence.then(async () => {
    const {id, type, payload} = event.data;
    try {
      let value;
      if (type === 'boot') {
        session = new LuaSession(wasmoon, payload.wasmBytes, text => postMessage({type:'output', text}));
        value = await session.boot(payload.files);
      } else if (type === 'run') { await session.run(payload.path,payload.source,payload.inputs); value = {complete:true,files:await session.outputs()}; }
      else if (type === 'visual') value = payload?.source ? await session.run(payload.path,payload.source,payload.inputs) : await session.visual(payload?.inputs);
      else if (type === 'action') value = await session.action(payload.action,payload.data);
      else throw Error('Unknown worker request');
      postMessage({id,type:'result',value});
    } catch (error) { postMessage({id,type:'error',message:error.message || String(error)}); }
  });
};
