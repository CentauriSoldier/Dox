-- Native DoxMime checked against the archived constructor and public methods.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local Mime=Dox.DoxMime;local checks=0;
local function check(condition,message) assert(condition,message);checks=checks+1;end
local function reject(action,fragment)
    local ok,err=pcall(action);
    check(not ok and (not fragment or tostring(err):find(fragment,1,true)),
        "Expected rejection "..tostring(fragment)..", got "..tostring(err));
end
local environment=setmetatable({class=function(name,meta,static,private,protected,public)
    return function(...)
        local object={};local data={pri={name="",preProcessor=null}};
        for method,fn in pairs(public) do
            if method~=name then object[method]=function(...) return fn(object,data,...);end;end
        end
        public[name](object,data,...);return object;
    end;
end},{__index=_G});
local Reference=assert(loadfile(pDox.."/legacy/dox/Components/DoxMime.lua","t",environment))();
check(class.is(Mime) and class.getname(Mime)=="Dox.DoxMime","native discovery");
check(rawget(_G,"DoxMime")==nil,"no short alias");
for _,extension in ipairs({"lua",".LUA","CPP",".tar-gz","h++","123","x_y","é"}) do
    local native,old=Mime(extension),Reference(extension);
    check(native.getName()==old.getName(),"archived extension normalization");
    for _,text in ipairs({"", "documented code", "Unicode: λ", "line one\nline two"}) do
        check(native.getPreProcessor()(text)==old.getPreProcessor()(text),"default preprocessor identity");
    end
end
for _,value in ipairs({false,1,{},null,""," ",".","..lua","a.b","/lua","a\\b","a b","a\tb","a\nb"}) do
    local okNative=pcall(Mime,value);local okOld=pcall(Reference,value);
    check(not okNative and okNative==okOld,"archived constructor rejection");
end
reject(function() Mime(nil);end);
local gate={prefix="first:"};local callback=function(text) return gate.prefix..text;end;
local native,old=Mime(".TXT",callback),Reference(".TXT",callback);
check(rawequal(native.getPreProcessor(),callback) and rawequal(old.getPreProcessor(),callback),"supplied callback identity");
for step=1,120 do
    local prefix=tostring(step)..":";
    local replacement=function(text) return prefix..text;end;
    check(native.setPreProcessor(replacement)==old.setPreProcessor(replacement),"setter return remains nil");
    check(rawequal(native.getPreProcessor(),replacement),"setter retains callback identity");
    check(native.getPreProcessor()("sample")==old.getPreProcessor()("sample"),"archived replacement behavior");
end
for _,bad in ipairs({false,1,"callback",{},null}) do
    local before=native.getPreProcessor();
    reject(function() native.setPreProcessor(bad);end);
    reject(function() Mime("txt",bad);end,"function or nil");
    check(rawequal(native.getPreProcessor(),before),"invalid setter is atomic");
end
reject(function() native.setPreProcessor(nil);end);
reject(function() return native.name;end,"private");
reject(function() return native.preProcessor;end,"private");
local source=Mime(".TXT",callback);local copied=clone(source);
check(not rawequal(copied,source) and class.isinstanceof(copied,Mime) and copied.getName()=="txt");
check(copied.getPreProcessor()("copy")=="first:copy","native clone retains callable preprocessor");
copied.setPreProcessor(function(text) return "copy:"..text;end);
check(source.getPreProcessor()("input")=="first:input","cloned callback storage is independent");
local graph={mime=source,alias=source};graph.self=graph;
local encoded=serialize(graph);gate.prefix="later:";
local loaded=deserialize(encoded);
check(rawequal(loaded.mime,loaded.alias) and rawequal(loaded.self,loaded),"graph aliases and cycles");
check(loaded.mime.getName()=="txt" and loaded.mime.getPreProcessor()("input")=="first:input","custom callback capture round-trip");
check(source.getPreProcessor()("input")=="later:input","source callback capture remains live");
check(deserialize(serialize(Mime("lua"))).getPreProcessor()("unchanged")=="unchanged","default callback persistence");
local firstDefault,secondDefault=Mime("lua"),Mime("lua");
check(not rawequal(firstDefault.getPreProcessor(),secondDefault.getPreProcessor()),"default callbacks keep per-instance identity");
firstDefault.setPreProcessor(secondDefault.getPreProcessor());
check(deserialize(serialize(firstDefault)).getPreProcessor()("shared")=="shared","reused default callback persists without exporting class code");
local LXC=require("LuaEx.lib.lxc");
LXC.loadSources({["MimeTest.lxc"]=[=[namespace MimeTest {
    class Child : Dox.DoxMime {
        private label="derived";
        public Child() { base(".LUA"); }
        public getLabel() { return this.label; }
    }
}]=]},_G);
local child=deserialize(serialize(MimeTest.Child()));
check(class.isinstanceof(child,MimeTest.Child) and child.getName()=="lua" and child.getLabel()=="derived","subclass persistence");
check(class.isinstanceof(clone(child),MimeTest.Child),"subclass native clone");
check(rawequal(clone(Mime),Mime) and rawequal(deserialize(serialize(Mime)),Mime),"canonical class references");
local Serializer=require("LuaEx.lib.serializer");
local function forged(name,callbacks)
    local marker={};local adapter={project=function(value)
        if rawequal(value,marker) then
            return {Kind="instance",Class="Dox.DoxMime",Fields={
                ["Dox.DoxMime:name"]={Index=1,Type="string",ClassType=false,Locked=false},
                ["Dox.DoxMime:preProcessor"]={Index=2,Type="table",ClassType=false,Locked=false},
            }},{name,callbacks};
        end
    end,checkFunction=function() end,checkGraph=function() end,
    allocate=function() error("No allocation during encoding");end,finish=function() error("No restore during encoding");end};
    return "--LXC:3\n"..Serializer.serializeStaged(marker,adapter);
end
local identity=function(text) return text;end;
for _,name in ipairs({"","UPPER","a.b","a/b","a\\b","a b"}) do reject(function() deserialize(forged(name,{identity}));end);end
check(deserialize(forged("lua",{})).getPreProcessor()("default")=="default","empty default marker reconstructs identity callback");
reject(function() deserialize(forged("lua",{false}));end,"preprocessor");
reject(function() deserialize(forged("lua",{identity,identity}));end,"storage");
check(deserialize(forged("lua",{identity})).getPreProcessor()("valid")=="valid","valid restoration after failures");
print("PASS DoxMime: "..checks.." checks.");
