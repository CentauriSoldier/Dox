-- Native DoxBlockTag versus unchanged archived methods and built-in tag fixtures.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local Tag=Dox.DoxBlockTag;local checks=0;
local function check(condition,message) assert(condition,message);checks=checks+1;end
local function reject(action,fragment)
    local ok,err=pcall(action);
    check(not ok and (not fragment or tostring(err):find(fragment,1,true)),
        "Expected rejection "..tostring(fragment)..", got "..tostring(err));
end
local records=setmetatable({},{__mode="k"});local Reference;
local environment=setmetatable({class=function(name,meta,static,private,protected,public)
    return function(...)
        local object={};local data={pri={aliases={},columnCount=1},ins=records};records[object]=data;
        for method,fn in pairs(public) do
            if method~=name then object[method]=function(...) return fn(object,data,...);end;end
        end
        setmetatable(object,{__tostring=function() return meta.__tostring(object,data);end,
            __eq=function(left,right) return meta.__eq(left,right,records[left]);end});
        public[name](object,data,...);return object;
    end;
end},{__index=_G});
Reference=assert(loadfile(pDox.."/legacy/dox/Components/DoxBlockTag.lua","t",environment))();environment.DoxBlockTag=Reference;
local catalogEnvironment=setmetatable({DoxBlockTag=function(...) return table.pack(...);end},{__index=_G});
local catalog=assert(loadfile(pDox.."/legacy/dox/Statics/BuiltInBlockTags.lua","t",catalogEnvironment))();
local methods={"getDisplay","getColumnCount","isCombined","isMultipleAllowed","isRequired","isUtil"};
local function aliasList(tag)
    local list={};for alias in tag.eachAlias() do list[#list+1]=alias;end;return table.concat(list,"|");
end
local function compare(args)
    local native,old=Tag(table.unpack(args,1,args.n)),Reference(table.unpack(args,1,args.n));
    for _,method in ipairs(methods) do check(native[method]()==old[method](),"archived "..method);end
    check(aliasList(native)==aliasList(old),"archived alias normalization/order");
    check(tostring(native)==tostring(old),"archived string formatting");
    for alias in native.eachAlias() do
        check(native.hasAlias(alias:upper())==old.hasAlias(alias:upper()),"case-insensitive alias lookup");
    end
    check(not native.hasAlias("not-present") and not old.hasAlias("not-present"));
    local copy=clone(native);
    check(not rawequal(copy,native) and copy==native and native==copy,"native value equality and independent clone");
    local loaded=deserialize(serialize(native));check(loaded==native,"native tag persistence");
    return native;
end
check(class.is(Tag) and class.getname(Tag)=="Dox.DoxBlockTag");
check(rawget(_G,"DoxBlockTag")==nil,"no short alias");
check(#catalog>0,"built-in tag catalog captured without editing it");
for _,args in ipairs(catalog) do compare(args);end
for flags=0,15 do
    for _,columns in ipairs({0,1,2.9,-1,math.huge,0/0,"bad"}) do
        compare(table.pack({"Alias","ALT"},"Display",flags%2==1,math.floor(flags/2)%2==1,
            math.floor(flags/4)%2==1,math.floor(flags/8)%2==1,columns));
    end
end
compare(table.pack({"a"},"Display","yes",1,{},"utility",false));
local aliases={"Mixed","UPPER"};local tag=Tag(aliases,"Name");aliases[1]="changed";
check(tag.hasAlias("mixed") and not tag.hasAlias("changed"),"constructor copies aliases");
local same=Tag({"mixed","upper"},"Name");local reordered=Tag({"upper","mixed"},"Name");
check(tag==same and same==tag and not (tag==reordered),"alias order participates in equality");
check(not (tag==Dox.DoxMime("lua")) and not (tag=={}),"unrelated objects compare unequal");
for field=2,7 do
    local args=table.pack({"mixed","upper"},"Name",false,false,false,false,0);
    if field==2 then args[field]="Other";elseif field==7 then args[field]=1;else args[field]=true;end
    local changed=Tag(table.unpack(args,1,args.n));
    -- Combined is normalized to false unless multiples are allowed.
    check((tag==changed)==(field==5),"all normalized fields participate in equality");
end
for _,input in ipairs({false,{}, {"a","A"}, {"a b"}, {""}, {[0]="a"}, {"a",false}, {[1]="a",[3]="b"}}) do
    local native=pcall(Tag,input,"Name");local old=pcall(Reference,input,"Name");
    check(not native and native==old,"archived alias rejection");
end
reject(function() Tag(nil,"Name");end,"at least one alias");
for _,display in ipairs({false,""," \t",1,{}}) do
    check(not pcall(Tag,{"a"},display) and not pcall(Reference,{"a"},display),"archived display rejection");
end
for _,field in ipairs({"aliases","columnCount","combined","display","multipleAllowed","required","util"}) do
    reject(function() return tag[field];end,"private");
end
local iterator=tag.eachAlias();check(iterator()=="mixed" and iterator()=="upper" and iterator()==nil and iterator()==nil);
local LXC=require("LuaEx.lib.lxc");
reject(function() LXC.loadSources({["TagChild.lxc"]="namespace TagTest { class Child : Dox.DoxBlockTag {} }"},_G);end,"final");
local graph={tag=tag,alias=tag};graph.self=graph;local loaded=deserialize(serialize(graph));
check(rawequal(loaded.tag,loaded.alias) and rawequal(loaded.self,loaded) and loaded.tag==tag,"graph identities and value equality");
check(rawequal(clone(Tag),Tag) and rawequal(deserialize(serialize(Tag)),Tag),"canonical class references");
local Serializer=require("LuaEx.lib.serializer");
local function fields()
    return {aliases={"a"},columnCount=1,combined=false,display="Name",multipleAllowed=false,required=false,util=false};
end
local function forged(state)
    local marker={};local descriptor={};local values={};
    for _,name in ipairs({"aliases","columnCount","combined","display","multipleAllowed","required","util"}) do
        values[#values+1]=state[name];descriptor["Dox.DoxBlockTag:"..name]={Index=#values,Type=rawtype(state[name]),ClassType=false,Locked=false};
    end
    local adapter={project=function(value)
        if rawequal(value,marker) then return {Kind="instance",Class="Dox.DoxBlockTag",Fields=descriptor},values;end
    end,checkFunction=function() end,checkGraph=function() end,
    allocate=function() error("No allocation during encoding");end,finish=function() error("No restore during encoding");end};
    return "--LXC:3\n"..Serializer.serializeStaged(marker,adapter);
end
for _,breaker in ipairs({function(t)t.aliases={};end,function(t)t.aliases={"a","a"};end,
    function(t)t.aliases={"UPPER"};end,function(t)t.display="";end,function(t)t.columnCount=0;end,
    function(t)t.columnCount=1.5;end,function(t)t.required="bad";end,function(t)t.combined=true;end}) do
    local state=fields();breaker(state);reject(function()deserialize(forged(state));end);
end
check(deserialize(forged(fields())).hasAlias("A"),"valid restoration after failures");
print("PASS DoxBlockTag: "..checks.." checks; "..#catalog.." built-in tags.");
