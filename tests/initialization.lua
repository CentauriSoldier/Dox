-- Run each case in a fresh native process: tests/initialization.lua LUAEX_REPOSITORY CASE.
-- CASE is missing, 0 through 5, or retry. No files are written.
local sLuaEx = assert(arg[1]);
local sCase = assert(arg[2]);
local sSource = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/");
local sRoot = (sSource:match("^(.*)/") or ".").."/..";
package.path = sLuaEx.."/?.lua;"..sRoot.."/?.lua;"..package.path;

if (sCase ~= "missing") then
    require("LuaEx.load")(tonumber(sCase) or 5);
end

local sPath = package.path;
if (sCase == "missing" or sCase == "0" or sCase == "1") then
    local bOK, sError = pcall(require, "dox.init");
    assert(not bOK, "Initialization should reject missing dependencies.");
    assert(tostring(sError):find(sCase == "missing" and "Initialize LuaEx" or "level 2", 1, true));
elseif (sCase == "retry") then
    package.preload["dox.Builders.GitHubWiki.DoxBuilderGitHubWiki"] = function()
        error("injected Wiki import failure");
    end;
    local bOK, sError = pcall(require, "dox.init");
    assert(not bOK and tostring(sError):find("injected Wiki", 1, true));
    assert(package.path == sPath, "Path not restored after initialization failure.");
    package.preload["dox.Builders.GitHubWiki.DoxBuilderGitHubWiki"] = nil;
    require("dox.init");
    assert(Dox.BUILDER.GITHUB_WIKI.value.getName() == "DoxBuilderGitHubWiki");
else
    require("dox.init");
    assert(Dox.BUILDER.HTML.value.getName() == "DoxBuilderHTML");
    assert(Dox.BUILDER.PULSAR_LUA.value.getName() == "DoxBuilderPulsarLua");
    assert(Dox.BUILDER.GITHUB_WIKI.value.getName() == "DoxBuilderGitHubWiki");
    local vFirst = require("dox.init");
    assert(vFirst == require("dox.init"), "Repeated require was not cached.");
end

assert(package.path == sPath, "Initialization changed package.path.");
print("PASS: initialization "..sCase..".");