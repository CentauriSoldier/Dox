# Dox native migration handoff

## Scope and rules

Migrate Dox to the current LuaEx LXC/LXE systems in dependency order, preserving
functionality. Obtain file-specific approval for each step. Back up each original
before editing; preserve legacy sources unchanged. Do not change LuaEx to make
Dox fit. Do not add short aliases or change startup without approval.

## DoxBlock — 2026-10-30

- `dox/Components/DoxBlock.lxc` defines final class `Dox.DoxBlock`, depending on
  Dox.DoxBlockTag and Dox.DoxSyntax. The native syntax member is read through
  `.Value`; no legacy `.value` compatibility path was added to the new component.
- Original tokenization, escaped tag markers, alias lookup, FQXN handling,
  required tags, disallowed multiples, configured tag order and stable ordering
  of repeated tags are retained. Public fqxn()/eachItem()/item() behavior remains;
  item access clones tag definitions. Private FQXN storage is named _tFQXN because
  LXC does not permit a field and method with the same name at one class level.
- Native clone/restore keeps definition data and graph sharing; the snapshot hook
  validates list shape, segment types, tag identities and nonblank item content.
  It does not impose additional qualified-name syntax rules.
- Originals were backed up in `legacy/block-migration-20261030-210024/`.
  `legacy/dox/Components/DoxBlock.lua` is an unchanged archive. The active Lua
  original remains until callers migrate; the production syntax enum and loader
  were not modified.
- `tests/block_regression.lua`: 1,376 checks passed at LuaEx load level 2, including
  94 block fixtures compared with archived constructor/private/public methods
  through a method-binding adapter and a legacy enum-value adapter. The native
  side uses an actual LXE member containing a native syntax instance. Coverage
  includes content/order, missing/duplicate tags, escaped markers, malformed
  input/indexes, cloned tags, finality, graph persistence and malformed snapshots.
  These adapters do not execute the retired class/enum systems. Full Dox startup
  and exporter integration remain pending. Native project compilation and prior
  component suites (DoxBlockTag 2,056; DoxSyntax 484; DoxMime 458) also passed.

## DoxBlockTag — 2026-10-30

- `dox/Components/DoxBlockTag.lxc` defines final class `Dox.DoxBlockTag`.
  Constructor normalization/defaults, ordered aliases, lookups/iteration, flags,
  column counts, clone reconstruction and string formatting retain the original
  algorithms. Equality compares the normalized fields and ordered alias list;
  unrelated native objects compare unequal. No aliases or loader changes were made.
- Native graph persistence retains sharing/cycles. The snapshot hook validates
  normalized aliases, display text, flags, combined/multiple consistency and
  column counts. Positive-infinite extra columns remain supported because the
  original constructor allows them; no unrelated numeric policy was introduced.
- Originals were backed up in `legacy/block-tag-migration-20261030-205628/`.
  The unchanged archive is `legacy/dox/Components/DoxBlockTag.lua`; its active
  Lua original remains until callers migrate. BuiltInBlockTags.lua and init.lua
  were left unchanged.
- `tests/blocktag_regression.lua`: 2,056 checks passed at LuaEx load level 2.
  All 43 built-in tag definitions and 112 flag/column combinations are compared
  with archived constructor/getter/equality/string bodies using method-binding
  adapters. Tests also cover copied input, alias order/case, normalized defaults,
  clone independence, finality, field privacy, native graph persistence and
  malformed field projections. The adapter does not run the legacy class runtime.
- Native project compilation, DoxMime 458 and DoxSyntax 484 checks also passed.
  Full Dox startup and exporter integration remain pending.

## DoxSyntax — 2026-10-30

- `dox/Components/DoxSyntax.lxc` defines final class `Dox.DoxSyntax`. The
  constructor's validation and exact stored strings are retained, including
  nonempty whitespace/newline closing delimiters. Both getEscapeCharacter and
  the existing getEscapeCharater spelling remain available.
- Native cloning/persistence preserve definition fields; a declaring-class
  snapshot hook applies the original constructor validation to restored values.
  No setters, aliases, enum changes or LuaEx changes were introduced.
- Originals were backed up before editing in
  `legacy/syntax-migration-20261030-205327/`. The unchanged class archive is
  `legacy/dox/Components/DoxSyntax.lua`; its active Lua original remains in place
  until callers migrate. The different `dox/DoxSyntax.lua` is not the initialized
  component and was left untouched, along with DoxSyntaxEnum.lua and dox/init.lua.
- `tests/syntax_regression.lua`: 484 checks passed at LuaEx load level 2, comparing
  every getter for all 30 existing syntax payloads against archived class methods
  through a method-binding adapter. It also checks invalid inputs, finality,
  field privacy, exact delimiters, cloning, graph sharing and malformed snapshots.
  The catalog fixture captures original constructor arguments without instantiating
  a legacy enum. Full Dox startup/export integration still awaits caller migration.

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

Review the block/tag and builder foundations next, followed by their
consumers and enum declarations. Inspect each owning source before proposing the
next file scope. Main Dox, parser subclasses and startup still use legacy APIs.
