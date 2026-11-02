# Dox native migration handoff

## Scope and rules

Migrate Dox to the current LuaEx LXC/LXE systems in dependency order, preserving
functionality. Obtain file-specific approval for each step. Back up each original
before editing; preserve legacy sources unchanged. Do not change LuaEx to make
Dox fit. Do not add short aliases or change startup without approval.

## Legacy source retirement — 2026-10-31

- Retired 42 old active Lua sources: 31 parsers, five components, three builders,
  dox/Dox.lua, unused duplicate dox/DoxSyntax.lua and Statics/DoxSyntaxEnum.lua.
  Exact originals remain at their matching legacy/dox paths. No native class,
  enum, helper, asset, startup or unrelated Lua module was removed or edited.
- Every removal was checked against its archive before deletion. A second backup
  plus SHA-256 manifest is in legacy/retire-lua-sources-20261031-080716/;
  retired-files.json lists the exact 42 paths/checksums. Both archive copies were
  rechecked after retirement, and all active counterparts were confirmed absent.
  All 31 native parser declarations remain present.
- The HTML-builder test now reads its host formatter from legacy/dox/Dox.lua;
  the syntax test reads legacy/dox/Statics/DoxSyntaxEnum.lua. HTML reference chunk
  source metadata still points to its former active location for asset-fallback
  layout comparisons; it does not read a removed file. Both tests and the two
  edited documents were backed up before changes in the same retirement folder.
- All 14 migration suites passed again: 21,933 checks. All seven fresh-process
  initialization cases and 311 real filesystem export checks also passed after
  retirement. Fresh output: C:/Users/CS/AppData/Local/Temp/
  DoxRetiredExport-7c0a2082aa71468e97d4bf1586bed560. Source whitespace checks passed.
- Browser rendering, installed Pulsar and live GitHub behavior remain unverified.
  Generated documentation has not been refreshed as part of retirement.

## Startup/caller integration — 2026-10-31

- `dox/init.lua` now retains only its documentation and LuaEx initialization
  prerequisite. All legacy class imports, alias assignments, class/collection
  validation and temporary search-path machinery are gone. Per the user's
  explicit correction, do not add class or enum declaration validation sections.
  LuaEx discovers native declarations before this entry point is required.
- `tests/export.lua` and README examples now use fully qualified Dox classes;
  syntax resolution uses DoxSyntax.fromEnum and enum payloads use .Value.
  Export coverage includes all 31 parsers, including Ada; NASM uses its actual
  DoxAssemblyNasm class name. Old global aliases are intentionally not published.
- `tests/initialization.lua` covers missing prerequisite, passive entry point,
  LuaEx levels 2–5 and retry after an early require. All seven fresh-process cases
  passed. It verifies no legacy imports, no short aliases, preserved namespace,
  cached require and unchanged package.path. Passive mode supplies no classes or
  enums and confirms startup does not inspect declarations. No old injected
  legacy Wiki-import failure remains because startup no longer imports it.
- Real filesystem export run: 311 checks passed using Lua 5.4 on Windows, with
  HTML files, Pulsar ZIPs and Wiki Markdown under a unique disposable directory.
  Checks cover all parsers/builders, format switches, themes, intro/banner,
  wrappers/custom tags/order, inheritance, Unicode/names, I/O failure handling,
  retries and unrelated-file preservation. Output directory for this run:
  C:/Users/CS/AppData/Local/Temp/DoxNativeExport-15e152ccbd2a4cac83efbfd25b1f1f37.
  These checks do not establish browser rendering, live GitHub or Pulsar behavior.
- All six approved originals were backed up before edits in
  `legacy/startup-integration-20261031-075027/`. README and tests/README describe
  current startup/names/enum APIs. Active legacy class Lua originals remain
  retained; removing them is a separate scope. LuaEx, CoG, native classes/enums
  and their existing migration regression tests were not changed in this step.
- The native Dox package is integrated locally through its documented entry point.
  External consumers that still use old global aliases require their own migration;
  no changes to other repositories or generated documentation were authorized.

## Remaining language parsers — 2026-10-31

- All 28 remaining legacy parser sources now have matching `.lxc` declarations
  under `dox/Parsers/`: DoxAda, DoxC, DoxCPlusPlus, DoxCSharp, DoxCSS, DoxDart,
  DoxElm, DoxFortran, DoxFSharp, DoxGo, DoxGroovy, DoxHaskell, DoxHTML, DoxJava,
  DoxJavaScript, DoxJulia, DoxKotlin, DoxMatlab, DoxObjectiveC, DoxPerl, DoxPHP,
  DoxPython, DoxRuby, DoxRust, DoxScala, DoxSwift, DoxTypeScript and DoxXML.
  Each is final, in namespace Dox, derived from Dox.Parser. Original class names,
  validation, MIME lists, identity preprocessing, delimiters and syntax members
  are retained. No extra extensions, helpers or short aliases were introduced.
