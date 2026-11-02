-- Native DoxSyntax versus archived methods and all existing syntax definitions.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local Syntax=Dox.DoxSyntax;local checks=0;
local function check(condition,message) assert(condition,message);checks=checks+1;end
local function reject(action,fragment)
    local ok,err=pcall(action);
    check(not ok and (not fragment or tostring(err):find(fragment,1,true)),
        "Expected rejection "..tostring(fragment)..", got "..tostring(err));
end
local environment=setmetatable({class=function(name,meta,static,private,protected,public)
    return function(...)
        local object={};local data={pri={}};
        for method,fn in pairs(public) do
            if method~=name then object[method]=function(...) return fn(object,data,...);end;end
        end
        public[name](object,data,...);return object;
    end;
end},{__index=_G});
local Reference=assert(loadfile(pDox.."/legacy/dox/Components/DoxSyntax.lua","t",environment))();
local catalogEnvironment=setmetatable({DoxSyntax=function(...) return table.pack(...);end,
    enum=function(name,names,values) return {names=names,values=values};end},{__index=_G});
local catalog=assert(loadfile(pDox.."/dox/Statics/DoxSyntaxEnum.lua","t",catalogEnvironment))();
check(class.is(Syntax) and class.getname(Syntax)=="Dox.DoxSyntax","native discovery");
check(rawget(_G,"DoxSyntax")==nil,"no global alias");
check(#catalog.names==30 and #catalog.values==30,"all existing enum payload definitions captured without a legacy enum");
local methods={"getName","getCommentOpen","getCommentClose","getEscapeCharacter","getEscapeCharater","getPrismName"};
for index,args in ipairs(catalog.values) do
    local native,old=Syntax(table.unpack(args,1,args.n)),Reference(table.unpack(args,1,args.n));
    for _,method in ipairs(methods) do check(native[method]()==old[method](),catalog.names[index].." "..method);end
    check(native.getEscapeCharacter()==native.getEscapeCharater(),"existing misspelled getter remains");
    local copied=clone(native);local loaded=deserialize(serialize(native));
    check(not rawequal(copied,native) and class.isinstanceof(copied,Syntax),"native clone identity");
    for _,method in ipairs(methods) do
        check(copied[method]()==native[method]() and loaded[method]()==native[method](),"native clone/restore preserves syntax bytes");
    end
end
local function valid() return {"Lua","--[[","]]","\\","lua"};end
for _,closing in ipairs({"\n","\r\n"," ","\t","END","*/"}) do
    local args=valid();args[3]=closing;
    check(Syntax(table.unpack(args)).getCommentClose()==Reference(table.unpack(args)).getCommentClose(),"nonempty whitespace closing delimiters remain valid");
end
for field=1,5 do
    for _,bad in ipairs({false,1,{},null,""}) do
        local args=valid();args[field]=bad;
        local okNative=pcall(Syntax,table.unpack(args,1,5));
        local okOld=pcall(Reference,table.unpack(args,1,5));
        check(not okNative and okNative==okOld,"archived invalid argument rejection");
    end
    local args=valid();args[field]=nil;
    check(not pcall(Syntax,table.unpack(args,1,5)) and not pcall(Reference,table.unpack(args,1,5)),"required argument remains required");
end
for _,field in ipairs({1,2,4,5}) do
    local args=valid();args[field]=" \t\n";
    check(not pcall(Syntax,table.unpack(args)) and not pcall(Reference,table.unpack(args)),"nonblank field validation");
end
local definition=Syntax(table.unpack(valid()));
for _,field in ipairs({"name","commentOpen","commentClose","escapeCharacter","prismName"}) do
    reject(function() return definition[field];end,"private");
    reject(function() definition[field]="changed";end,"private");
end
local LXC=require("LuaEx.lib.lxc");
reject(function() LXC.loadSources({["SyntaxChild.lxc"]="namespace SyntaxTest { class Child : Dox.DoxSyntax {} }"},_G);end,"final");
local graph={syntax=definition,alias=definition};graph.self=graph;
local loaded=deserialize(serialize(graph));
check(rawequal(loaded.syntax,loaded.alias) and rawequal(loaded.self,loaded),"graph sharing and cycles");
check(loaded.syntax.getName()=="Lua" and loaded.syntax.getCommentOpen()=="--[[");
check(rawequal(clone(Syntax),Syntax) and rawequal(deserialize(serialize(Syntax)),Syntax),"canonical class references");
local Serializer=require("LuaEx.lib.serializer");
local function forged(args)
    local marker={};local names={"name","commentOpen","commentClose","escapeCharacter","prismName"};
    local fields={};for i,name in ipairs(names) do fields["Dox.DoxSyntax:"..name]={Index=i,Type="string",ClassType=false,Locked=false};end
    local adapter={project=function(value)
        if rawequal(value,marker) then return {Kind="instance",Class="Dox.DoxSyntax",Fields=fields},args;end
    end,checkFunction=function() end,checkGraph=function() end,
    allocate=function() error("Cannot allocate during encoding");end,finish=function() error("Cannot restore during encoding");end};
    return "--LXC:3\n"..Serializer.serializeStaged(marker,adapter);
end
for field=1,5 do
    local args=valid();args[field]="";reject(function() deserialize(forged(args));end);
end
local args=valid();args[3]="\n";
check(deserialize(forged(args)).getCommentClose()=="\n","restored newline delimiter remains valid");
check(deserialize(serialize(definition)).getPrismName()=="lua","valid restoration survives malformed saves");
print("PASS DoxSyntax: "..checks.." checks.");
