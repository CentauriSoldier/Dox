-- Run with native Lua: tests/export.lua LUAEX_REPOSITORY EXISTING_TEST_OUTPUT_DIRECTORY.
-- All filesystem writes remain inside the supplied disposable test directory.
local sLuaEx = assert(arg[1], "Supply the LuaEx repository root.");
local pOut   = assert(arg[2], "Supply an existing disposable output directory.");
local sSource = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/");
local sRoot = (sSource:match("^(.*)/") or ".").."/..";
package.path = sLuaEx.."/?.lua;"..sRoot.."/?.lua;"..package.path;

require("LuaEx.load")(5);
require("dox.init");

local Markdown = require("dox.Builders.GitHubWiki.Markdown");
local nChecks = 0;
local sTick = string.char(96);
local fOpen = io.open;


local function Check(bValue, sMessage)
    nChecks = nChecks + 1;
    assert(bValue, sMessage);
end


local function Equal(vActual, vExpected, sMessage)
    Check(vActual == vExpected, sMessage.."\nExpected: "..tostring(vExpected).."\nActual: "..tostring(vActual));
end


local function Contains(sText, sNeedle, sMessage)
    Check(sText:find(sNeedle, 1, true) ~= nil, sMessage..": missing "..sNeedle);
end


local function Fails(fAction, sNeedle)
    local bOK, sError = pcall(fAction);
    Check(not bOK, "Expected failure: "..sNeedle);
    Contains(tostring(sError), sNeedle, "Failure reason");
end


local function Read(pFile)
    local hFile = assert(fOpen(pFile, "rb"));
    local sText = hFile:read("a");
    hFile:close();
    return sText;
end


local function Import(oDocument, sBody)
    oDocument.importString("--[[!\n"..sBody.."\n!]]", DoxMime("lua"));
end


local function Document(sTitle, sBody)
    local oDocument = DoxLua(sTitle);
    oDocument.setOutputPath(pOut);
    if (sBody) then Import(oDocument, sBody); end
    return oDocument;
end


local function Identity(sText)
    return sText;
end


-- Exercise the complete immediate initializer and every registered source parser.
for _, sParser in ipairs({
    "DoxAssemblyNASM", "DoxAutoPlayMediaStudio", "DoxC", "DoxCSharp", "DoxCPlusPlus",
    "DoxCSS", "DoxDart", "DoxElm", "DoxFSharp", "DoxFortran", "DoxGo", "DoxGroovy",
    "DoxHaskell", "DoxHTML", "DoxJava", "DoxJavaScript", "DoxJulia", "DoxKotlin",
    "DoxLua", "DoxMatlab", "DoxObjectiveC", "DoxPerl", "DoxPHP", "DoxPython",
    "DoxRuby", "DoxRust", "DoxScala", "DoxSwift", "DoxTypeScript", "DoxXML",
}) do
    local oDocument = _G[sParser]("Parser Test");
    local oSyntax = oDocument.getSyntax().value;
    local sInput = oSyntax.getCommentOpen().."!\n@fqxn Parser.item\n@desc Parser content.\n@ex value = 1;\n!"..oSyntax.getCommentClose();
    local oMime;
    for _, oValue in oDocument.getMimeTypes()() do oMime = oValue; break; end
    oDocument.importString(sInput, oMime);
    for _, eBuilder in ipairs({Dox.BUILDER.HTML, Dox.BUILDER.PULSAR_LUA, Dox.BUILDER.GITHUB_WIKI}) do
        oDocument.setOutputPath(pOut);
        oDocument.setBuilder(eBuilder);
        local sPath = oDocument.export("parser-"..sParser);
        Contains(Read(sPath), eBuilder == Dox.BUILDER.HTML and "Parser content." or
                  (eBuilder == Dox.BUILDER.PULSAR_LUA and "PK" or "Parser Test"), "Parser export "..sParser);
    end
end