- Each source was inspected, then backed up before declarations were written in
  `legacy/remaining-parsers-migration-20261031-074203/`; README/HANDOFF originals
  are also there. Exact class archives exist at `legacy/dox/Parsers/*.lua`.
  All 28 active Lua originals match both archives byte-for-byte and remain in
  place pending startup integration. All 31 existing parser sources now have
  matching active native declarations, including the earlier Lua/AutoPlay/NASM.
- `tests/remaining_parsers_regression.lua`: 12,115 checks passed. It invokes each
  archived constructor through a class-binding adapter with native base and
  downstream components, checking metadata, all 43 built-in tag definitions,
  MIME sets, identity callbacks, title errors/finality, all three builders' full
  export bytes/manifests, clone/restore, shared MIME graph identity, custom
  callback captures and uppercase file imports for every advertised extension.
  Syntax-derived fixture delimiters include the existing Ada/Fortran rules;
  those definitions were preserved without changing language policy.
- All 14 migration suites passed with all native parser declarations present:
  21,933 checks total. Native Dox project compilation, exact archive comparisons
  and whitespace checks passed. These tests use archived method/constructor
  adapters, not the retired legacy class runtime. Export writes are captured
  in memory; real-disk output/browser rendering and full startup remain outside
  these checks.
- dox/init.lua, existing parsers/helpers, components/builders and LuaEx were
  unchanged. Next work is startup/caller integration, requiring separate
  file-specific approval. Do not describe Dox as fully integrated yet.

## NASM parser — 2026-10-31

- `dox/Parsers/DoxAssemblyNasm.lxc` defines final
  `Dox.DoxAssemblyNasm : Dox.Parser`, retaining the original Nasm class spelling,
  title validation, !/!/@ delimiters, ASSEMBLY_NASM syntax, asm MIME identity
  preprocessing and 43 built-in tags. No alias or preprocessing helper was added.
- Originals were backed up before editing in
  `legacy/nasm-parser-migration-20261031-073937/`. The unchanged parser archive is
  `legacy/dox/Parsers/DoxAssemblyNasm.lua`; the active Lua original remains.
- `tests/nasm_parser_regression.lua`: 431 checks passed. The archived constructor
  runs through a class-binding adapter against native base/downstream components.
  Checks cover metadata, all tag definitions, identity preprocessing, finality,
  invalid titles, NASM delimiters/highlighting, complete export bytes/manifests
  for all three builders, concrete clone/restore, shared MIME graph identity,
  custom captured callbacks, uppercase file extensions and file/string imports.
- Base parser 682 and MIME 458 checks also passed; native project compilation
  passed. Writes are captured in memory. The retired legacy class runtime,
  real-disk exports and browser rendering are not verified by this suite.
  Startup, other parsers, components/builders and LuaEx were unchanged. The
  legacy init alias spelling DoxAssemblyNASM is left for startup integration;
  no alias compatibility decision was made in this parser migration.

## AutoPlay Media Studio parser — 2026-10-30

- `dox/Parsers/DoxAutoPlayMediaStudio.lxc` defines final
  `Dox.DoxAutoPlayMediaStudio : Dox.Parser`. Name, public title constructor,
  LUA syntax, !/!/@ delimiters and both MIME definitions retain the original
  behavior. It has the 43 built-in tags and no Lua parser-specific PulsarLua tag.
- `dox/Parsers/AutoPlayPreprocessor.lua` creates a fresh ordinary Lua callback per
  parser, preserving the archived five-entity map and single-pass substitution.
  The autoplay MIME decodes quot/apos/lt/gt/amp; unknown, numeric and uppercase
  entities remain unchanged. The lua MIME keeps identity preprocessing, including
  literal bracket escapes. Ordinary callbacks support native host persistence.
- Originals were backed up before edits in
  `legacy/autoplay-parser-migration-20261030-222016/`. The unchanged archive is
  `legacy/dox/Parsers/DoxAutoPlayMediaStudio.lua`; the active Lua original remains.
- `tests/autoplay_parser_regression.lua`: 1,006 checks passed. Archived constructor
  and entity-decoding bodies run through a class-binding adapter with native base
  and downstream components. Checks cover all 43 tag definitions, metadata,
  256 entity-string combinations for both MIME paths, single-pass behavior,
  finality/title errors, Lua lexical exclusions, uppercase file extensions,
  file/string import equivalence, full export bytes/manifests for all three
  builders, concrete clone/restore, shared MIME identities and custom captures.
  The HTML example assertion accounts for quotes escaped in embedded JSON.
