# Local example runtime

Wasmoon 1.16.0 supplies Lua 5.4 WebAssembly locally. Preserve wasmoon/package/LICENSE and wasmoon/LUA-LICENSE.txt. The embedded-byte loader extension is described in wasmoon/LOCAL-CHANGES.md; the WASM binary is unchanged.

workbench contains the catalog builder, browser UI, worker and verification tools. Node is optional for viewing the page, and required to rebuild or run developer checks. LuaEx retains its optional portable Node distribution and notices under api/node; sibling projects use an installed Node.

The browser uses the real LuaEx initializer, LXC/LXE declarations and Dox sources alongside LuaEx sources. A documented native-I/O-shaped adapter maps the filesystem backend onto Wasmoon’s isolated virtual filesystem; no host DLL is loaded. This verifies example behavior in that runtime, not host-native filesystem semantics.

From the repository root:

```text
node docs/examples/api/workbench/verify.cjs
node docs/examples/api/workbench/bundle.cjs
```
