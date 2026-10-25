# Dox changelog

## v2.1

### Added
- Standalone, immediate initialization through `require("dox.init")`.
- Versioned documentation introduction and generated HTML API reference for GitHub Pages.
- A current repository guide to writing comments and generating HTML and Pulsar packages.

### Changed
- Dox modules reside under the lowercase `dox` namespace, with the initializer inside that folder.
- Core, HTML-builder and Pulsar-builder imports use the standalone module paths.
- Initialization requires `LUAEX_INIT == true`; LuaEx no longer loads Dox automatically.
- The README preserves its existing title image and describes the current API.

### Removed
- Obsolete README notices that described the standalone repository as archived or moved into LuaEx.
