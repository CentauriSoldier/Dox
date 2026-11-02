# Dox native migration handoff

## Scope and rules

Migrate Dox to the current LuaEx LXC/LXE systems in dependency order, preserving
functionality. Obtain file-specific approval for each step. Back up each original
before editing; preserve legacy sources unchanged. Do not change LuaEx to make
Dox fit. Do not add short aliases or change startup without approval.

## GitHub Wiki builder — 2026-10-30

- `dox/Builders/GitHubWiki/DoxBuilderGitHubWiki.lxc` defines final native class
  `Dox.DoxBuilderGitHubWiki : Dox.DoxBuilder`. PageName, ResolveLink and FormatEntry
  became private static methods; the existing Markdown helper is privately required
  and unchanged. Native syntax payloads use `.Value`.
- The hierarchy, page naming, case-insensitive collision checks, inheritance,
  utility omission, section/column formatting, code languages, links and multi-file
  export algorithms are retained. build/export match the native base signatures.
  No publication, deletion, new output-directory policy or short alias was added.
- Backups are in `legacy/wiki-builder-migration-20261030-211418/`; the exact archive
  is `legacy/dox/Builders/GitHubWiki/DoxBuilderGitHubWiki.lua`. The active original
  remains pending caller migration. Markdown.lua, dox/init.lua and LuaEx are unchanged.
- `tests/wiki_builder_regression.lua`: 776 checks passed at LuaEx load level 2.
  Across 32 fixture sets, native prepared hierarchies and page manifests match
  archived methods through method/superclass/enum-value adapters. Tests cover
  native blocks, navigation ancestors, shared inherited content, UTF-8/tilde page
  names, converted links, examples, combined sections, hidden utility metadata,
  duplicate/collision/missing/circular inheritance rejection and length limits.
  In-memory exports compare Markdown bytes and sorted write order, landing-page
  renaming/reservations, unrelated-file preservation and partial failure/cleanup
  using the archived base writeOutput body. Native clone/restore and finality pass.
- Native project compilation, DoxBuilder 918 and Pulsar builder 196 checks also passed.
- Full Dox startup/exporter integration remains pending; neither live GitHub
  rendering nor publishing is claimed. Adapters do not run the retired class system.

## Pulsar Lua builder — 2026-10-30

- `dox/Builders/Pulsar/Lua/DoxBuilderPulsarLua.lxc` defines final native class
  `Dox.DoxBuilderPulsarLua : Dox.DoxBuilder`. Existing completion preparation,
  hierarchy insertion, inheritance, callable-table normalization, type resolution,
  manifest naming and ZIP construction algorithms are retained. Four local helper
  functions became private static methods; JSON/package modules are required
  privately and were not modified.
- Overrides use the approved native base contracts: build accepts seven arguments
  and ignores unused presentation settings; combined formatting accepts a third ID
  argument and returns the same unwrapped content. Export still uses the base
  implementation, now verified with .zip output and wb mode.
- Backups are in `legacy/pulsar-builder-migration-20261030-210948/`; the exact
  class archive is `legacy/dox/Builders/Pulsar/Lua/DoxBuilderPulsarLua.lua`.
  The active original remains pending caller migration. No aliases, loader,
  installed editor package or LuaEx changes were made.
- `tests/pulsar_builder_regression.lua`: 196 checks passed at LuaEx load level 2.
  Across 42 fixture sets, native completion graphs and ZIP bytes match archived
  builder methods via a method-binding/superclass adapter. Tests cover native
  blocks, ordered arguments, explicit names, documented fields, callable tables,
  constructor return inference, unknown/union types, inherited metadata and
  missing/circular inheritance. Inherited binary export uses in-memory I/O;
  native clone/restore, MIME identity and finality are also checked. The adapter
  does not execute the retired class/enum systems.
- Native project compilation, DoxBuilder 918 and DoxBlock 1,376 checks also passed.
- No live Pulsar installation or full Dox startup/exporter integration is claimed;
  the host, remaining builders, parser classes and production enums still require
  migration/integration.

## DoxBuilder / MIME — 2026-10-30

- `dox/Components/DoxBuilder.lxc` defines `Dox.DoxBuilder` with a protected
  constructor and final getName getter. Embedded native `Dox.DoxBuilder.MIME`
  retains HTML="html", LUACOMPLETERC="luacompleterc", MARKDOWN="MD", TXT="txt".
  Constructor membership uses LXE identity and payload access uses `.Value`.
- Wrapper import/copies, lookups/iteration, replacement/append rules, filename
  fallback, export forwarding and write/close error handling retain the original
  algorithms. Output decisions remain with the concrete builders/Dox host.
- The approved native override contract is explicit: build takes seven arguments
  (title, intro, data, Prism theme, banner, page theme, syntax). The combined-content
  formatter takes display, content and ID. Concrete builder migrations must match
  these signatures and may ignore unused arguments. No concrete builder was edited
  in this step; the legacy base remains active for pending consumers.
- Native persistence validates metadata, MIME identity and wrapper storage while
  retaining concrete subclass fields. No loader changes or short aliases were added.
- Original backups are in `legacy/builder-migration-20261030-210424/`; the unchanged
  class archive is `legacy/dox/Components/DoxBuilder.lua`. The active original is
  retained pending caller integration. No LuaEx changes were made.
- `tests/builder_regression.lua`: 918 checks passed at LuaEx load level 2. Tests
  compare 120 wrapper-operation steps and all MIME export suffixes with archived
  methods through method/enum/type adapters; they verify input/output copies,
  wrapper defaults/validation, MIME payloads, protected construction, finality,
  stub errors, native clone/restore and graph sharing. Injected I/O covers returned
  open/write/close failures and raised write/close failures, comparing cleanup
  with the original. No user output files are written by this suite.
- Native project compilation, DoxBlock 1,376 and DoxBlockTag 2,056 checks also passed.
- Full Dox startup/exporter integration remains pending concrete builder and host
  migrations. The reference adapters do not execute the retired class/enum systems.

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