Equal(Markdown.decode("&lt;&amp;&#65;&#x1F600;&unknown;"), "<&A"..utf8.char(0x1f600).."&unknown;", "Entity decoding");
Equal(Markdown.decode("&#xD800;&#99999999;"), "&#xD800;&#99999999;", "Invalid numeric entities retained");
Equal(Markdown.decode("&amp;lt;"), "&lt;", "Entities decoded only once");
Equal(Markdown.attribute(' href="#A" title="B"', "href"), "#A", "Quoted attributes");
Equal(Markdown.attribute(" data-href=x href='right'", "href"), "right", "Attribute boundaries");
Contains(Markdown.convert("<strong>bold</strong> <em>italic</em>", Identity), "**bold** *italic*", "Emphasis");
Contains(Markdown.convert("<p>First</p><p>Second</p>", Identity), "First\n\nSecond", "Paragraphs");
Contains(Markdown.convert("<h3>Title</h3>", Identity), "### Title", "Headings");
Contains(Markdown.convert("<ul><li>A</li><li>B</li></ul>", Identity), "- A\n- B", "Lists");
Contains(Markdown.convert('<a href="https://example.org/a(b)">Web</a>', Identity), "[Web](https://example.org/a(b))", "Link content");
Contains(Markdown.convert('<img src="picture.png" alt="A [picture]">', Identity), "![A \\[picture\\]](picture.png)", "Images");
Contains(Markdown.convert('<pre><code class="language-lua">a &lt; b\n'..sTick:rep(3)..'</code></pre>', Identity),
         sTick:rep(4).."lua\na < b\n"..sTick:rep(3), "Safe code fences");
Contains(Markdown.convert("<code>&lt;a&gt;</code>", Identity), "<a>", "Inline code preserved");
Contains(Markdown.convert("<table><tr><th>Type</th><th>Name</th></tr><tr><td><code>A</code></td><td>x|y</td></tr></table>", Identity),
         "x\\|y", "Table pipes");
Check(not Markdown.convert("<script>bad()</script><style>bad{}</style><div>Good</div>", Identity):find("bad", 1, true), "Script/style content omitted");
Contains(Markdown.convert(sTick:rep(3).."lua\n<a href='#X'>literal</a>\n"..sTick:rep(3), Identity),
         "<a href='#X'>literal</a>", "Authored Markdown fences preserved");
Check(not Markdown.convert("<table><tr><td><code>A</code></td></tr></table>", Identity):find("\1", 1, true), "No unresolved formatting markers");

