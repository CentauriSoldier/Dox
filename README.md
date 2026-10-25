![DOX](assets/dox_title.png)

# Dox

Write documentation beside your code, then publish it for the browser and your
editor. Dox reads structured source comments and turns them into HTML
documentation or a Pulsar autocomplete package.

Keep explanations, parameters, return values and examples next to the code they
describe. The same comments can give someone a page to read and useful
information while they write code.

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
