# Dox exporter regression tests

Use Lua 5.4 with the current LuaEx checkout. The native integration run was
verified on Windows; other hosts have not been verified by that run.

Create a disposable output directory, then run from the Dox repository:

    lua tests/export.lua ../LuaEx C:/Temp/DoxExportTest

The output directory must already exist. The suite writes sample HTML files,
Pulsar ZIP packages and Wiki Markdown there, overwriting matching test filenames.
Use a directory reserved for these tests.

The suite covers all 31 parsers with all three builders; switching formats;
HTML palettes, Prism themes, introductions and banners; custom wrappers and tags;
section ordering; inheritance; Markdown code, lists, tables and links; Unicode
and filename collisions; output preservation; and returned/raised write and close
failures. Filesystem hooks are restored before assertions are evaluated.

Run initialization checks in separate Lua processes:

    lua tests/initialization.lua ../LuaEx missing
    lua tests/initialization.lua ../LuaEx passive
    lua tests/initialization.lua ../LuaEx 2
    lua tests/initialization.lua ../LuaEx 3
    lua tests/initialization.lua ../LuaEx 4
    lua tests/initialization.lua ../LuaEx 5
    lua tests/initialization.lua ../LuaEx retry

These check the LuaEx initialization prerequisite, levels 2–5, repeated requires,
namespace preservation, absence of legacy class imports/short aliases and an
unchanged search path. The passive case supplies only the initialization flag to
prove the entry point does not validate class or enum declarations. The retry
case first fails before LuaEx initialization, then succeeds after initialization.
They write no files. Runtime startup contains no class/enum validation sections.

## Wiki output contract

The parser instance's setOutputPath is the sole destination setting. Builders receive that path;
they do not retain their own directory settings.

Select Dox.BUILDER.GITHUB_WIKI and call export with no filename to produce
Home.md, _Sidebar.md and API pages. An explicit safe filename changes the landing
page's basename. Matching files are overwritten, while unrelated and obsolete
files are not deleted. A filesystem failure can leave pages already written
before the failure; the error is reported.

Duplicate FQXNs, case-insensitive filename collisions, missing inheritance targets
and inheritance cycles are rejected before file writes. Existing HTML/Pulsar
duplicate handling remains unchanged.

The Wiki builder converts supported static HTML into Markdown. CSS, JavaScript
controls and arbitrary HTML behavior are not reproduced. Known FQXN links are
mapped to pages; unknown fragment links remain as authored.

## Verification boundaries

Local exports and Markdown parsing do not establish live GitHub rendering or an
installed Pulsar provider's behavior. Separate integration checks are required
for those environments.
## Native integration verification

`tests/export.lua` uses fully qualified Dox classes, native syntax resolution and
`.Value` enum payloads. It covers Ada as well as the other 30 parsers. The native
startup run passed all seven initialization cases and 311 filesystem export
checks, including HTML, ZIP and multi-page Wiki writes, all palettes/Prism themes,
format switching, errors/retries and preservation of unrelated output files.
Legacy Lua class modules are not required by the entry point.
