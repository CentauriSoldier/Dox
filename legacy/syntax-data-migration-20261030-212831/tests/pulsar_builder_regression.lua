-- Pulsar builder migration: native blocks, archived completion/package parity, native export.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local Builder=Dox.DoxBuilderPulsarLua;local checks=0;
local function check(condition,message)assert(condition,message);checks=checks+1;end
local function reject(action,fragment)
    local ok,err=pcall(action);check(not ok and (not fragment or tostring(err):find(fragment,1,true)),
        "Expected rejection "..tostring(fragment)..", got "..tostring(err));
end
local function equal(a,b,seen)
    if rawequal(a,b)then return true;end
    if rawtype(a)~="table" or rawtype(b)~="table"then return false;end
    seen=seen or {};if seen[a]then return rawequal(seen[a],b);end;seen[a]=b;
    for k,v in pairs(a)do if not equal(v,b[k],seen)then return false;end;end
    for k in pairs(b)do if a[k]==nil then return false;end;end
    return true;
end
local environment=setmetatable({DoxBuilder={MIME={LUACOMPLETERC={value="luacompleterc"}}},
    class=function(name,meta,static,private,protected,public)
        return function()
            local object={};local data={pro={}};
            for method,fn in pairs(public)do
                if method~=name then object[method]=function(...)return fn(object,data,...);end;end
            end
            public[name](object,data,function(builderName,mime,button,filename,newline,wrappers)
                data.pro.outputExtension=mime.value;data.pro.outputMode="w";
            end);return object;
        end;
    end},{__index=_G});
local Reference=assert(loadfile(pDox.."/legacy/dox/Builders/Pulsar/Lua/DoxBuilderPulsarLua.lua","t",environment))();
local native,old=Builder(),Reference();
check(class.is(Builder) and class.getname(Builder)=="Dox.DoxBuilderPulsarLua");
check(rawget(_G,"DoxBuilderPulsarLua")==nil,"no short alias");
check(class.isa(native,Dox.DoxBuilder) and native.getName()=="DoxBuilderPulsarLua");
check(rawequal(native.getMime(),Dox.DoxBuilder.MIME.LUACOMPLETERC));
check(native.getDefaultFilename()=="completions" and native.getNewLine()=="\n");
local LXC=require("LuaEx.lib.lxc");
LXC.loadSources({["PulsarSyntax.lxe"]=[=[namespace PulsarTest {
    public enum SYNTAX { LUA = Dox.DoxSyntax("Lua","--[[","]]","\\","lua"); }
}]=]},_G);
local Tag=Dox.DoxBlockTag;
local fqxn=Tag({"fqxn"},"FQXN",true);
local tags={fqxn,Tag({"desc"},"Description",false,true),Tag({"summary"},"Summary",false,true),
    Tag({"param"},"Parameter(s)",false,true),Tag({"return"},"Return(s)",false,true),
    Tag({"field"},"Field(s)",false,true),Tag({"pulsarlua"},"PulsarLua"),Tag({"inheritdoc"},"Inheritdoc")};
local function block(text)return Dox.DoxBlock(text,PulsarTest.SYNTAX.LUA,"@",tags,{fqxn});end
local fixtures={
    block("@fqxn Demo.Methods.add\n@desc Add two numbers.\n@param number left First.\n@param number right Second.\n@return number result Sum."),
    block("@fqxn Demo.Constants\n@desc Constants.\n@field number ONE First.\n@field string LABEL Label."),
    block("@fqxn Model.Constructor\n@pulsarlua function Model\n@desc A callable model.\n@param number id Identifier.\n@return Model instance New model."),
    block("@fqxn Model.Methods.get\n@desc Gets the value.\n@return number value The value."),
    block("@fqxn Model.Field\n@pulsarlua number Model.value\n@desc Current value."),
    block("@fqxn Demo.Unknown\n@param NotDocumented value Unknown type.\n@return string|nil text Ambiguous."),
    block("@fqxn Demo.Alias\n@inheritdoc Demo.Methods.add"),
    block("@fqxn Original.Methods.name\n@pulsarlua function Renamed.call\n@param string input Text.\n@summary Explicit name."),
};
local function compare(blocks,title)
    local a,b=native.refresh(blocks),old.refresh(blocks);
    check(equal(a,b),"archived completion graph and sharing");
    local za,na=native.buildPackage(title,a);local zb,nb=old.buildPackage(title,b);
    check(za==zb and na==nb,"byte-identical archived ZIP and package name");
    check(za:sub(1,2)=="PK" and za:find(na.."/package.json",1,true) and za:find(na.."/completions.json",1,true),"package layout");
    check(native.build(title,"ignored intro",a)==za and old.build(title,"ignored intro",b)==zb,"build preserves archive return");
    return a,za;