local oDocument = Document("Wiki Test", [=[
@fqxn Sample.add
@desc Adds <strong>two</strong> values. <a href="#Sample.copy">Copy</a>. [Root](#Sample).
@param number a First value.
@param number b Second value.
@ret number sum Their sum.
@note Notes stay readable.
@ex local text = "<tag>"; -- literal markup
@pulsarlua function Sample.add
]=]);
Import(oDocument, "@fqxn Sample.copy\n@inheritdoc Sample.add");
Import(oDocument, "@fqxn Sample.Spaced  Name\n@desc UTF-8 café.");
oDocument.setIntro('<h2>Welcome</h2><p>Read <a href="#Sample.add">add</a>.</p>');
oDocument.setBanner("https://example.org/banner (1).png");

-- All switching directions rebuild raw blocks for the selected format.
for _, eFirst in ipairs({Dox.BUILDER.HTML, Dox.BUILDER.PULSAR_LUA, Dox.BUILDER.GITHUB_WIKI}) do
    for _, eSecond in ipairs({Dox.BUILDER.HTML, Dox.BUILDER.PULSAR_LUA, Dox.BUILDER.GITHUB_WIKI}) do
        oDocument.setBuilder(eFirst);
        oDocument.refresh();
        oDocument.setBuilder(eSecond);
        local sFilename;
        if (eSecond ~= Dox.BUILDER.GITHUB_WIKI) then sFilename = "switch"; end
        local sPath = oDocument.export(sFilename);
        local sWritten = Read(sPath);
        if (eSecond == Dox.BUILDER.HTML) then sWritten = sWritten:gsub("\r\n", "\n"); end
        Equal(sWritten, oDocument.getOutput(), "getOutput matches file content after native text-mode translation");
        if (eSecond == Dox.BUILDER.HTML) then
            Contains(oDocument.getOutput(), "Adds", "HTML switch content");
        elseif (eSecond == Dox.BUILDER.PULSAR_LUA) then
            Contains(oDocument.getOutput(), "PK", "Pulsar switch archive");
        else
            Contains(Read(pOut.."/API-Sample.add.md"), "(API-Sample.copy)", "Cross-page HTML links");
            Contains(Read(pOut.."/API-Sample.add.md"), "(API-Sample)", "Cross-page Markdown links");
            Contains(Read(pOut.."/API-Sample.copy.md"), "First value.", "Inherited parameter docs");
            Contains(Read(pOut.."/API-Sample.add.md"), sTick:rep(3).."lua", "Source language fence");
            Contains(Read(pOut.."/API-Sample.add.md"), '"<tag>"', "Literal example markup");
            Contains(Read(pOut.."/API-Sample.Spaced~20~20Name.md"), "café", "Spaces and UTF-8 content");
            Contains(Read(pOut.."/_Sidebar.md"), "[Home](Home)", "Sidebar landing page");
            Check(not Read(pOut.."/API-Sample.add.md"):find("PulsarLua", 1, true), "Utility metadata hidden");
        end
    end
end

-- New imports are included without manually refreshing after a prior export.
Import(oDocument, "@fqxn Sample.later\n@desc Imported later.");
oDocument.setBuilder(Dox.BUILDER.GITHUB_WIKI);
oDocument.export();
Contains(Read(pOut.."/API-Sample.later.md"), "Imported later.", "Latest imported blocks");
Equal(oDocument.export("Landing"), pOut.."/Landing.md", "Custom landing page");
Contains(Read(pOut.."/_Sidebar.md"), "[Home](Landing)", "Custom home navigation");
Equal(oDocument.export("Landing #1% café"), pOut.."/Landing #1% café.md", "Special-character landing filename");
Contains(Read(pOut.."/_Sidebar.md"), "(Landing%20%231%25%20caf%C3%A9)", "Special-character landing URL");
Equal(oDocument.export("../escape"), pOut.."/Home.md", "Wiki unsafe filename fallback");
Fails(function() oDocument.export("_Sidebar"); end, "reserved");
Fails(function() oDocument.export("API-Collision"); end, "reserved");

-- Shared builders must retain neither document content nor output directories.
local oOther = Document("Other", "@fqxn Other\n@desc Other content.");
oOther.setBuilder(Dox.BUILDER.GITHUB_WIKI);
oOther.export("OtherHome");
Check(not oOther.getOutput():find("Sample", 1, true), "Other document content isolated");
oDocument.export();
Check(not oDocument.getOutput():find("Other content", 1, true), "Original document still isolated");

-- Validation happens before filesystem access.
for _, tCase in ipairs({
    {"@fqxn Duplicate\n@desc First.", "@fqxn Duplicate\n@desc Second.", "Duplicate"},
    {"@fqxn Case\n@desc Upper.", "@fqxn case\n@desc Lower.", "collision"},
    {"@fqxn Inherited\n@inheritdoc Absent", nil, "Missing"},
    {"@fqxn Cycle.A\n@inheritdoc Cycle.B", "@fqxn Cycle.B\n@inheritdoc Cycle.A", "Circular"},
}) do
    local oBad = Document("Bad", tCase[1]);
    local nOpens = 0;
    if (tCase[2]) then Import(oBad, tCase[2]); end
    oBad.setBuilder(Dox.BUILDER.GITHUB_WIKI);
    io.open = function(...) nOpens = nOpens + 1; return fOpen(...); end;
    local bOK, sError = pcall(oBad.export);
    io.open = fOpen;
    Check(not bOK, "Invalid data rejected");
    Contains(tostring(sError), tCase[3], "Validation diagnostic");
    Equal(nOpens, 0, "No writes before validation");
end

-- Existing filename fallbacks and extension/binary behavior are preserved.
local oFallback = Document("Bad/Title", "@fqxn Fallback\n@desc Fallback.");
for _, tCase in ipairs({
    {Dox.BUILDER.HTML, "index.html"},
    {Dox.BUILDER.PULSAR_LUA, "completions.zip"},
    {Dox.BUILDER.GITHUB_WIKI, "Home.md"},
}) do
    oFallback.setBuilder(tCase[1]);
    Equal(oFallback.export("../bad"), pOut.."/"..tCase[2], "Filename fallback");
end

-- Both inherited single-file export and Wiki export report all filesystem failures.
for _, eBuilder in ipairs({Dox.BUILDER.HTML, Dox.BUILDER.PULSAR_LUA, Dox.BUILDER.GITHUB_WIKI}) do
    local oFailure = Document("Failure Test", "@fqxn Failure\n@desc Failure content.");
    oFailure.setBuilder(eBuilder);
    oFailure.setOutputPath(pOut.."/nonexistent/directory");
    Fails(oFailure.export, "Error outputting Dox");
    oFailure.setOutputPath(pOut);
    for _, sFailure in ipairs({"open", "write", "write-throw", "close", "close-throw"}) do
        local bClosed = false;
        io.open = function()
            if (sFailure == "open") then return nil, "injected open"; end
            return {
                write = function()
                    if (sFailure == "write-throw") then error("injected write"); end
                    if (sFailure == "write") then return nil, "injected write"; end
                    return true;
                end,
                close = function()
                    bClosed = true;
                    if (sFailure == "close-throw") then error("injected close"); end
                    if (sFailure == "close") then return nil, "injected close"; end
                    return true;
                end,
            };
        end;
        local bOK, sError = pcall(oFailure.export);
        io.open = fOpen;
        Check(not bOK, "Injected failure is reported");
        Contains(tostring(sError), "injected", "Filesystem diagnostic");
        Equal(bClosed, sFailure ~= "open", "Opened handles closed after failure");
    end
    Check(fOpen == io.open, "Filesystem hook restored");
    local hRetry = fOpen(oFailure.export(), "rb");
    Check(hRetry ~= nil, "Successful retry after filesystem failure");
    if (hRetry) then hRetry:close(); end
end

-- Existing HTML and Pulsar inheritance rejection remains active.
for _, eBuilder in ipairs({Dox.BUILDER.HTML, Dox.BUILDER.PULSAR_LUA}) do
    local oBad = Document("Inheritance", "@fqxn Inherit\n@inheritdoc Missing");
    oBad.setBuilder(eBuilder);
    Fails(oBad.export, eBuilder == Dox.BUILDER.HTML and "does not exist" or "Missing");
end

-- Empty projects and existing destinations remain usable.
local oEmpty = Document("Empty");
oEmpty.setBuilder(Dox.BUILDER.GITHUB_WIKI);
oEmpty.export("EmptyHome");
Contains(oEmpty.getOutput(), "## API", "Empty project landing page");

-- Static HTML and raw Markdown content retain their distinct whitespace/code rules.
Contains(Markdown.convert("<ol><li>One<ul><li>Nested</li></ul></li><li>Two</li></ol>", Identity),
         "    - Nested", "Nested HTML lists");
Contains(Markdown.convert("<ol><li>One</li><li>Two</li></ol>", Identity), "2. Two", "Ordered HTML lists");
Equal(Markdown.convert("- Parent\n    - Child", Identity), "- Parent\n    - Child", "Authored Markdown indentation");
Contains(Markdown.convert(sTick.."<script>literal</script>"..sTick, Identity), "<script>literal</script>", "Script text inside Markdown code");
Contains(Markdown.convert("<pre><code>&lt;script&gt;literal&lt;/script&gt;</code></pre>", Identity),
         "<script>literal</script>", "Script text inside HTML code");
Equal(Markdown.attribute(" href=https://example.org/", "href"), "https://example.org/", "Unquoted URL trailing slash");
Contains(Markdown.convert("<ul><li><p>Paragraph item</p></li></ul>", Identity), "- Paragraph item", "HTML paragraph inside list item");
local sMarkerText = "\1DOX1\2";
Contains(Markdown.convert(sMarkerText.."<code>safe</code>", Identity), sMarkerText, "Authored marker-like text preserved");

-- Builder configuration APIs, all page palettes and every Prism theme remain usable.
local Themes = require("dox.Builders.HTML.Themes");
local oThemes = Document("Themes", "@fqxn Themes\n@desc Theme content.\n@ex local theme = true;");
for _, sName in ipairs({
    "ALUCARD", "CATPPUCCIN_FRAPPE", "CATPPUCCIN_LATTE", "CATPPUCCIN_MACCHIATO", "CATPPUCCIN_MOCHA",
    "DRACULA", "GRUVBOX_DARK", "GRUVBOX_LIGHT", "MIDNIGHT_BLUE", "NORD", "ROSE_PINE",
    "ROSE_PINE_DAWN", "ROSE_PINE_MOON", "SOLARIZED_DARK", "SOLARIZED_LIGHT", "SYNTHWAVE_PROTOCOL",
    "TOKYO_NIGHT", "TOKYO_NIGHT_MOON", "TOKYO_NIGHT_STORM", "ZENBURN",
}) do
    oThemes.setTheme(Dox.THEME[sName]);
    oThemes.export("theme");
    Contains(oThemes.getOutput(), Themes[Dox.THEME[sName].value].css, "HTML palette "..sName);
end
for _, sName in ipairs({"COY", "DARK", "DEFAULT", "FUNKY", "OKAIDIA", "SOLARIZED_LIGHT", "TOMORROW_NIGHT", "TWILIGHT"}) do
    oThemes.setPrismTheme(Dox.PRISM[sName]);
    oThemes.export("prism");
    Contains(oThemes.getOutput(), Dox.PRISM[sName].value..".min.css", "Prism palette "..sName);
end
oThemes.setIntro("<p>Introduction marker.</p>");
oThemes.setBanner("missing-image.png");
oThemes.export("presentation");
Contains(oThemes.getOutput(), "Introduction marker.", "HTML introduction");
Contains(oThemes.getOutput(), "Banner image unavailable", "HTML banner fallback");
oThemes.setIntro("");
oThemes.setBanner("");
oThemes.export("presentation");
Check(not oThemes.getOutput():find("Introduction marker.", 1, true), "HTML introduction cleared");
Check(not oThemes.getOutput():find('src="missing-image.png"', 1, true), "HTML banner cleared");

local oWrappers = DoxBuilderHTML();
oWrappers.setColumnWrapper("Custom", 1, "<b>", "</b>");
Equal(oWrappers.getColumnWrapper("Custom", 1)[1], "<b>", "Custom wrappers");
local tCopy = oWrappers.getColumnWrapper("Custom", 1);
tCopy[1] = "changed";
Equal(oWrappers.getColumnWrapper("Custom", 1)[1], "<b>", "Wrapper copy isolation");
Fails(function() oWrappers.setColumnWrapper("Custom", 3, "", ""); end, "out of bounds");
oWrappers.clearColumnWrappers("Custom");
Equal(oWrappers.getColumnWrapperCount("Custom"), 0, "Named wrapper clearing");
Check(oWrappers.getColumnWrapperCount("Parameter(s)") > 0, "Unrelated wrappers preserved");
oWrappers.clearColumnWrappers();
Equal(oWrappers.getColumnWrapperCount("Parameter(s)"), 0, "All wrapper clearing");

-- Custom multi-column tags and direct builder APIs use the same raw block model.
local tTags = clone(require("dox.Statics.BuiltInBlockTags"));
tTags[#tTags + 1] = DoxBlockTag({"custom"}, "Custom Fields", false, true, true, false, 2);
local oBlock = DoxBlock("@fqxn Custom.item\n@custom string name First custom field.\n@custom number count Second custom field.",
                        Dox.SYNTAX.LUA, "@", tTags, {tTags[1]});
local oWiki = DoxBuilderGitHubWiki();
local tData = oWiki.refresh({oBlock}, function() error("Wiki must not invoke the HTML formatter."); end);
local tFiles = oWiki.build("Custom", "", tData, nil, "", nil, Dox.SYNTAX.LUA);
Contains(tFiles["API-Custom.item.md"], "First custom field.", "Custom tag description");
Contains(tFiles["API-Custom.item.md"], "Second custom field.", "Repeated custom tag");
local _, nHeadings = tFiles["API-Custom.item.md"]:gsub("## Custom Fields", "");
Equal(nHeadings, 1, "Combined custom tag heading");
Check(not tFiles["API-Custom.item.md"]:find("\1", 1, true), "Custom content markers resolved");

local oOrder = Document("Ordered", "@fqxn Ordered\n@desc OrderedDescription\n@ex OrderedExample");
oOrder.setBuilder(Dox.BUILDER.GITHUB_WIKI);
oOrder.setBlockTagOrder({"ex", "desc"});
oOrder.export();
local sOrdered = Read(pOut.."/API-Ordered.md");
Check(sOrdered:find("OrderedExample", 1, true) < sOrdered:find("OrderedDescription", 1, true), "Custom tag order");
oOrder.setBlockTagOrder(nil);
oOrder.export();
sOrdered = Read(pOut.."/API-Ordered.md");
Check(sOrdered:find("OrderedDescription", 1, true) < sOrdered:find("OrderedExample", 1, true), "Tag order reset");
Fails(function() oOrder.setBlockTagOrder({"desc", "description"}); end, "repeated");
Fails(function() oOrder.setBuilder("HTML"); end, "Expected type");

-- Multi-level inheritance works in all output systems.
local oChain = Document("Chain", "@fqxn Chain.A\n@inheritdoc Chain.B");
Import(oChain, "@fqxn Chain.B\n@inheritdoc Chain.C");
Import(oChain, "@fqxn Chain.C\n@desc ChainDescription\n@param string value ChainParameter");
for _, eBuilder in ipairs({Dox.BUILDER.HTML, Dox.BUILDER.PULSAR_LUA, Dox.BUILDER.GITHUB_WIKI}) do
    oChain.setBuilder(eBuilder);
    local sPath = oChain.export("chain");
    Contains(Read(sPath), eBuilder == Dox.BUILDER.PULSAR_LUA and "PK" or
             (eBuilder == Dox.BUILDER.GITHUB_WIKI and "Chain" or "ChainDescription"), "Inheritance chain export");
    if (eBuilder == Dox.BUILDER.GITHUB_WIKI) then
        Contains(Read(pOut.."/API-Chain.A.md"), "ChainParameter", "Resolved Wiki inheritance chain");
    end
end

-- Page mapping remains injective for UTF-8, percent signs, tildes and spaces.
local oNames = Document("Names", "@fqxn Names.café\n@desc Unicode name.");
Import(oNames, "@fqxn Names.a%20b\n@desc Literal percent.");
Import(oNames, "@fqxn Names.a b\n@desc Actual space.");
Import(oNames, "@fqxn Names.a~20b\n@desc Literal tilde.");
Import(oNames, '@fqxn Names.link\n@desc <a href="#Names.a%20b">Encoded space</a> <a href="https://example.org/a(b)">External</a>');
oNames.setBuilder(Dox.BUILDER.GITHUB_WIKI);
oNames.export("names");
Contains(Read(pOut.."/API-Names.caf~C3~A9.md"), "Unicode name.", "UTF-8 page name");
Contains(Read(pOut.."/API-Names.a~2520b.md"), "Literal percent.", "Percent page name");
Contains(Read(pOut.."/API-Names.a~20b.md"), "Actual space.", "Space page name");
Contains(Read(pOut.."/API-Names.a~7E20b.md"), "Literal tilde.", "Tilde page name");
Contains(Read(pOut.."/API-Names.link.md"), "(API-Names.a~20b)", "Percent-encoded FQXN link");
Contains(Read(pOut.."/API-Names.link.md"), "https://example.org/a%28b%29", "External URL escaping");

local hKeep = assert(fOpen(pOut.."/keep.txt", "wb"));
hKeep:write("Keep this content.");
hKeep:close();
oNames.export("names");
Equal(Read(pOut.."/keep.txt"), "Keep this content.", "Unrelated output files preserved");
local sPrevious = oNames.getOutput();
oNames.setOutputPath(pOut.."/nonexistent");
Fails(oNames.export, "Error outputting Dox");
Equal(oNames.getOutput(), sPrevious, "Last successful output retained after failure");
oNames.setOutputPath(pOut);
oNames.export("names");
Fails(function()
    local oLong = Document("Long", "@fqxn "..string.rep("A", 250).."\n@desc Long.");
    oLong.setBuilder(Dox.BUILDER.GITHUB_WIKI);
    oLong.export();
end, "exceeds");

print("PASS: "..nChecks.." native export checks.");