-- Run each case in a fresh process: tests/initialization.lua LUAEX_REPOSITORY CASE.
-- CASE is missing, passive, 2 through 5, or retry. No files are written.
local sLuaEx = assert(arg[1]);
local sCase = assert(arg[2]);
local sSource = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/");
local sRoot = (sSource:match("^(.*)/") or ".").."/..";
package.path = sLuaEx.."/?.lua;"..sRoot.."/?.lua;"..package.path;
local sPath = package.path;

if (sCase == "missing" or sCase == "retry") then
    local bOK, sError = pcall(require, "dox.init");
    assert(not bOK and tostring(sError):find("Initialize LuaEx", 1, true));
    assert(package.path == sPath, "Failed require changed package.path.");
    assert(not package.loaded["dox.init"], "Failed require was cached.");
end

if (sCase == "passive") then
    -- No class/enum environment is provided: entry-point code must not inspect it.
    _G.LUAEX_INIT = true;
elseif (sCase ~= "missing") then
    require("LuaEx.load")(tonumber(sCase) or 5);
end

if (sCase ~= "missing") then
    local oNamespace = rawget(_G, "Dox");
    local tLegacy = {
        "dox.Dox", "dox.Components.DoxMime", "dox.Components.DoxSyntax",
        "dox.Components.DoxBlockTag", "dox.Components.DoxBlock", "dox.Components.DoxBuilder",
        "dox.Builders.HTML.DoxBuilderHTML", "dox.Builders.Pulsar.Lua.DoxBuilderPulsarLua",
        "dox.Builders.GitHubWiki.DoxBuilderGitHubWiki", "dox.Parsers.DoxLua",
    };
    for _, sModule in ipairs(tLegacy) do
        package.preload[sModule] = function() error("Legacy import must not run: "..sModule); end;
    end
    local vFirst = require("dox.init");
    assert(vFirst == true and vFirst == require("dox.init"), "Require caching changed.");
    assert(rawequal(oNamespace, rawget(_G, "Dox")), "Entry point replaced the namespace.");
    for _, sModule in ipairs(tLegacy) do assert(not package.loaded[sModule], "Legacy class imported."); end
    for _, sName in ipairs({"DoxLua", "DoxMime", "DoxSyntax", "DoxBlockTag", "DoxBlock",
        "DoxBuilder", "DoxBuilderHTML", "DoxBuilderPulsarLua", "DoxBuilderGitHubWiki", "DoxAssemblyNASM"}) do
        assert(rawget(_G, sName) == nil, "Unexpected short alias: "..sName);
    end
    if (sCase ~= "passive") then
        local oDocument = Dox.DoxLua("Startup test");
        assert(oDocument.getName() == "DoxLua");
        assert(Dox.Parser.resolveBuilder(Dox.BUILDER.HTML).getName() == "DoxBuilderHTML");
        assert(Dox.Parser.resolveBuilder(Dox.BUILDER.PULSAR_LUA).getName() == "DoxBuilderPulsarLua");
        assert(Dox.Parser.resolveBuilder(Dox.BUILDER.GITHUB_WIKI).getName() == "DoxBuilderGitHubWiki");
    end
end

assert(package.path == sPath, "Entry point changed package.path.");
print("PASS: initialization "..sCase..".");