end
local data,archive=compare(fixtures,"Awesome API 2");
local add=data.global.fields.Demo.fields.add;
check(add.type=="function" and #add.args==2 and add.args[1].name=="left" and add.args[2].name=="right","parameter order");
check(add.returnTypes[1].type=="number" and add.argsDisplay=="left, right");
check(data.global.fields.Demo.fields.Constants.fields.ONE.type=="number","documented enum/table fields");
local model=data.global.fields.Model;
check(model.type=="table" and model.metatable.fields.__call and model.fields.get and model.fields.value,"callable table retains members");
check(model.returnTypes[1].type=="table" and model.returnTypes[1].fields.value.type=="number","constructor return inference");
check(data.global.fields.Demo.fields.Unknown.argTypes[1].type=="unknown","unresolved types become unknown");
check(data.global.fields.Demo.fields.Unknown.returnTypes[1].type=="unknown","ambiguous unions remain unknown");
check(data.global.fields.Renamed.fields.call.args[1].name=="input","explicit names override Methods convention");
check(equal(data.global.fields.Demo.fields.Alias,add),"inherited completion metadata");
compare({},"Empty package");
for count=1,40 do
    local blocks={};for i=1,count do
        blocks[i]=block("@fqxn Generated.Methods.f"..i.."\n@desc Function "..i..".\n@param number a Value.\n@return string value Text.");
    end
    compare(blocks,"Generated package "..count);
end
for _,text in ipairs({"@fqxn Invalid\n@pulsarlua function", "@fqxn Invalid\n@param number",
    "@fqxn Invalid\n@inheritdoc Missing.target"})do
    local b=block(text);check(not pcall(native.refresh,{b}) and not pcall(old.refresh,{b}),"archived metadata rejection");
end
local cycle={block("@fqxn Cycle.A\n@inheritdoc Cycle.B"),block("@fqxn Cycle.B\n@inheritdoc Cycle.A")};
check(not pcall(native.refresh,cycle) and not pcall(old.refresh,cycle),"inheritance cycles reject");
reject(function()native.buildPackage("!!!",data);end,"letters or digits");
check(native.formatBlockContent("id","Display","content")==old.formatBlockContent("id","Display","content"));
check(native.formatCombinedBlockContent("Display","content","id")==old.formatCombinedBlockContent("Display","content"));
-- Inherited export must use ZIP bytes and binary mode without writing a user file.
local open=io.open;local written,closed;
io.open=function(path,mode)
    check(path=="output/chosen.zip" and mode=="wb","native inherited export path/mode");
    return {write=function(_,bytes)written=bytes;return true;end,close=function()closed=true;return true;end};
end;
local result=table.pack(pcall(native.export,"output","chosen","Awesome API 2","ignored intro",data));io.open=open;
check(result[1] and result[2]=="output/chosen.zip" and result[3]==archive and written==archive and closed,"inherited ZIP export");
local restored=deserialize(serialize(native));
check(class.isinstanceof(restored,Builder) and restored.getName()==native.getName(),"concrete builder restoration");
check(restored.buildPackage("Awesome API 2",data)==archive,"restored builder output");
check(clone(native).buildPackage("Awesome API 2",data)==archive,"native clone output");
check(rawequal(clone(Builder),Builder) and rawequal(deserialize(serialize(Builder)),Builder),"canonical class references");
reject(function()LXC.loadSources({["PulsarChild.lxc"]="namespace PulsarTest { class Child : Dox.DoxBuilderPulsarLua {} }"},_G);end,"final");
print("PASS Pulsar builder: "..checks.." checks.");
