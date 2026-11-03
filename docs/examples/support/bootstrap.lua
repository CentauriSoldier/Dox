--[[!
@fqxn Examples.Bootstrap
@desc Locates this checkout and sibling LuaEx before native declaration discovery.
!]]
local sFile = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/");
local pDocs = assert(sFile:match("^(.*)/examples/support/bootstrap%.lua$"));
local pRepository = pDocs.."/..";
package.path = pDocs.."/?.lua;"..pRepository.."/?.lua;"..pRepository.."/../LuaEx/?.lua;"..package.path;
-- Supply Lua 5.4's two-argument atan under the name captured by line.
if (not LUAEX_INIT) then
    math.atan2 = math.atan2 or math.atan;
    require("LuaEx.init");
end
require("dox.init");
return {docs = pDocs, repository = pRepository};
