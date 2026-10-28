# Dox changelog

## [**v0.70**] (*in progress*)

### Added
- **Dox.BUILDER.GITHUB_WIKI** and **DoxBuilderGitHubWiki** for local Wiki Markdown export: **Home.md**, **_Sidebar.md**, API pages, parent/member navigation, FQXN links and parser-language code examples.
- Static HTML-to-Markdown formatting for descriptions, headings, emphasis, lists, tables, links and images, with protected code content and safe delimiters.
- Deterministic portable API filenames, escaped landing-page URLs, and pre-write validation of duplicate FQXNs, filename collisions and documentation inheritance.
- Native exporter and initialization regression suites, documented in **tests/README.md**.
- Standalone, immediate initialization through `require("dox.init")`.
- Versioned documentation introduction and generated HTML API reference for GitHub Pages.
- A current repository guide to writing comments and generating HTML and Pulsar packages.

### Changed
- **Dox.export** refreshes the selected builder and delegates output to it. Formatting, file extensions, text/binary modes and file writes belong to the builder layer.
- **Dox.setOutputPath** remains the sole destination setting; builders do not retain independent output directories.
- **DoxBuilder.export** supplies the checked single-file writer inherited by HTML and Pulsar. Pulsar selects ZIP/binary output; Wiki overrides export for multiple Markdown pages.
- Export retains the returned-path and **getOutput** conventions. Wiki returns its landing-page path and content; failures retain the last successful output.
- Switching builders or importing additional blocks no longer requires a manual refresh before export.
- Dox modules reside under the lowercase `dox` namespace, with the initializer inside that folder.
- Core, HTML-builder and Pulsar-builder imports use the standalone module paths.
- Initialization requires `LUAEX_INIT == true`; LuaEx no longer loads Dox automatically.
- The README preserves its existing title image and describes the current API.

### Fixed
- Builder writes close opened handles after raised as well as returned write failures, reporting destination-specific open/write/close errors.

### Verification
- **308 native exporter checks** passed on Windows Lua **5.4.9**: all 30 parsers across HTML/Pulsar/Wiki, all HTML palettes and Prism themes, format switching, custom tags/order, inheritance, filename encoding and filesystem failures.
- Eight fresh-process initialization cases passed, including dependency rejection, LuaEx levels 0–5, repeated imports and failed-import path restoration/retry.
- The pre-change HTML sample matched apart from generated IDs; its Pulsar ZIP remained byte-identical. Generated packages also passed independent ZIP/JSON checks.
- All 52 Dox source files passed syntax loading and exported in all three formats. The Wiki corpus contained 130 Markdown pages and 389 validated generated page links.
- Local headless-browser checks passed for HTML introduction, navigation, topic routing and Back history, plus a rendered Markdown preview. CDN requests were blocked and the Prism UI hook was stubbed; live GitHub rendering and installed Pulsar integration remain unverified.
- The 48-file CoG corpus exported through HTML/Pulsar. Wiki rejected an existing duplicate FQXN before writing pages and preserved existing output. CoG source comments remain unchanged.
- Four unresolved fragment links in existing Dox source comments remain. The broader LuaEx run passed 16 suites; formatter/serializer suites could not run because their configured test files were missing.

### Removed
- Obsolete README notices that described the standalone repository as archived or moved into LuaEx.

---

## [**v0.62**]

### Removed
- Bundled **Dox** implementation, parsers, builders, and assets from the current framework tree; earlier changelog entries are retained as historical records.

---

## [**v0.61**]

### Added
- **Dox.setBlockTagOrder** for per-document section ordering, with stable repeated items and default-order restoration.
- **Dox.THEME** and **setTheme** with 20 page palettes, including Midnight Blue (default), Synthwave Protocol, and Zenburn.
- **Dox.PRISM** and **setPrismTheme** with eight independent code-highlighting palettes; Okaidia remains the default.
- **Dox.setBanner** for optional image banners, with an unavailable-image notice and usable default header on load failure.
- Project-named Pulsar package ZIP export through **Dox.BUILDER.PULSAR_LUA** and the normal **export** method.
- Pulsar completion metadata for documented functions, parameters, returns, fields, enums, callable classes, and object members.
- **DoxBuilder.eachColumnWrapper** and selective wrapper-group clearing.
- Correctly spelled **DoxSyntax.getEscapeCharacter**, retaining the existing getter for compatibility.

### Changed
- Updated *Prism* in **Dox** to *1.30.0*.
- Redesigned Dox HTML output with responsive navigation, selected-item markers, breadcrumbs, and readable content sections.
- Example tags use the active parser's Prism language; explicitly authored code-language markup remains supported.
- Expanded verified Pulsar code-name tags across LuaEx hooks, libraries, classes, primitives, and game-system APIs.
- Localized Dox module dependencies, completed API comments, corrected built-in tag documentation, and removed obsolete scaffolding.
- Updated the documentation example to demonstrate page themes, Prism themes, and Pulsar package generation; regenerated documentation output.

