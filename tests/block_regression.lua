-- Native DoxBlock parsing versus archived methods with a legacy enum-value adapter.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local Block,Tag=Dox.DoxBlock,Dox.DoxBlockTag;local checks=0;
local function check(condition,message) assert(condition,message);checks=checks+1;end
local function reject(action,fragment)
    local ok,err=pcall(action);
    check(not ok and (not fragment or tostring(err):find(fragment,1,true)),
        "Expected rejection "..tostring(fragment)..", got "..tostring(err));
end
local LXC=require("LuaEx.lib.lxc");
LXC.loadSources({["BlockSyntax.lxe"]=[=[namespace BlockTest {
    public enum SYNTAX { LUA = Dox.DoxSyntax("Lua", "--[[", "]]", "\\", "lua"); }
}]=]},_G);
local language=BlockTest.SYNTAX.LUA;
local environment=setmetatable({class=function(name,meta,static,private,protected,public)
    return function(...)
        local object={};local data={pri={columns=1,fqxn={},items={}}};
        for method,fn in pairs(private) do
            if rawtype(fn)=="function" then data.pri[method]=function(...)return fn(object,data,...);end;end
        end
        for method,fn in pairs(public) do
            if method~=name then object[method]=function(...)return fn(object,data,...);end;end
        end
        public[name](object,data,...);return object;
    end;
end},{__index=_G});
local Reference=assert(loadfile(pDox.."/legacy/dox/Components/DoxBlock.lua","t",environment))();
local legacyLanguage={value=language.Value};
local fqxn=Tag({"fqxn"},"FQXN",true);
local description=Tag({"desc","description"},"Description");
local parameter=Tag({"param","parameter"},"Parameters",false,true,false,false,2);
local utility=Tag({"internal"},"Utility",false,true,false,true);
local tags={fqxn,description,parameter,utility};local required={fqxn};
local function names(block)
    local result={};
    for last,index,segment in block.fqxn() do
        result[#result+1]=tostring(last)..":"..index..":"..segment;
    end
    return table.concat(result,"|");
end
local function items(block)
    local result={};
    for tag,content in block.eachItem() do result[#result+1]={tag=tag,content=content};end
    return result;
end
local function compare(text,definitions,mustHave)
    definitions=definitions or tags;mustHave=mustHave or required;
    local native=Block(text,language,"@",definitions,mustHave);
    local old=Reference(text,legacyLanguage,"@",definitions,mustHave);
    check(names(native)==names(old),"archived qualified-name iteration");
    local a,b=items(native),items(old);check(#a==#b,"archived item count");
    for index,entry in ipairs(a) do
        check(entry.tag==b[index].tag and entry.content==b[index].content,"archived stable output order and content");
        local tag,content=native.item(index);
        check(tag==entry.tag and not rawequal(tag,entry.tag) and content==entry.content,"indexed access clones tags");
    end
    local copied=clone(native);local loaded=deserialize(serialize(native));
    check(names(copied)==names(native) and names(loaded)==names(native),"clone/restore qualified names");
    local c,d=items(copied),items(loaded);check(#c==#a and #d==#a,"clone/restore item count");
    for index,entry in ipairs(a) do
        check(c[index].tag==entry.tag and d[index].tag==entry.tag and c[index].content==entry.content
            and d[index].content==entry.content,"native persistence preserves tags/content");
    end
    return native;
end
check(class.is(Block) and class.getname(Block)=="Dox.DoxBlock");
check(rawget(_G,"DoxBlock")==nil,"no short alias");
local block=compare("@param number x First.\n@desc Description.\n@param string y Second.\n@fqxn Demo.item\n@internal Hidden.");
check(names(block)=="false:1:Demo|true:2:item");
local ordered=items(block);check(ordered[1].tag==description and ordered[2].content=="number x First."
    and ordered[3].content=="string y Second." and ordered[4].tag==utility,"configured order and stable repeated tags");
compare("@fqxn Demo.escape\n@desc A literal \\@ symbol.");
compare("@fqxn Demo.multiline\n@desc First line.\nSecond line.\n@param table values Many values.");
compare("@desc No qualified name required.",tags,{});
for step=1,90 do
    local text="@fqxn Example.Group.Item"..step.."\n@param number first Value "..step..".\n@desc Description "..step..".\n@param string second Other.";
    if step%2==0 then text=text.."\n@internal Metadata.";end
    compare(text);
end
for _,text in ipairs({"", " ", "@unknown Stuff.", "@desc Missing name.", "@fqxn Demo.item\n@desc ",
    "@fqxn Demo.item\n@desc One.\n@description Two.", "@fqxn", "@fqxn Demo.item\n@p x"}) do
    local nativeOK=pcall(Block,text,language,"@",tags,required);
    local oldOK=pcall(Reference,text,legacyLanguage,"@",tags,required);
    check(not nativeOK and nativeOK==oldOK,"archived malformed/missing/duplicate rejection");
end
for _,index in ipairs({0,-1,1.5,math.huge,0/0,100,"1",false}) do
    reject(function()block.item(index);end,"existing item");
end
reject(function()block.item(nil);end,"existing item");
local firstTag,firstContent=block.item(1);local nextTag,nextContent=block.item(1);
check(not rawequal(firstTag,nextTag) and firstTag==nextTag and firstContent==nextContent,"repeated item access returns independent tags");
local graph={block=block,alias=block};graph.self=graph;local loaded=deserialize(serialize(graph));
check(rawequal(loaded.block,loaded.alias) and rawequal(loaded.self,loaded),"graph sharing/cycles");
check(rawequal(clone(Block),Block) and rawequal(deserialize(serialize(Block)),Block),"canonical class references");
reject(function()LXC.loadSources({["BlockChild.lxc"]="namespace BlockTest { class Child : Dox.DoxBlock {} }"},_G);end,"final");
reject(function()return block.items;end,"private");
reject(function()return block._tFQXN;end,"private");
local Serializer=require("LuaEx.lib.serializer");
local function forged(fqxnParts,entries)
    local marker={};local adapter={project=function(value)
        if rawequal(value,marker) then
            return {Kind="instance",Class="Dox.DoxBlock",Fields={
                ["Dox.DoxBlock:columns"]={Index=1,Type="number",ClassType=false,Locked=false},
                ["Dox.DoxBlock:_tFQXN"]={Index=2,Type="table",ClassType=false,Locked=false},
                ["Dox.DoxBlock:items"]={Index=3,Type="table",ClassType=false,Locked=false},
            }},{1,fqxnParts,entries};
        end
    end,checkFunction=function()end,checkGraph=function()end,
    allocate=function()error("No allocation during encoding");end,finish=function()error("No restore during encoding");end};
    return "--LXC:3\n"..Serializer.serializeStaged(marker,adapter);
end
reject(function()deserialize(forged({[2]="gap"},{}));end,"hole");
reject(function()deserialize(forged({false},{}));end);
reject(function()deserialize(forged({},{{blockTag=false,content="text"}}));end,"tag");
check(names(deserialize(forged({"Valid","name"},{})))=="false:1:Valid|true:2:name","valid snapshot after failures");
local canonical=Dox.DoxBlock("@fqxn Canonical.item\n@desc Descriptor-backed syntax.",Dox.SYNTAX.LUA,"@",tags,required);
check(names(canonical)=="false:1:Canonical|true:2:item","canonical syntax data resolves during parsing");
print("PASS DoxBlock: "..checks.." checks.");
