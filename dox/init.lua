--[[!
@fqxn Dox.init
@desc Dox package entry point after LuaEx initialization. Native declarations are
    discovered by LuaEx from package.path; this module does not load classes,
    validate declarations, publish aliases or change package.path. Require is cached.
@throws LUAEX_INIT is not exactly true.
@ex require("dox.init");
!]]
assert(_G.LUAEX_INIT == true, "Initialize LuaEx before loading Dox.");
