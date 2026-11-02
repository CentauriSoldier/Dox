-- Native Dox catalogs and lazy syntax/builder resolution.
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
local catalogEnvironment=setmetatable({DoxSyntax=function(...)return table.pack(...);end,
    enum=function(name,names,values)return {names=names,values=values};end},{__index=_G});
local catalog=assert(loadfile(pDox.."/legacy/dox/Statics/DoxSyntaxEnum.lua","t",catalogEnvironment))();
check(lxe.isEnum(Dox.SYNTAX) and #Dox.SYNTAX==30,"native syntax member count");
local keys={"name","commentOpen","commentClose","escapeCharacter","prismName"};
local getters={"getName","getCommentOpen","getCommentClose","getEscapeCharacter","getPrismName"};
local previous;
for index,member in Dox.SYNTAX()do
    check(member.Name==catalog.names[index] and member.Ordinal==index,"syntax member names/order");
    check(lxe.isMember(member,Dox.SYNTAX),"canonical syntax membership");
    local resolved=Dox.DoxSyntax.fromEnum(member);
    check(class.isinstanceof(resolved,Dox.DoxSyntax),"resolved native syntax identity");
    check(rawequal(resolved,Dox.DoxSyntax.fromEnum(member)),"one cached object per member");
    check(not previous or not rawequal(previous,resolved),"distinct objects for distinct members");previous=resolved;
    for field,key in ipairs(keys)do
        check(member.Value[key]==catalog.values[index][field],"original syntax data bytes");
        check(resolved[getters[field]]()==catalog.values[index][field],"original syntax getter behavior");
    end
    check(not pcall(function()member.Value.name="changed";end),"syntax data remains read-only");
    check(rawequal(deserialize(serialize(member)),member),"canonical syntax save/load");
    check(rawequal(Dox.DoxSyntax.fromEnum(deserialize(serialize(member))),resolved),"restored member reuses cached object");
end
local LXC=require("LuaEx.lib.lxc");
LXC.loadSources({["SyntaxDataTest.lxe"]=[=[namespace SyntaxDataTest {
    public enum DATA { BAD = {name="Incomplete"}; }
}]=]},_G);
check(not pcall(Dox.DoxSyntax.fromEnum,SyntaxDataTest.DATA.BAD),"invalid syntax data rejected");
check(not pcall(Dox.DoxSyntax.fromEnum,SyntaxDataTest.DATA),"enum roots rejected");
check(not pcall(Dox.DoxSyntax.fromEnum,{}),"nonmembers rejected");
check(Dox.DoxSyntax.fromEnum(Dox.SYNTAX.FORTRAN).getCommentClose()=="\n","newline terminator preserved");
local builderNames={"HTML","PULSAR_LUA","GITHUB_WIKI"};
local builderClasses={"Dox.DoxBuilderHTML","Dox.DoxBuilderPulsarLua","Dox.DoxBuilderGitHubWiki"};
check(lxe.isEnum(Dox.BUILDER) and #Dox.BUILDER==3,"builder member count");
for index,member in Dox.BUILDER()do
    check(member.Name==builderNames[index] and member.Ordinal==index,"builder names/order");
    check(member.Value==builderClasses[index],"builder class identity payload");
    check(lxe.isMember(member,Dox.BUILDER),"builder membership");
    local resolved=Dox.Parser.resolveBuilder(member);
    check(class.isinstanceof(resolved,class.getbyname(builderClasses[index])),"resolved concrete builder");
    check(rawequal(resolved,Dox.Parser.resolveBuilder(member)),"one shared builder per member");
    check(rawequal(clone(member),member) and rawequal(deserialize(serialize(member)),member),"builder canonical save/clone");
    check(rawequal(resolved,Dox.Parser.resolveBuilder(deserialize(serialize(member)))),"restored member reuses builder");
end
for _,invalid in ipairs({Dox.BUILDER,Dox.SYNTAX.LUA,Dox.PRISM.OKAIDIA,{},false,"HTML"})do
    check(not pcall(Dox.Parser.resolveBuilder,invalid),"invalid builder selection rejected");
end
check(not pcall(Dox.Parser.resolveBuilder,nil),"nil builder rejected");
check(lxe.isEnum(Dox.OUTPUT) and #Dox.OUTPUT==1,"output enum count");
check(Dox.OUTPUT.HTML.Name=="HTML" and Dox.OUTPUT.HTML.Ordinal==1 and Dox.OUTPUT.HTML.Value==1,"original output name/order/numeric value");
check(rawequal(deserialize(serialize(Dox.OUTPUT.HTML)),Dox.OUTPUT.HTML),"output canonical persistence");
print("PASS Dox enums/syntax resolution: "..checks.." checks.");
