-- Native string-valued Dox enums; class-valued SYNTAX remains blocked.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local checks=0;
local function check(condition,message)assert(condition,message);checks=checks+1;end
local file=assert(io.open(pDox.."/legacy/dox/Dox.lua","rb"));local source=file:read("*a");file:close();
for _,name in ipairs({"PRISM","THEME"})do
    local names,values=source:match(name..'%s*=%s*enum%("Dox%.'..name..'",%s*(%b{}),%s*(%b{})');
    assert(names and values,"Missing original enum "..name);
    local oldNames,oldValues=assert(load("return "..names..","..values,"original-enum-literals","t",{}))();
    local collection=Dox[name];check(lxe.isEnum(collection) and #collection==#oldNames,"member count");
    for index,member in collection()do
        check(member.Name==oldNames[index] and member.Ordinal==index,"member name/order");
        check(member.Value==oldValues[index],"payload bytes");
        check(rawequal(collection[oldNames[index]],member) and lxe.isMember(member,collection),"canonical membership");
        check(rawequal(clone(member),member) and rawequal(deserialize(serialize(member)),member),"canonical clone/persistence");
        check(not pcall(function()member.Value="changed";end),"immutable member payload binding");
    end
end
check(Dox.PRISM.OKAIDIA.Value=="prism-okaidia","Prism default identity/value preserved");
check(Dox.THEME.MIDNIGHT_BLUE.Value=="midnight_blue","page default identity/value preserved");
check(rawget(Dox,"SYNTAX")==nil,"class-valued syntax migration is explicitly pending");
print("PASS Dox theme enums: "..checks.." checks; SYNTAX pending class-payload support.");