- Lua parser 577 and base parser 682 checks also passed, along with native project
  compilation. Export writes are captured in memory. This does not execute the
  retired legacy class runtime or verify real-disk/browser behavior. No startup,
  other parser, component, builder or LuaEx edits were made; integration remains
  pending. Continue with the remaining language-specific parsers.

## Lua parser — 2026-10-30

- `dox/Parsers/DoxLua.lxc` defines final `Dox.DoxLua : Dox.Parser`. Its public
  title constructor retains the original name, delimiters, LUA syntax, one lua
  MIME and PulsarLua utility tag (pulsarlua/pullua aliases). No short alias was added.
- The separately approved `dox/Parsers/LuaPreprocessor.lua` returns a factory
  creating a fresh ordinary Lua callback per parser. The archived preprocessing
  body is retained, including only unescaping square brackets. It uses global
  pairs through the ordinary module environment, avoiding captured C functions
  and LXC-compiled closures that the host serializer rejects. Custom MIME
  callbacks remain replaceable and their captured application data persists.
- Originals were backed up before editing in
  `legacy/lua-parser-migration-20261030-221630/`. The unchanged parser archive is
  `legacy/dox/Parsers/DoxLua.lua`; the active Lua original is also retained.
- `tests/lua_parser_regression.lua`: 577 checks passed. Archived constructor and
  preprocessing bodies run through a class-binding adapter, with native base
  and downstream components. Checks cover all 44 tag definitions, metadata,
  144 preprocessing combinations, finality/title errors, Lua lexical exclusions,
  file/string imports, byte-equivalent exports for all three builders, concrete
  clone/restore, shared MIME graph identity and custom callback persistence.
  Export writes are captured in memory; the retired legacy class runtime is not
  executed and real-disk/browser behavior is not verified by this suite.
- Native project compilation passed, as did base parser 682 and MIME 458 checks.
  Other language parser files, dox/init.lua, existing components/builders and
  LuaEx were not edited. Full startup integration remains pending.

## Base parser — 2026-10-30

- `dox/Parser.lxc` defines extensible `Dox.Parser`, with a protected constructor.
  The user selected Parser because this is the base for language-specific parsers.
  Dox remains the namespace. The initial unpublished `dox/Dox.lxc` draft was
  backed up and renamed; no `Dox.Dox` declaration remains active. Existing
  components/builders did not need namespace-reference edits.
- Import/extraction, raw-block deduplication, MIME handling, tag validation/order,
  per-document themes/banner/intro/output settings and builder delegation retain
  the archived algorithms. Auto accessors are explicit native methods; setters
  retain fluent returns. The private refresh helper is `_refresh`; the protected
  named-tag iterator is `_eachBlockTag`, distinguishing it from public
  `eachBlockTag`, which still yields cloned tags. No existing parser subclass
  calls the protected iterator. Builder callbacks use a lexical wrapper so
  private formatter access retains the parser's declaring context.
- `dox/Statics/DoxEnums.lxe` now declares BUILDER (HTML, PULSAR_LUA, GITHUB_WIKI)
  with class-name string values, and OUTPUT with HTML = 1. BUILDER values no
  longer contain builder objects: `Dox.Parser.resolveBuilder(member)` lazily
  caches one shared native instance per canonical member after discovery.
- `BuiltInBlockTags.lua` now uses Dox.DoxBlockTag. It is required lazily during
  construction, after native class publication. Each parser clones the catalog.
  Derived finalized builder trees are omitted from native snapshot projections
  and recomputed on refresh/export; imported strings and last output persist.
- Originals were backed up in `legacy/dox-class-migration-20261030-215117/`.
  The pre-rename draft/test are in `legacy/parser-name-20261030-220718/`.
  The separately approved tag-test adjustment is backed up in
  `legacy/tag-test-fixture-20261030-220913/`.
  Original main/tag sources remain at `legacy/dox/Dox.lua` and
  `legacy/dox/Statics/BuiltInBlockTags.lua`. Native backup declarations use .bak
  suffixes to keep them out of recursive discovery. The active Dox.lua remains.
- `tests/dox_regression.lua`: 682 checks passed. It covers native protected-base
  derivation, all 43 built-ins, custom tags/order/errors, MIME collections, string
  and file imports, Lua lexical extraction, all three exporters, cloning and
  persistence. Archived host bodies run through binding/type adapters against
  native downstream components; full export bytes/manifests match for all 30
  syntaxes and all three builders. The retired legacy class runtime is not run.
- `tests/enums_regression.lua`: 721 checks passed, including BUILDER identity,
  lazy cache/restore and invalid families, plus numeric OUTPUT preservation.
  The block-tag test now reads the archived catalog for its legacy fixtures.
- All ten migration suites passed: 7,804 checks total. Native project compilation
  also passed. Export writes are captured in memory; this does not verify browser
  rendering or real-disk export. Language parsers, dox/init.lua and LuaEx remain
  unchanged. Full application startup integration is still pending.

