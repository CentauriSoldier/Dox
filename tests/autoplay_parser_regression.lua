-- Native AutoPlay parser against archived constructor/entity-decoding bodies.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local checks=0;
local function check(value,message)assert(value,message);checks=checks+1;end
local function reject(action)local ok,err=pcall(action);check(not ok,tostring(err));end
local Parser=Dox.DoxAutoPlayMediaStudio;
local LXC=require("LuaEx.lib.lxc");
local environment=setmetatable({DoxMime=Dox.DoxMime,
    class=function(name,meta,static,private,protected,public,parent,final)
        return {constructor=public[name],decode=private.unescapeHTMLEntities,final=final};
    end},{__index=_G});
local archived=assert(loadfile(pDox.."/legacy/dox/Parsers/DoxAutoPlayMediaStudio.lua","t",environment))();
LXC.loadSources({["AutoPlayReference.lxc"]=[=[namespace AutoPlayParserTest {
    class Reference : Dox.Parser { public Reference(...) { base(...); } }
}]=]},_G);
local function reference(title)
    local data={pri={}};data.pri.unescapeHTMLEntities=function(text)return archived.decode({},data,text);end;
    local args;archived.constructor({},data,function(...)args=table.pack(...);end,title);
    return AutoPlayParserTest.Reference(table.unpack(args,1,args.n));
end
local function mimes(o)
    local result,count={},0;for name,value in o.getMimeTypes()()do result[name]=value;count=count+1;end
    check(count==2 and result.lua and result.autoplay,"two original MIME types");return result;
end
local native,old=Parser("AutoPlay test"),reference("AutoPlay test");
check(class.is(Parser) and class.getname(Parser)=="Dox.DoxAutoPlayMediaStudio","native class identity");
check(class.isa(native,Dox.Parser),"native base parser");
check(rawget(_G,"DoxAutoPlayMediaStudio")==nil,"no global alias");
check(archived.final==true,"original finality");
for _,method in ipairs({"getName","getSyntax","getBlockOpen","getBlockClose","getTagOpen","getIntro","getOutputPath","getOutput"})do
    check(native[method]()==old[method](),"archived metadata: "..method);
