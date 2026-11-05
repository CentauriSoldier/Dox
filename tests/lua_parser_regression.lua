-- Native Lua parser against archived constructor/preprocessor bodies.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.init");
local checks=0;
local function check(value,message)assert(value,message);checks=checks+1;end
local function reject(action)local ok,err=pcall(action);check(not ok,tostring(err));end
local Parser=Dox.DoxLua;
local LXC=require("LuaEx.lib.lxc");
local environment=setmetatable({DoxMime=Dox.DoxMime,DoxBlockTag=Dox.DoxBlockTag,
    class=function(name,meta,static,private,protected,public,parent,final)
        return {name=name,constructor=public[name],preprocess=private.preprocessDocumentation,final=final};
    end},{__index=_G});
local archived=assert(loadfile(pDox.."/legacy/dox/Parsers/DoxLua.lua","t",environment))();
local function archivedArguments(title)
    local data={pri={}};
    data.pri.preprocessDocumentation=function(text)return archived.preprocess({},data,text);end;
    local args;
    archived.constructor({},data,function(...)args=table.pack(...);end,title);
    return args;
end
LXC.loadSources({["LuaParserReference.lxc"]=[=[namespace LuaParserTest {
    class Reference : Dox.Parser {
        public Reference(...) { base(...); }
    }
}]=]},_G);
local function reference(title)local args=archivedArguments(title);return LuaParserTest.Reference(table.unpack(args,1,args.n));end
local function mime(o)
    local found,count;count=0;
    local native=class.isinstanceof(o,Parser);
    for name,value in o.getMimeTypes()()do
        check(name=="lua" or (native and (name=="lxc" or name=="lxe")),"Lua-family MIME key");
        check(value.getName()==name,"MIME name matches key");
        if name=="lua"then found=value;end
        count=count+1;
    end
    check(count==(native and 3 or 1) and found~=nil,"expected Lua-family MIME set");return found;
end
local native=Parser("Lua test");local old=reference("Lua test");
check(class.is(Parser) and class.getname(Parser)=="Dox.DoxLua","native class identity");
check(class.isa(native,Dox.Parser),"native base parser");
check(rawget(_G,"DoxLua")==nil,"no global alias");
check(archived.final==true,"original finality");
for _,method in ipairs({"getName","getSyntax","getBlockOpen","getBlockClose","getTagOpen","getIntro","getOutputPath","getOutput"})do
    check(native[method]()==old[method](),"archived metadata: "..method);
