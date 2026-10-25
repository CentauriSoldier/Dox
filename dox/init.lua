-- Initialize Dox immediately when this module is required.
local _G        = _G;
local assert    = assert;
local debug     = debug;
local error     = error;
local package   = package;
local pcall     = pcall;
local require   = require;

--[[!
@fqxn Dox.init
@desc Initializes Dox components, builders and parsers in one require call, after LuaEx. No initializer function or configuration options are returned. Lua caches the module after successful initialization.
@throws LUAEX_INIT is not exactly true, class/collection dependencies are absent, or a module fails to load. Failed initialization may leave loaded modules/globals; package.path is restored.
@ex require("dox.init");
!]]
assert(_G.LUAEX_INIT == true, "Initialize LuaEx before loading Dox.");
assert(_G.class and _G.SortedDictionary,
       "Dox requires LuaEx class-load level 2 or higher.");

local sSource = debug.getinfo(1, "S").source;
local pSourceDirectory = sSource:match("^@(.+)[/\\][^/\\]+$") or ".";
local sOriginalPackagePath = package.path;

package.path = package.path..";"..pSourceDirectory.."/../?.lua";
local bSuccess, sError = pcall(function()
    local pDox              = "dox";
    local pDoxBuilders      = pDox..".Builders";
    local pDoxComponents    = pDox..".Components";
    local pDoxParsers       = pDox..".Parsers";

    --dox and dox component classes
    DoxMime         = require(pDoxComponents..".DoxMime");
    DoxSyntax       = require(pDoxComponents..".DoxSyntax");
    DoxBlockTag     = require(pDoxComponents..".DoxBlockTag");
    DoxBlock        = require(pDoxComponents..".DoxBlock");
    DoxBuilder      = require(pDoxComponents..".DoxBuilder");

    --require Dox Builders
    DoxBuilderHTML      = require(pDoxBuilders..".HTML.DoxBuilderHTML");
    DoxBuilderPulsarLua = require(pDoxBuilders..".Pulsar.Lua.DoxBuilderPulsarLua");

    --require Dox and Dox parsers (subclasses)
    Dox                     = require(pDox..".Dox");
    DoxAssemblyNASM         = require(pDoxParsers..".DoxAssemblyNasm");
    DoxAutoPlayMediaStudio  = require(pDoxParsers..".DoxAutoPlayMediaStudio");
    DoxC                    = require(pDoxParsers..".DoxC");
    DoxCSharp               = require(pDoxParsers..".DoxCSharp");
    DoxCPlusPlus            = require(pDoxParsers..".DoxCPlusPlus");
    DoxCSS                  = require(pDoxParsers..".DoxCSS");
    DoxDart                 = require(pDoxParsers..".DoxDart");
    DoxElm                  = require(pDoxParsers..".DoxElm");
    DoxFSharp               = require(pDoxParsers..".DoxFSharp");
    DoxFortran              = require(pDoxParsers..".DoxFortran");
    DoxGo                   = require(pDoxParsers..".DoxGo");
    DoxGroovy               = require(pDoxParsers..".DoxGroovy");
    DoxHaskell              = require(pDoxParsers..".DoxHaskell");
    DoxHTML                 = require(pDoxParsers..".DoxHTML");
    DoxJava                 = require(pDoxParsers..".DoxJava");
    DoxJavaScript           = require(pDoxParsers..".DoxJavaScript");
    DoxJulia                = require(pDoxParsers..".DoxJulia");
    DoxKotlin               = require(pDoxParsers..".DoxKotlin");
    DoxLua                  = require(pDoxParsers..".DoxLua");
    DoxMatlab               = require(pDoxParsers..".DoxMatlab");
    DoxObjectiveC           = require(pDoxParsers..".DoxObjectiveC");
    DoxPerl                 = require(pDoxParsers..".DoxPerl");
    DoxPHP                  = require(pDoxParsers..".DoxPHP");
    DoxPython               = require(pDoxParsers..".DoxPython");
    DoxRuby                 = require(pDoxParsers..".DoxRuby");
    DoxRust                 = require(pDoxParsers..".DoxRust");
    DoxScala                = require(pDoxParsers..".DoxScala");
    DoxSwift                = require(pDoxParsers..".DoxSwift");
    DoxTypeScript           = require(pDoxParsers..".DoxTypeScript");
    DoxXML                  = require(pDoxParsers..".DoxXML");

end);
package.path = sOriginalPackagePath;
if (not bSuccess) then
    error(sError, 0);
end