end
check(tostring(native)=="DoxAutoPlayMediaStudio (! ... !)","string form");
local function tags(o)
    local result={};for tag in o.eachBlockTag()do
        local aliases={};for alias in tag.eachAlias()do aliases[#aliases+1]=alias;end
        result[#result+1]={aliases=table.concat(aliases,"|"),display=tag.getDisplay(),required=tag.isRequired(),
            multiple=tag.isMultipleAllowed(),combined=tag.isCombined(),utility=tag.isUtil(),columns=tag.getColumnCount()};
    end;return result;
end
local a,b=tags(native),tags(old);check(#a==43 and #a==#b,"built-ins without Lua parser's PulsarLua tag");
for index,tag in ipairs(a)do for key,value in pairs(tag)do check(value==b[index][key],"original tag definition/order");end;end
local nm,om=mimes(native),mimes(old);local processor=nm.autoplay.getPreProcessor();
local pieces={"","&quot;","&apos;","&lt;","&gt;","&amp;","&amp;lt;","&unknown;","&#34;","&#x22;","&QUOT;","&quot",[=[\[x\]]=],"plain","\n","\r\n"};
for _,left in ipairs(pieces)do for _,right in ipairs(pieces)do
    local text=left.." middle "..right;
    check(processor(text)==om.autoplay.getPreProcessor()(text),"archived entity-decoding bytes");
    check(nm.lua.getPreProcessor()(text)==text and om.lua.getPreProcessor()(text)==text,"Lua MIME stays identity");
end;end
check(processor("&amp;lt;")=="&lt;","single-pass decoding");
check(processor("&quot;&apos;&lt;&gt;&amp;")==[["'<>&]],"five supported entities");
check(processor([=[\[x\]]=])==[=[\[x\]]=],"no Lua-parser bracket unescaping");
local other=mimes(Parser("Other"));
check(processor~=other.autoplay.getPreProcessor() and nm.lua.getPreProcessor()~=other.lua.getPreProcessor(),"fresh callbacks per parser");
for _,invalid in ipairs({""," ",false,1,{}})do reject(function()Parser(invalid);end);end
reject(function()Parser();end);
reject(function()LXC.loadSources({["AutoPlayFinal.lxc"]="namespace AutoPlayParserTest { class Invalid : Dox.DoxAutoPlayMediaStudio {} }"},_G);end);
local function exportMemory(o)
    local open=io.open;local writes={};
    io.open=function(path,mode)
        if mode=="w" or mode=="wb"then
            local chunks={};writes[path]=chunks;
            return {write=function(_,text)chunks[#chunks+1]=text;return true;end,close=function()return true;end};
        end
        return open(path,mode);
    end;
    local ok,path=pcall(o.export,"AutoPlayTest");io.open=open;assert(ok,path);
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
@desc AutoPlay &quot;quoted&quot; &amp; &lt;em&gt;content&lt;/em&gt;.
@param string name Name of the item.
@return string result The result.
@example print(&quot;hello&quot;)
!]]
--[[! @fqxn Incomplete
]==];
local uuid=string.uuid;string.uuid=function()return "autoplay-parser-example-id";end
local ok,err=pcall(function()
    for _,extension in ipairs({"lua","autoplay"})do
        local left,right=Parser("AutoPlay test"),reference("AutoPlay test");
        for _,o in ipairs({left,right})do
            o.setIntro("AutoPlay intro");o.setOutputPath("out");o.setBanner("banner.png");
            o.setTheme(Dox.THEME.NORD);o.setPrismTheme(Dox.PRISM.TWILIGHT);
            local mime=mimes(o)[extension];o.importString(source,mime);o.importString(source,mime);
        end
        for _,builder in Dox.BUILDER()do
            left.setBuilder(builder);right.setBuilder(builder);
            local files=sameExport(left,right,"archived AutoPlay constructor/"..extension);
            if builder==Dox.BUILDER.HTML then
                local html;for _,bytes in pairs(files)do html=bytes;end
                check(html:find("language-lua",1,true),"Lua example highlighting");
                check(not html:find("LongFake",1,true) and not html:find("LineFake",1,true) and not html:find("Incomplete",1,true),"lexical exclusions");
                check(html:find(extension=="autoplay" and 'print(\\"hello\\")' or 'print(&quot;hello&quot;)',1,true),"MIME-specific entity handling");
            end
            for _,copy in ipairs({clone(left),deserialize(serialize(left))})do
                check(class.isinstanceof(copy,Parser) and not rawequal(copy,left),"concrete copy/restore identity");
                local cm=mimes(copy);check(cm.autoplay.getPreProcessor()("&lt;saved&gt;")=="<saved>","restored entity callback");
                check(cm.lua.getPreProcessor()("&lt;saved&gt;")=="&lt;saved&gt;","restored identity callback");
                sameExport(left,copy,"clone/restored parser");
            end
        end
    end
    local shared=deserialize(serialize({parser=native,mime=nm.autoplay}));
    check(rawequal(mimes(shared.parser).autoplay,shared.mime),"shared MIME graph identity");
    local changed=Parser("Custom");local suffix=" custom";
    mimes(changed).autoplay.setPreProcessor(function(text)return text..suffix;end);
    check(mimes(deserialize(serialize(changed))).autoplay.getPreProcessor()("text")=="text custom","custom callback capture survives");
    for _,extension in ipairs({"LUA","AUTOPLAY"})do
        local open=io.open;local closed=false;local path="input."..extension;
        io.open=function(p,mode)
            if p==path then check(mode=="r","file read mode");return {read=function()return source;end,close=function()closed=true;end};end
            return open(p,mode);
        end;
        local fileParser=Parser("AutoPlay test");local imported,importError=pcall(fileParser.importFile,path);
        io.open=open;assert(imported,importError);check(closed,"file closed");
        local stringParser=Parser("AutoPlay test");stringParser.importString(source,mimes(stringParser)[extension:lower()]);
        sameExport(fileParser,stringParser,"file/string import/"..extension);
    end
end);string.uuid=uuid;assert(ok,err);
print("PASS AutoPlay parser: "..checks.." checks.");