end
check(tostring(native)=="DoxLua (! ... !)","string form");
local function tags(o)
    local result={};for tag in o.eachBlockTag()do
        local aliases={};for alias in tag.eachAlias()do aliases[#aliases+1]=alias;end
        result[#result+1]={aliases=table.concat(aliases,"|"),display=tag.getDisplay(),required=tag.isRequired(),
            multiple=tag.isMultipleAllowed(),combined=tag.isCombined(),utility=tag.isUtil(),columns=tag.getColumnCount()};
    end;return result;
end
local a,b=tags(native),tags(old);check(#a==44 and #a==#b,"43 built-ins plus PulsarLua");
for index,tag in ipairs(a)do for key,value in pairs(tag)do check(value==b[index][key],"original tag definition/order");end;end
local pulsar=a[44];check(pulsar.display=="PulsarLua" and pulsar.aliases=="pulsarlua|pullua" and pulsar.utility and not pulsar.multiple,"Pulsar utility definition");
local newMime,oldMime=mime(native),mime(old);
local processor=newMime.getPreProcessor();
check(newMime.getName()==oldMime.getName(),"original extension");
check(processor~=mime(Parser("Other")).getPreProcessor(),"fresh callback per parser");
local pieces={"",[=[\[]=],[=[\]]=],[=[\[\]]=],[=[\[\[x\]\]]=],[=[\(x\)]=],[=[\@desc]=],"plain",[=[\\[]=],[=[\\]]=],"\n","\r\n"};
for _,left in ipairs(pieces)do for _,right in ipairs(pieces)do
    local text=left.." middle "..right;
    check(processor(text)==oldMime.getPreProcessor()(text),"archived preprocessing bytes");
end;end
for _,invalid in ipairs({""," ",false,1,{}})do reject(function()Parser(invalid);end);end
reject(function()Parser();end);
reject(function()LXC.loadSources({["LuaParserFinal.lxc"]="namespace LuaParserTest { class Invalid : Dox.DoxLua {} }"},_G);end);
local function exportMemory(o)
    local open=io.open;local writes={};
    io.open=function(path,mode)
        if mode=="w" or mode=="wb"then
            local chunks={};writes[path]=chunks;
            return {write=function(_,text)chunks[#chunks+1]=text;return true;end,close=function()return true;end};
        end
        return open(path,mode);
    end;
    local ok,path=pcall(o.export,"LuaTest");io.open=open;assert(ok,path);
    local files={};for p,chunks in pairs(writes)do files[p]=table.concat(chunks);end
    return path,files;
end
local function sameExport(left,right,label)
    local path,files=exportMemory(left);local oldPath,oldFiles=exportMemory(right);
    check(path==oldPath and left.getOutput()==right.getOutput(),label.." output/path");
    for p,bytes in pairs(files)do check(oldFiles[p]==bytes,label.." exported bytes");end
    for p in pairs(oldFiles)do check(files[p]~=nil,label.." file manifest");end
    return files;
end
local source=[==[
local fake="--[[! @fqxn Fake !]]"
local long=[=[--[[! @fqxn LongFake !]]]=]
-- ordinary --[[! @fqxn LineFake !]]
--[[! @fqxn Demo.function
@desc Lua content.
@param string name Name of the item.
@return string result The result.
@example local list = \[\[literal\]\]
@pulsarlua function Demo.function
!]]
--[[! @fqxn Incomplete
]==];
local uuid=string.uuid;string.uuid=function()return "lua-parser-example-id";end
local ok,err=pcall(function()
    for _,o in ipairs({native,old})do
        o.setIntro("Lua intro");o.setOutputPath("out");o.setBanner("banner.png");
        o.setTheme(Dox.THEME.NORD);o.setPrismTheme(Dox.PRISM.TWILIGHT);
        o.importString(source,mime(o));o.importString(source,mime(o));
    end
    for _,builder in Dox.BUILDER()do
        native.setBuilder(builder);old.setBuilder(builder);
        local files=sameExport(native,old,"archived Lua constructor");
        if builder==Dox.BUILDER.HTML then
            local html;for _,bytes in pairs(files)do html=bytes;end
            check(html:find("[[literal]]",1,true),"Lua brackets unescaped in example");
            check(html:find("language-lua",1,true),"Lua example highlighting");
            check(not html:find("LongFake",1,true) and not html:find("LineFake",1,true) and not html:find("Incomplete",1,true),"lexical exclusions");
        end
        for _,copy in ipairs({clone(native),deserialize(serialize(native))})do
            check(class.isinstanceof(copy,Parser) and not rawequal(copy,native),"concrete copy/restore identity");
            check(mime(copy).getPreProcessor()([=[\[saved\]]=])=="[saved]","restored Lua callback");
            sameExport(native,copy,"clone/restored parser");
        end
    end
    local shared=deserialize(serialize({parser=native,mime=newMime}));
    check(rawequal(mime(shared.parser),shared.mime),"shared MIME graph identity");
    -- The MIME callback remains replaceable and custom callback captures persist.
    local changed=Parser("Custom");local suffix=" custom";
    mime(changed).setPreProcessor(function(text)return text..suffix;end);
    local restored=deserialize(serialize(changed));
    check(mime(restored).getPreProcessor()("text")=="text custom","custom callback capture survives");
    for _,extension in ipairs({"LUA","LXC","LXE"})do
        local open=io.open;local closed=false;
        local path="input."..extension;
        io.open=function(input,mode)
            if input==path then check(mode=="r","Lua-family file read mode");return {read=function()return source;end,close=function()closed=true;end};end
            return open(input,mode);
        end;
        local fileParser=Parser("Lua test");
        local imported,importError=pcall(fileParser.importFile,path);io.open=open;assert(imported,importError);
        check(closed,extension.." file closed");
        local stringParser=Parser("Lua test");stringParser.importString(source,mime(stringParser));
        sameExport(fileParser,stringParser,extension.." file/string import");
    end
end);string.uuid=uuid;assert(ok,err);
print("PASS DoxLua parser: "..checks.." checks.");
