# Local change to Wasmoon 1.16.0

The distributed `dist/index.js` has a small compatibility extension: an optional
third `LuaFactory` constructor argument forwards WASM bytes to the generated
loader as `luaexWasmBytes`. The byte reader returns this payload directly and
skips streaming fetch when it is present. This build's standard `wasmBinary`
option is disabled, so the small loader extension is necessary.
`LuaWasm.initialize` receives the same optional argument. Existing URL-based
callers retain the original behavior.

The workbench passes embedded WASM bytes and places Wasmoon, the Lua loader,
and worker handling code in one worker script. This avoids nested blob script
imports and fetching a blob WASM URL from an opaque `file://` origin.

The original package license is retained. No change was made to `glue.wasm`.