### Fixed
- ***DoxBuilderHTML*** **LoadDoxAsset** function not working in all cases.
- Dox file-extension selection and MIME iteration/registration using incorrect or undeclared variables.
- Public block-tag iteration skipping the last tag and the protected iterator failing to advance.
- Required-tag detection with multiple required tags, invalid block-item indexes, and malformed-item error reporting.
- Empty, sparse, or duplicate tag-alias lists; block-tag equality now includes column count.
- MIME preprocessor replacement, extension normalization/validation, and invalid preprocessor handling.
- Wrapper clearing crashes, rejected replacement indexes, silently ignored new groups, and inconsistent empty-wrapper validation.
- Fortran documentation extraction with both LF and Windows CRLF line endings.
- Lua extraction treating documentation markers inside quoted strings, long strings, or ordinary comments as real Dox blocks.
- HTML Back/Forward history loops, internal/external fragment routing, and encoded documentation names.
- Inherited documentation chain resolution, missing-target diagnostics, and circular-reference detection in HTML and Pulsar output.
- HTML template-marker errors, documentation serialization handling, and combined-section identifiers.
- Export failures now report file-open, write, and close errors; package ZIP output uses binary mode.
- Pulsar code-name overrides, callable-class member visibility, and documented object-member resolution while preserving existing provider completions.

---

## [**v0.60**]

### Added
- **Dox** comment blocks can now use internal anchor links (***#***) to other FQXNs.
- **Dox** output back navigation.
- **Dox** now uses **prism.js** for displaying code blocks with syntax highlighting for all available **prism.js** languages.
- "**Copy**" (*to clipboard*) button to all user-created code blocks in **Dox** HTML output.
- **Code** ***BlockTag*** to Dox, permitting code examples with any user-specified **prism.js** language.
- **Example** ***BlockTag*** now automatically detects the **prism.js** language based on the **Dox** subclass being used.
- Relevant **prism.js** scripts are automatically added to **Dox's** finalized HTML output based on the languages used in the documentation.
- **Dox** **Parsers** (subclasses) for several new languages.

### Changed
- **Dox** now auto-combines certain multiple built-in ***BlockTag*** items such as **Param**, **Return**, etc. into a single section.
- ***DoxBlockTags*** can now be set to *combined* which places all items using that tag into one section.
- **Dox** now has an ***@inheritdoc*** tag that allows inheritance of docs from one **fqxn** to another.
- **Dox** Fully Qualified Dox Names (**fqxn**) may now contain spaces.
- **Dox** now allows custom intro page message.
- **DoxBuilderHTML** now places all output into a single HTML file instead of using a separate *.js* file.
- **Dox** CSS redesigned to be more functional, readable and aesthetically pleasing.
- **DoxBlockTag** column wrappers are now defined by each **DoxBuilder** subclass rather than globally.

### Fixed
- **Dox** displaying parameters, returns and other combined tags out of order.

---

## [**v0.50**]

### Added
- Support for code html tags using **prism.js** in **Dox** module.
- Several new features to **Dox** and prepped it for major updates in future releases.

---

## [**v0.40**]

### Changed
- Integrated and rewrote **Dox** documentation module and added support for other languages.

---

## [**v0.35**]

### Fixed
- Dox "Copy" button not working.

### Changed
- Dox now places all output into a single HTML file instead of using a separate <em>.js</em> file.
- Dox CSS redesigned to be more functional and aesthetically pleasing.

### Added
- Dox now allows custom intro page message.
- Dox comment blocks can now use anchor links (<em>#</em>) to other FQXNs.
- added Dox output back navigation.
- Dox now uses <strong>prism.js</strong> for displaying code blocks with syntax highlighting for all available <strong>prism.js</strong> languages.
- added a "Copy" (to clipboard) button to all user-created code blocks.
- added a <strong>Code</strong> <em><strong>BlockTag</strong></em> to Dox, permitting code examples with any user-specified <strong>prism.js</strong> language.
- <strong>Example</strong> <em><strong>BlockTag</strong></em> now automatically detects the <strong>prism.js</strong> language based on the Dox subclass being used.
- <strong>prism.js</strong> scripts are automatically added to Dox's finalized HTML output based on the languages used in the documentation.
- added Dox parsers (subclasses) for several new languages.

---

## [**v0.30**]

### Added
- added support for code html tags using <strong>prism.js</strong> in <strong>Dox</strong> module.
- added several new features to <strong>Dox</strong> and prepped it for major updates in future releases.

---

## [**v0.20**]

### Added
- integrated and rewrote Dox documentation module and added support for other languages.

---

## [**0.09**]

### Added
- Added support for linux.

---

## [**0.08**]

### Fixed
- Fixed a bug in the local 'import()' function.

---

## [**0.07**]

### Added
- Added the ability to allow a module block to be displayed for multiple modules as desired

### Changed
- Module names can now be displayed differently as desired.

---

## [**0.06**]

### Fixed
- Fixed a bug that was omitting the last entry of blocks.

### Added
- Added the ability for dox to normally and recursively scan directories and process all files at once.

---

## [**0.05**]

### Fixed
- Fixed a bug that allowed empty modules and empty blocks.

### Changed
- Reconfigured Start and End tags to be easier to use.
- Reconfigured function blocks tags to be easier to use.

---

## [**0.04**]

### Added
- Added the binary module and included embeded images for the output.
- Added the <i>Welcome.html</i> page.

---

## [**0.03**]

### Changed
- Moved from a single-page output to a multi-page one.
- Output CSS to and external file (style.css).

### Added
- Added the Module Info panel for each module.

---

## [**0.02**]

### Changed
- Refactored the code and ported all logical functions to modules.

---

## [**0.01**]

### Added
- Created Dox in all its wonder...and despair.
