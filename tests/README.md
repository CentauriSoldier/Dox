# Dox exporter regression tests

Use native Lua with the current LuaEx checkout. The completed native
run for this change used Lua 5.4.9 on Windows. Other hosts and Lua versions have
not been verified by that run.

Create a disposable output directory, then run from the Dox repository:

    lua tests/export.lua ../LuaEx C:/Temp/DoxExportTest

The output directory must already exist. The suite writes sample HTML files,
Pulsar ZIP packages and Wiki Markdown there, overwriting matching test filenames.
Use a directory reserved for these tests.

The suite covers all 30 parsers with all three builders; switching formats;
HTML palettes, Prism themes, introductions and banners; custom wrappers and tags;
section ordering; inheritance; Markdown code, lists, tables and links; Unicode
and filename collisions; output preservation; and returned/raised write and close
failures. Filesystem hooks are restored before assertions are evaluated.

Run initialization checks in separate Lua processes:

    lua tests/initialization.lua ../LuaEx missing
    lua tests/initialization.lua ../LuaEx 0
    lua tests/initialization.lua ../LuaEx 1
    lua tests/initialization.lua ../LuaEx 2
    lua tests/initialization.lua ../LuaEx 3
    lua tests/initialization.lua ../LuaEx 4
    lua tests/initialization.lua ../LuaEx 5
    lua tests/initialization.lua ../LuaEx retry

These check prerequisite rejection, supported class-load levels, repeated imports
and package-path restoration/retry after a failed Wiki-builder import. They write
no files.

## Wiki output contract

Dox.setOutputPath is the sole destination setting. Builders receive that path;
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