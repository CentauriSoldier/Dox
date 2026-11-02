-- Native NASM parser versus archived constructor arguments and native base behavior.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local checks=0;
local function check(value,message)assert(value,message);checks=checks+1;end
local function reject(action)local ok,err=pcall(action);check(not ok,tostring(err));end
local Parser=Dox.DoxAssemblyNasm;local LXC=require("LuaEx.lib.lxc");
local environment=setmetatable({DoxMime=Dox.DoxMime,
    class=function(name,meta,static,private,protected,public,parent,final)return {constructor=public[name],final=final};end},{__index=_G});
local archived=assert(loadfile(pDox.."/legacy/dox/Parsers/DoxAssemblyNasm.lua","t",environment))();
LXC.loadSources({["NasmReference.lxc"]=[=[namespace NasmParserTest {
    class Reference : Dox.Parser { public Reference(...) { base(...); } }
}]=]},_G);
local function reference(title)
    local args;archived.constructor({},{},function(...)args=table.pack(...);end,title);
    return NasmParserTest.Reference(table.unpack(args,1,args.n));
end
local function mime(o)
    local result,count;count=0;
    for name,value in o.getMimeTypes()()do check(name=="asm","asm MIME key");result=value;count=count+1;end
    check(count==1,"single MIME");return result;
end
local native,old=Parser("NASM test"),reference("NASM test");
check(class.is(Parser) and class.getname(Parser)=="Dox.DoxAssemblyNasm","original class-name spelling");
check(class.isa(native,Dox.Parser),"native base parser");
check(rawget(_G,"DoxAssemblyNasm")==nil and rawget(_G,"DoxAssemblyNASM")==nil,"no global aliases");
check(archived.final==true,"original finality");
for _,method in ipairs({"getName","getSyntax","getBlockOpen","getBlockClose","getTagOpen","getIntro","getOutputPath","getOutput"})do
    check(native[method]()==old[method](),"archived metadata: "..method);
end
check(native.getSyntax()==Dox.SYNTAX.ASSEMBLY_NASM and tostring(native)=="DoxAssemblyNasm (! ... !)","NASM syntax and string form");
local function tags(o)
    local result={};for tag in o.eachBlockTag()do
        local aliases={};for alias in tag.eachAlias()do aliases[#aliases+1]=alias;end
        result[#result+1]={aliases=table.concat(aliases,"|"),display=tag.getDisplay(),required=tag.isRequired(),
            multiple=tag.isMultipleAllowed(),combined=tag.isCombined(),utility=tag.isUtil(),columns=tag.getColumnCount()};
    end;return result;
end
local a,b=tags(native),tags(old);check(#a==43 and #a==#b,"original built-in tag count");
for index,tag in ipairs(a)do for key,value in pairs(tag)do check(value==b[index][key],"original tag definition/order");end;end
local nm,om=mime(native),mime(old);
for _,text in ipairs({"","plain","&quot;&lt;&amp;",[=[\[brackets\]]=],"\n","\r\n","mov eax, 1 ; NASM"})do
    check(nm.getPreProcessor()(text)==text and om.getPreProcessor()(text)==text,"identity preprocessing bytes");
end
check(nm.getPreProcessor()~=mime(Parser("Other")).getPreProcessor(),"fresh identity callback");
for _,invalid in ipairs({""," ",false,1,{}})do reject(function()Parser(invalid);end);end
reject(function()Parser();end);
reject(function()LXC.loadSources({["NasmFinal.lxc"]="namespace NasmParserTest { class Invalid : Dox.DoxAssemblyNasm {} }"},_G);end);
local function exportMemory(o)
    local open=io.open;local writes={};
    io.open=function(path,mode)
        if mode=="w" or mode=="wb"then
            local chunks={};writes[path]=chunks;
            return {write=function(_,text)chunks[#chunks+1]=text;return true;end,close=function()return true;end};
        end
        return open(path,mode);
    end;
    local ok,path=pcall(o.export,"NasmTest");io.open=open;assert(ok,path);
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
local source=[=[
%{! @fqxn Demo.assembly
@desc NASM content remains &quot;encoded&quot;.
@param number count Count of items.
@return number result The result.
@example mov eax, 1
!%}
]=];
local uuid=string.uuid;string.uuid=function()return "nasm-parser-example-id";end
local ok,err=pcall(function()
    for _,o in ipairs({native,old})do
        o.setIntro("NASM intro");o.setOutputPath("out");o.setBanner("banner.png");
        o.setTheme(Dox.THEME.NORD);o.setPrismTheme(Dox.PRISM.TWILIGHT);
        o.importString(source,mime(o));o.importString(source,mime(o));
    end
    for _,builder in Dox.BUILDER()do
        native.setBuilder(builder);old.setBuilder(builder);
        local files=sameExport(native,old,"archived NASM constructor");
        if builder==Dox.BUILDER.HTML then
            local html;for _,bytes in pairs(files)do html=bytes;end
            check(html:find("language-asm6502",1,true),"original highlighting name");
            check(html:find("mov eax, 1",1,true) and html:find("NASM content remains &quot;encoded&quot;.",1,true),"content parsed with identity preprocessing");
        end
        for _,copy in ipairs({clone(native),deserialize(serialize(native))})do
            check(class.isinstanceof(copy,Parser) and not rawequal(copy,native),"concrete clone/restore identity");
            check(mime(copy).getPreProcessor()("saved")=="saved","restored identity callback");
            sameExport(native,copy,"clone/restored parser");
        end
    end
    local shared=deserialize(serialize({parser=native,mime=nm}));
    check(rawequal(mime(shared.parser),shared.mime),"shared MIME graph identity");
    local changed=Parser("Custom");local suffix=" custom";
    mime(changed).setPreProcessor(function(text)return text..suffix;end);
    check(mime(deserialize(serialize(changed))).getPreProcessor()("text")=="text custom","custom callback captures");
    local open=io.open;local closed=0;local paths={["input.ASM"]=source,["second.asm"]=source};
    io.open=function(path,mode)
        if paths[path]then check(mode=="r","NASM file read mode");return {read=function()return paths[path];end,close=function()closed=closed+1;end};end
        return open(path,mode);
    end;
    local fileParser=Parser("NASM test");
    local imported,importError=pcall(function()fileParser.importFile("input.ASM");fileParser.importFiles({"second.asm","skip.other"});end);
    io.open=open;assert(imported,importError);check(closed==2,"recognized files closed, unknown extension skipped");
    local stringParser=Parser("NASM test");stringParser.importString(source,mime(stringParser));
    sameExport(fileParser,stringParser,"NASM file/string imports");
end);string.uuid=uuid;assert(ok,err);
print("PASS NASM parser: "..checks.." checks.");
