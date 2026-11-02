# Dox native migration handoff

## Scope and rules

Migrate Dox to the current LuaEx LXC/LXE systems in dependency order, preserving
functionality. Obtain file-specific approval for each step. Back up each original
before editing; preserve legacy sources unchanged. Do not change LuaEx to make
Dox fit. Do not add short aliases or change startup without approval.

## DoxMime — 2026-10-30

- `dox/Components/DoxMime.lxc` defines `Dox.DoxMime`. The extension normalization,
  validation, callback reference behavior and nil-returning setter are retained.
  Each omitted callback still creates a distinct identity function.
- Callback storage is privately boxed for native graph persistence. A weak index
  recognizes internally created default callbacks; snapshot preparation writes an
  empty default marker instead of exporting LXC-compiled application code. Restore
  recreates defaults, while custom application callbacks retain captured state.
  Reusing another instance's default callback is supported. No LuaEx edits were made.
- Native snapshot validation checks normalized names and callback storage. Clone,
  graph sharing/cycles and concrete subclass persistence use native facilities.
- Originals were backed up before edits in
  `legacy/mime-migration-20261030-205015/`. An unchanged class archive also exists
  at `legacy/dox/Components/DoxMime.lua`.
- The active `dox/Components/DoxMime.lua` is intentionally retained unchanged,
  pending migration of its callers. `dox/init.lua` is unchanged. No global DoxMime
  alias was introduced. Do not remove the active original without caller integration.
- `tests/mime_regression.lua`: 458 checks passed under Lua 5.4 at LuaEx load level 2.
  Tests compare original constructor/getter/setter bodies using a method-binding
  adapter, check invalid inputs and atomic setters, callback identities/captures,
  defaults, cloning, graph persistence, subclasses and malformed projections.
  The retired legacy class implementation itself is not executed by the adapter.
- Full Dox startup and exporter integration remain unverified during this staged
  migration; do not report the framework migration as complete.

## Next dependency review

Review DoxSyntax, then the block/tag and builder foundations, followed by their
consumers and enum declarations. Inspect each owning source before proposing the
next file scope. Main Dox, parser subclasses and startup still use legacy APIs.