## HTML builder — 2026-10-30

- `dox/Builders/HTML/DoxBuilderHTML.lxc` defines native
  `Dox.DoxBuilderHTML : Dox.DoxBuilder`. It remains extensible. Build/format overrides
  match the approved base signatures; syntax wrappers use DoxSyntax.fromEnum and
  themes use canonical LXE member checks and `.Value` payloads.
- The existing JSON/script generation, Prism language mapping, banner escaping,
  page palette selection, content formatting and inheritance algorithms are
  retained. Module-level asset state became private static fields. Constructor
  wrapper data comes from a private factory to supply native parent arguments,
  with fresh per-instance wrapper storage and the same block wrapper bytes.
- Asset loading keeps package-path lookup and source-folder fallbacks. The native
  helper uses its currently compiled method source location instead of the source
  of a bound method facade. Optional _SourceFolder is read explicitly from _G.
  Embedded JavaScript literal indentation is preserved exactly; the initial
  generated indentation difference was caught and corrected by byte comparisons.
- Edited originals were backed up in
  `legacy/html-builder-migration-20261030-213444/`. The exact archive is
  `legacy/dox/Builders/HTML/DoxBuilderHTML.lua`; the active Lua original remains
  pending caller migration. Assets, Themes.lua, PrismLanguages.lua, dox/init.lua
  and LuaEx were not changed. No short alias was introduced.
- `tests/html_builder_regression.lua`: 135 checks passed at LuaEx load level 2.
  Archived HTML/private/base method bodies run through binding/enum/type adapters,
  with the archived host formatter and deterministic section IDs. Complete HTML
  bytes match across all 20 page themes and all 8 Prism themes, both intro paths,
  banners and source-relative fallback. All 30 syntax wrappers match. Tests also
  cover finalized hierarchy/inheritance, wrapper defaults, invalid enum
  families, utility omission, Prism scripts, in-memory inherited export, native
  clone/restore and canonical class references. The legacy class runtime is not run.
- Native project compilation, DoxBuilder 918 and enum/resolver 689 checks also passed.
- This verifies output/data behavior, not browser rendering. Full Dox host/parser
  integration remains pending.

## Syntax data resolution — complete, 2026-10-30

- The user explicitly rejected changing LuaEx and approved a Dox-only solution.
  Do not revive the earlier suggestion to alter core class/enum loading.
- `dox/Statics/DoxEnums.lxe` now declares all 58 members: PRISM (8), THEME (20),
  SYNTAX (30). All names, ordering and source data are preserved. SYNTAX values
  are read-only records with name/commentOpen/commentClose/escapeCharacter/prismName.
  They contain no constructor calls and load in the ordinary discovery batch.
- `Dox.DoxSyntax.fromEnum(member)` lazily constructs and privately caches one
  actual syntax object per enum member after discovery. Native syntax-object
  payloads still pass through for existing callers that provide them. The resolver
  validates data through the existing constructor. No global aliases were added.
- Native DoxBlock and the Wiki builder use this resolver. The Pulsar test consumes
  canonical Dox.SYNTAX data through DoxBlock. Future HTML/main-Dox migrations must
  use the resolver rather than `.Value.get...`. External code that treated `.Value`
  as a syntax object must use fromEnum; this API consequence was disclosed/approved.
- Backups are in `legacy/syntax-data-migration-20261030-212831/`. Declaration
  backups use `.lxc.bak`/`.lxe.bak` so ordinary recursive discovery does not load
  them as duplicates. These backup bytes remain unchanged. Future native source
  backups must also use a non-discoverable extension. Active legacy Lua originals
  and the entry point remain unchanged pending consumer migration.
- Verification: enums/resolver 689, DoxBlock 1,377, Wiki builder 777, Pulsar builder
  196 and DoxSyntax 484 checks passed. Native Dox project compilation passed.
  Checks include fresh discovery, every original syntax field, cached identity,
  read-only descriptors, native enum persistence, malformed data, actual canonical
  enum parsing and Wiki code-language parity. Existing object-payload fixtures also
  pass. No LuaEx source was changed; full Dox startup/export integration is pending.
- Earlier backups of the original enum-owning Lua sources remain in
  `legacy/enums-migration-20261030-211857/`, with unchanged archives at
  `legacy/dox/Dox.lua` and `legacy/dox/Statics/DoxSyntaxEnum.lua`. The failed direct
  instance-payload draft was superseded by this data/resolver design.

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

## Remaining scope

Native migration, Dox-local startup/caller integration and active legacy source
retirement are complete. Generated documentation can be reviewed separately.
External repositories were not changed. No browser, installed Pulsar or live
GitHub verification was performed.
