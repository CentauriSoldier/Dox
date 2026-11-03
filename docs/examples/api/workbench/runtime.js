(function (scope) {
  'use strict';
  class LuaSession {
    constructor(wasmoon, wasm, emit) { this.wasmoon = wasmoon; this.wasm = wasm; this.emit = emit; }
    async boot(files) {
      this.factory = this.wasm instanceof Uint8Array
        ? new this.wasmoon.LuaFactory('/embedded-lua.wasm', undefined, this.wasm)
        : new this.wasmoon.LuaFactory(this.wasm);
      for (const [name, bytes] of Object.entries(files)) await this.factory.mountFile('/' + name, bytes);
      await this.factory.mountFile('/examples/resources/.keep', new Uint8Array());
      this.originalFiles = files;
      const virtualFS = (await this.factory.getLuaModule()).module.FS;
      // Match the native I/O record contract over Wasmoon's isolated memory filesystem.
      // Framework sources remain unchanged; only package.loadlib's filesystem backend
      // is supplied here, because a browser cannot load a host DLL/shared object.
      const literal = value => {
        if (value === null || value === undefined) return 'nil';
        if (typeof value === 'string') return JSON.stringify(value);
        if (typeof value === 'number' || typeof value === 'boolean') return String(value);
        if (Array.isArray(value)) return '{'+value.map(literal).join(',')+'}';
        return '{'+Object.entries(value).map(([key,item])=>'['+literal(key)+']='+literal(item)).join(',')+'}';
      };
      const canonical = name => {
        const parts=[];
        for(const part of name.replaceAll('\\','/').split('/')) {
          if(part==='..')parts.pop();else if(part && part!=='.')parts.push(part);
        }
        return '/'+parts.join('/');
      };
      const stat = name => {
        const file=canonical(name), info=virtualFS.stat(file);
        return {Path:file,Identity:file,Name:file.split('/').pop(),Kind:((info.mode & 0o170000) === 0o040000)?'directory':'file',Size:info.size,Mode:info.mode};
      };
      this.fsBridge = (op,name,target) => {
        try {
          const file=canonical(name || '/'); let value=true;
          if(op==='stat')value=stat(file);
          else if(op==='list')value=virtualFS.readdir(file).filter(item=>item!=='.'&&item!=='..'&&(file!=='/'||['LuaEx','cog','dox','examples'].includes(item))).sort().map(item=>stat(file+'/'+item));
          else if(op==='mkdir')virtualFS.mkdir(file);
          else if(op==='copy')virtualFS.writeFile(canonical(target),virtualFS.readFile(file));
          else if(op==='move')virtualFS.rename(file,canonical(target));
          else if(op==='delete')virtualFS.unlink(file);
          else if(op==='rmdir')virtualFS.rmdir(file);
          else if(op==='chmod')virtualFS.chmod(file,target);
          else if(op==='root')value='/';
          else if(op==='read')value=virtualFS.readFile(file,{encoding:'utf8'});
          else throw Error('Unsupported virtual filesystem operation: '+op);
          return literal({ok:true,value});
        } catch(error) { return literal({ok:false,reason:error.message || String(error),code:error.errno===44?2:error.errno || 5}); }
      };
      this.lua = await this.factory.createEngine({injectObjects:false,enableProxy:false});
      const index = Object.fromEntries(Object.keys(files).map(name => [name.toLowerCase(), '/' + name]));
      this.lua.global.set('__workbench_files', index);
      this.lua.global.set('__workbench_fs', this.fsBridge);
      this.lua.global.set('__workbench_emit', this.emit);
      await this.lua.doString(`
        package.path = '/?.lua;/LuaEx/?.lua'
        local files = __workbench_files
        table.insert(package.searchers, 2, function(name)
          local file = files[(name:gsub('%.','/') .. '.lua'):lower()]
          if file then return assert(loadfile(file)), file end
          return '\\n\\tNo mounted LuaEx module: ' .. name
        end)
        local nativeToString = tostring
        print = function(...)
          local values = {}
          for index = 1, select('#', ...) do values[index] = nativeToString(select(index,...)) end
          __workbench_emit(table.concat(values, '\\t'))
        end
        -- Install a native-ABI-shaped backend before LuaEx loads its ordinary iohook.
        local loadlib = package.loadlib
        package.loadlib = function(file, symbol)
          if symbol ~= 'luaopen_luaex_io' then return loadlib(file,symbol) end
          return function()
            local backend = {Version=1}
            for _,operation in ipairs({'stat','list','mkdir','copy','move','delete','rmdir','chmod','root','read'}) do
              backend[operation] = function(...)
                local result = assert(load('return '..__workbench_fs(operation,...)))()
                if result.ok then return result.value end
                return nil,result.reason,result.code
              end
            end
            return backend
          end
        end
        -- line currently captures the older atan2 name during module initialization.
        math.atan2 = math.atan2 or math.atan
        require('LuaEx.init')
        if files['cog/load.lua'] then require('cog.load')() end
        if files['dox/init.lua'] then require('dox.init') end
        -- The virtual filesystem uses forward slashes on every host.
        local open = io.open
        io.open = function(file, ...) return open(file:gsub('\\\\','/'), ...) end
      `);
      return this.lua.doString('return _VERSION');
    }
    async run(file, source, inputs = {}) {
      this.lua.global.set('EXAMPLE_INPUT',inputs);
      await this.factory.mountFile('/' + file, source);
      return this.lua.doFile('/' + file);
    }
    async visual(inputs = {}) { this.lua.global.set('EXAMPLE_INPUT',inputs);return this.lua.doFile('/examples/visual/AStar/browser.lua'); }
    async action(action, payload = {}) {
      this.lua.global.set('__workbench_action', action);
      this.lua.global.set('__workbench_payload', payload);
      return this.lua.doString('return workbench_action(__workbench_action, __workbench_payload)');
    }
    async outputs() {
      const fs = (await this.factory.getLuaModule()).module.FS;
      const result = [];
      const visit = directory => {
        for (const name of fs.readdir(directory)) {
          if (name === '.' || name === '..') continue;
          const file = directory + '/' + name;
          if ((fs.stat(file).mode & 0o170000) === 0o040000) { visit(file); continue; }
          if (!/\.(png|csv|html|json|zip|luaex)$/i.test(file)) continue;
          const bytes = fs.readFile(file), original = this.originalFiles[file.slice(1)];
          if (!original || original.length !== bytes.length || bytes.some((value,index)=>value !== original[index])) result.push({name:file.slice(1),bytes});
        }
      };
      visit('/examples');
      return result;
    }
    close() { if (this.lua) { this.lua.global.close(); this.lua = null; } }
  }
  if (typeof module !== 'undefined' && module.exports) module.exports = {LuaSession};
  else scope.LuaSession = LuaSession;
})(globalThis);
