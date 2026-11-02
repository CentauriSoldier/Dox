-- Native documentation host integration; legacy parsers/startup remain separate.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local checks=0;
local function check(value,message)assert(value,message);checks=checks+1;end
local function reject(action)local ok,err=pcall(action);check(not ok,tostring(err));end
local LXC=require("LuaEx.lib.lxc");
LXC.loadSources({["DoxHostTest.lxc"]=[=[namespace DoxHostTest {
    class Parser : Dox.Parser {
        public Parser(name,syntax,mimes,...) { base(name,"Host test","!","!","@",syntax,mimes,...); }
        public findTag(display) { return this.getBlockTagByDisplay(display); }
        public namedTags() { return this._eachBlockTag(); }
    }
}]=]},_G);
local Host=Dox.Parser;local Parser=DoxHostTest.Parser;
local mime=Dox.DoxMime("c");
local function document(syntax,...)return Parser("Test",syntax or Dox.SYNTAX.C,{mime},...);end
local d=document();
check(d.getName()=="Test" and tostring(d)=="Test (! ... !)","name and string form");
check(d.getBlockOpen()=="!" and d.getBlockClose()=="!" and d.getTagOpen()=="@","delimiters");
check(rawequal(d.getSyntax(),Dox.SYNTAX.C),"syntax identity");
check(d.getIntro()=="" and d.getOutputPath()=="" and d.getOutput()=="","initial output");
check(d.setIntro("Intro")==d and d.getIntro()=="Intro","fluent intro setter");
check(d.setOutputPath("out")==d and d.getOutputPath()=="out","fluent output path setter");
local count=0;for tag in d.eachBlockTag()do count=count+1;check(class.isinstanceof(tag,Dox.DoxBlockTag),"cloned native tag");end
check(count==43,"built-in tag count");
local names={};for display,tag in d.namedTags()do names[#names+1]=display;check(display==tag.getDisplay(),"protected tag iterator");end
check(#names==43 and d.findTag("Description").hasAlias("desc"),"protected tag lookup");
check(d.findTag("missing")==nil,"missing tag");
local function order(o)local t={};for tag in o.eachBlockTag()do t[#t+1]=tag.getDisplay();end;return table.concat(t,"|");end
local originalOrder=order(d);
d.setBlockTagOrder({"example","DESC"});check(order(d):match("^Example|Description|"),"custom order");
local customOrder=order(d);
for _,value in ipairs({{"desc","description"},{"unknown"},{[2]="desc"},{[0]="desc"},{""},{true},"desc"})do
    reject(function()d.setBlockTagOrder(value);end);check(order(d)==customOrder,"invalid order is atomic");
end
d.setBlockTagOrder();check(order(d)==originalOrder,"nil order reset");
d.setBlockTagOrder({});check(order(d)==originalOrder,"empty order reset");
check(order(document())==originalOrder,"independent tag lists");
local extra=Dox.DoxBlockTag({"custom"},"Custom");local custom=document(nil,extra);
check(custom.findTag("Custom").hasAlias("custom"),"custom tag retained");
reject(function()document(nil,Dox.DoxBlockTag({"desc"},"Conflict"));end);
reject(function()document(nil,{});end);
reject(function()Parser("",Dox.SYNTAX.C,{mime});end);
reject(function()Parser("Test",Dox.THEME.NORD,{mime});end);
reject(function()Parser("Test",Dox.SYNTAX.C,{});end);
reject(function()Parser("Test",Dox.SYNTAX.C,{{}});end);
reject(function()d.importString(false,mime);end);
reject(function()d.importString("",{});end);
reject(function()d.addMimeType({});end);
local luaMime=Dox.DoxMime("lua");d.addMimeType(luaMime);
local found={};for name,value in d.getMimeTypes()()do found[name]=value;end
check(found.c==mime and found.lua==luaMime,"live MIME dictionary");
for _,family in ipairs({"BUILDER","PRISM","THEME"})do
    local setter=family=="BUILDER" and "setBuilder" or family=="PRISM" and "setPrismTheme" or "setTheme";
    reject(function()d[setter](Dox.SYNTAX.C);end);
    reject(function()d[setter]({});end);
end
local input="/*! @fqxn Demo.member\n@desc Host content.\n@param string name A name.\n@example print(1) !*/";
check(d.importString(input,mime)==nil,"deferred import return");
d.importString(input,mime);check(d.refresh()==nil,"refresh return");
-- Capture all three actual builders' writes without creating export files.
local function exportMemory(o,name)
    local open=io.open;local writes={};
    io.open=function(path,mode)
        if mode=="w" or mode=="wb"then
            local chunks={};writes[path]=chunks;
            return {write=function(_,text)chunks[#chunks+1]=text;return true;end,close=function()return true;end};
        end
        return open(path,mode);
    end;
    local ok,path=pcall(o.export,name);io.open=open;assert(ok,path);
    local result={};for p,chunks in pairs(writes)do result[p]=table.concat(chunks);end
    return path,result;
end
local uuid=string.uuid;string.uuid=function()return "host-example-id";end
local ok,err=pcall(function()
    for _,member in Dox.BUILDER()do
        d.setBuilder(member);
        local path,files=exportMemory(d,"Test");
        check(rawtype(path)=="string" and files[path]~=nil,"builder writes its returned path");
        check(rawtype(d.getOutput())=="string" and #d.getOutput()>0,"stored output string");
        local copy=clone(d);check(copy~=d and copy.getIntro()==d.getIntro(),"clone preserves document");
        local restored=deserialize(serialize(d));check(restored.getSyntax()==d.getSyntax(),"restore canonical syntax");
        for _,other in ipairs({copy,restored})do
            local otherPath,otherFiles=exportMemory(other,"Test");
            check(otherPath==path,"copy export path");
            for p,bytes in pairs(files)do check(otherFiles[p]==bytes,"copy/restored complete export bytes");end
        end
    end
end);string.uuid=uuid;assert(ok,err);
-- File imports: extension matching, skipped unknowns, deferred processing and close.
local fileDoc=document();local open=io.open;local closed=0;local reads=0;
io.open=function(path,mode)
    check(mode=="r","read mode");reads=reads+1;
    if path=="missing.c"then return nil;end
    return {read=function()return input;end,close=function()closed=closed+1;end};
end;
local okFiles,errFiles=pcall(function()
    fileDoc.importFile("source.C");fileDoc.importFiles({"other.c","skip.unknown"});
    check(reads==2 and closed==2,"recognized imports opened and closed");
    reject(function()fileDoc.importFile("missing.c");end);
    reject(function()fileDoc.importFiles({});end);
end);io.open=open;assert(okFiles,errFiles);
fileDoc.refresh();
local _,files=exportMemory(fileDoc,"Imported");local html;for _,bytes in pairs(files)do html=bytes;end
check(html:find("Host content.",1,true),"file source reached HTML output");
-- Lua lexer ignores apparent markers in strings and ordinary comments.
local lua=document(Dox.SYNTAX.LUA);lua.importString([==[
local fake="--[[! @fqxn Fake !]]"
local long=[=[--[[! @fqxn AlsoFake !]]]=]
-- ordinary --[[! @fqxn CommentFake !]]
--[[! @fqxn Actual
@desc Real comment.
!]]
--[[! @fqxn Incomplete
]==],luaMime);
local _,luaFiles=exportMemory(lua,"Lua");local luaHTML;for _,bytes in pairs(luaFiles)do luaHTML=bytes;end
check(luaHTML:find("Actual",1,true) and not luaHTML:find("AlsoFake",1,true),"Lua lexical extraction");
reject(function()Host("Direct","Title","!","!","@",Dox.SYNTAX.C,{mime});end);
reject(function()LXC.loadSources({["DoxFinalTest.lxc"]="namespace DoxHostTest { class Bad : Dox.Parser { public override refresh() {} } }"},_G);end);
-- Run archived host methods through binding/type adapters, using native downstream
-- components already covered by their own differential suites. This does not run
-- the retired legacy class runtime.
local legacySyntax={};local canonicalSyntax={};
for _,member in Dox.SYNTAX()do
    local old={family="Dox.SYNTAX",value=Dox.DoxSyntax.fromEnum(member)};
    legacySyntax[member.Name]=old;canonicalSyntax[old]=member;
end
local legacyBuilders={};
for _,member in Dox.BUILDER()do
    local builder=Host.resolveBuilder(member);local adapter=setmetatable({},{__index=builder});
    adapter.getExampleWrapper=function(syntax)return builder.getExampleWrapper(canonicalSyntax[syntax] or syntax);end;
    adapter.export=function(path,filename,title,intro,data,prism,banner,theme,syntax)
        return builder.export(path,filename,title,intro,data,prism,banner,theme,canonicalSyntax[syntax] or syntax);
    end;
    legacyBuilders[member.Name]={family="Dox.BUILDER",value=adapter};
end
local oldNamespace={BUILDER=legacyBuilders,PRISM=Dox.PRISM,THEME=Dox.THEME};
local function read(path)local f=assert(io.open(path,"rb"));local text=f:read("*a");f:close();return text;end
local legacyTypes={DoxMime=Dox.DoxMime,DoxBlockTag=Dox.DoxBlockTag};
local typeProxy=setmetatable({assert=setmetatable({
    custom=function(value,expected,...)
        if legacyTypes[expected]then assert(class.isinstanceof(value,legacyTypes[expected]));return;end
        if expected=="Dox.SYNTAX" or expected=="Dox.BUILDER"then assert(rawtype(value)=="table" and value.family==expected);return;end
        if expected=="Dox.PRISM" or expected=="Dox.THEME"then assert(lxe.isMember(value,Dox[expected:match("%.(.+)$")]));return;end
        return type.assert.custom(value,expected,...);
    end,
    table=function(value,keyType,valueType,minimum,...)
        if valueType=="DoxMime"then
            type.assert.table(value,keyType,nil,minimum,...);
            for _,item in pairs(value)do assert(class.isinstanceof(item,Dox.DoxMime));end
            return;
        end
        return type.assert.table(value,keyType,valueType,minimum,...);
    end,
},{__index=type.assert})},{__call=function(_,...)return type(...);end,__index=type});
local environment=setmetatable({Dox=oldNamespace,type=typeProxy,
    SortedDictionary=LuaEx.Classes.SortedDictionary,
    DoxBlock=function(text,syntax,...)return Dox.DoxBlock(text,canonicalSyntax[syntax],...);end,
    DoxBuilderHTML=function()return {};end,DoxBuilderPulsarLua=function()return {};end,DoxBuilderGitHubWiki=function()return {};end,
    enum=function()return {};end,
    require=function(name)
        if name=="dox.Statics.DoxSyntaxEnum"then return legacySyntax;end
        return require(name);
    end,
    class=function(name,meta,static,private,protected,public)
        return {meta=meta,private=private,protected=protected,public=public};
    end,
},{__index=_G});
local reference=assert(load(read(pDox.."/legacy/dox/Dox.lua"),"archived-Dox-host","t",environment))();
local function archivedDocument(syntax)
    local object={};local pri={bannerURL="",blockOpen="",blockClose="",blockTags={},defaultBlockTags={},blockStrings={},
        finalized={},Intro="",OutputPath="",mimeTypes=LuaEx.Classes.SortedDictionary(),output=""};
    local data={pri=pri,pub=object};
    for name,fn in pairs(reference.private)do
        if rawtype(fn)=="function"then pri[name]=function(...)return fn(object,data,...);end;end
    end
    for name,fn in pairs(reference.public)do
        object[name:gsub("__FNL$","")]=function(...)return fn(object,data,...);end;
    end
    object.getIntro=function()return pri.Intro;end;object.setIntro=function(value)pri.Intro=value;return object;end;
    object.getOutputPath=function()return pri.OutputPath;end;object.setOutputPath=function(value)pri.OutputPath=value;return object;end;
    reference.protected.Dox(object,data,"Test","Host test","!","!","@",legacySyntax[syntax],{mime});
    return object;
end
local uuid=string.uuid;string.uuid=function()return "host-reference-id";end
local compared,comparisonError=pcall(function()
    for _,syntax in Dox.SYNTAX()do
        local native,old=document(syntax),archivedDocument(syntax.Name);
        check(native.getName()==old.getName() and native.getBlockOpen()==old.getBlockOpen() and
            native.getBlockClose()==old.getBlockClose() and native.getTagOpen()==old.getTagOpen(),"archived parser metadata");
        check(order(native)==order(old),"archived built-in order");
        local definition=Dox.DoxSyntax.fromEnum(syntax);
        local text=definition.getCommentOpen().."! @fqxn Demo.member\n@desc Original parser comparison.\n@param string name Description.\n@example print(1) !"..definition.getCommentClose();
        for _,o in ipairs({native,old})do o.importString(text,mime);o.importString(text,mime);o.setIntro("Original intro");o.setOutputPath("out");end
        for _,member in Dox.BUILDER()do
            native.setBuilder(member);old.setBuilder(legacyBuilders[member.Name]);
            local path,files=exportMemory(native,"Comparison");local oldPath,oldFiles=exportMemory(old,"Comparison");
            check(path==oldPath and native.getOutput()==old.getOutput(),"archived export path/stored output");
            for p,bytes in pairs(files)do check(oldFiles[p]==bytes,"archived complete export bytes: "..syntax.Name.."/"..member.Name);end
            for p in pairs(oldFiles)do check(files[p]~=nil,"same export file manifest");end
        end
    end
end);string.uuid=uuid;assert(compared,comparisonError);
print("PASS Dox host integration: "..checks.." checks.");
