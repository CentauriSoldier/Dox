![DOX](assets/dox_title.png)

# Dox

Write documentation beside your code, then publish it for the browser and your
editor. Dox reads structured source comments and turns them into HTML
documentation or a Pulsar autocomplete package.

Keep explanations, parameters, return values and examples next to the code they
describe. The same comments can give someone a page to read and useful
information while they write code.

## Native migration in progress

`Dox.DoxMime`, `Dox.DoxSyntax`, `Dox.DoxBlockTag` and `Dox.DoxBlock` are native
LXC components. `Dox.DoxBuilder` is also native, with an embedded LXE `MIME`
enum. `Dox.DoxBuilderPulsarLua` is the first native concrete builder; completion
data and ZIP packaging retain the original output. `Dox.DoxBuilderGitHubWiki`
is also native, preserving Wiki page manifests and multi-file export.
`Dox.DoxBuilderHTML` now uses native theme identities and cached syntax resolution
while retaining its templates, Prism assets and HTML output. LuaEx discovers
their `.lxc` sources under `dox` when the Dox root is on `package.path`
before initialization. `Dox.PRISM`, `Dox.THEME` and `Dox.SYNTAX` now have native
LXE declarations. Syntax values contain immutable data; resolve the cached syntax
object with `Dox.DoxSyntax.fromEnum(Dox.SYNTAX.LUA)` instead of calling getters on
`.Value`. `Dox.Parser` is the native base for language-specific parsers, replacing
the legacy class named Dox. `Dox.BUILDER` values are builder class names; use
`Dox.Parser.resolveBuilder(Dox.BUILDER.HTML)` to obtain the shared builder instance.
`Dox.OUTPUT.HTML` retains its numeric value of 1. Built-in tag creation now uses
the native tag class and is deferred until a parser instance is constructed.
`Dox.DoxLua` is now a native Lua parser derived from `Dox.Parser`, preserving
Lua bracket preprocessing and its PulsarLua utility tag. Its preprocessing callback
is supplied by `dox/Parsers/LuaPreprocessor.lua` for native graph persistence.
`Dox.DoxAutoPlayMediaStudio` is also native, preserving identity preprocessing for
`.lua` and single-pass HTML entity decoding for `.autoplay` through
`dox/Parsers/AutoPlayPreprocessor.lua`.
`Dox.DoxAssemblyNasm` is native, retaining `.asm` identity preprocessing,
ASSEMBLY_NASM syntax and the original delimiter/highlighting settings.
The remaining language parsers and legacy entry point still await migration;
active Lua class originals are retained. See [HANDOFF.md](HANDOFF.md) for status.

## One source, two destinations

**HTML documentation** brings documented names, descriptions and examples
together in a browsable page, with links, syntax highlighting and configurable
page and code themes.

**Pulsar packages** bring documented names, descriptions, arguments, return
types and fields into the editor. Dox generates a ZIP package for use with
`autocomplete-lua` or `autocomplete-luaex`.

## Write the documentation where it belongs

For Lua, put a Dox block inside a `--[[! … !]]` comment. Use `@fqxn` to give
the documented item its fully qualified name; add the details a reader needs.

Save this example as `MyLibrary.lua`:

```lua
local MyLibrary = {};

--[[!
@fqxn MyLibrary.add
@desc Adds two numbers.
@param number a The first number.
@param number b The second number.
@return number sum The total.
@ex MyLibrary.add(2, 3)
@pulsarlua function MyLibrary.add
!]]
function MyLibrary.add(a, b)
    return a + b;
end

return MyLibrary;
```

`@fqxn` gives Dox its document hierarchy. Descriptions, parameters, returns,
examples, notes and other tags fill in the entry. The optional `@pulsarlua`
declaration tells the Pulsar builder what kind of Lua symbol it describes.

Dox also includes parsers for other source languages. Each parser supplies its
language's comment syntax and file extensions; the documentation tags stay
familiar.

## Generate a page

Dox depends on [LuaEx](https://github.com/CentauriSoldier/LuaEx).
Place the `LuaEx` and lowercase `dox` folders on your Lua module search path,
keeping their subfolders intact. Initialize LuaEx first, then require Dox once.

Create the output directory before exporting. With `MyLibrary.lua` and an
existing `docs` directory, this script generates `docs/MyLibrary.html`:

```lua
local initLuaEx = require("LuaEx.load");
initLuaEx();
require("dox.init");

local document = DoxLua("MyLibrary");
document.setOutputPath("docs");
document.importFiles({"MyLibrary.lua"});
document.refresh();
document.export("MyLibrary");
```

Import the files you want to document, refresh the collected entries, and export
the result. HTML is the default output.

## Take it into Pulsar

To produce a Pulsar package from the same document, switch builders:

```lua
document.setBuilder(Dox.BUILDER.PULSAR_LUA);
document.export("MyLibrary");
```

This writes `docs/MyLibrary.zip`. Unpack it into Pulsar's packages directory,
preserving the generated package folder, then reload Pulsar. Enable
`autocomplete-lua` or `autocomplete-luaex` to use the package's documented
options-provider service.

The package uses the types and signatures you document. It does not execute
your source to infer missing information.

## Make the output your own

Choose a page palette and a Prism highlighting theme, add a banner, or arrange
documentation sections in the order that suits your project. Parsers, block
tags and builders are separate components, with the implementation and API
documentation available here:

- [Dox API and output settings](dox/Dox.lua)
- [Built-in documentation tags](dox/Statics/BuiltInBlockTags.lua)
- [Language parsers](dox/Parsers/)
- [HTML builder](dox/Builders/HTML/DoxBuilderHTML.lua) and
  [page themes](dox/Builders/HTML/Themes.lua)
- [Pulsar Lua builder](dox/Builders/Pulsar/Lua/DoxBuilderPulsarLua.lua)

---

Released into the public domain under the [Unlicense](LICENSE).

**Credits:** [Logo](https://cooltext.com/) ·
[Decorative lettering](https://fsymbols.com/generators/carty/) ·
[Background artwork](https://www.vecteezy.com/free-vector/space)
