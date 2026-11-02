-- Remaining 28 native parsers compared with archived constructor bodies.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local checks=0;
local function check(value,message)assert(value,message);checks=checks+1;end
local function reject(action)local ok,err=pcall(action);check(not ok,tostring(err));end
local LXC=require("LuaEx.lib.lxc");
LXC.loadSources({["RemainingParserReference.lxc"]=[=[namespace RemainingParserTest {
    class Reference : Dox.Parser { public Reference(...) { base(...); } }
}]=]},_G);
local names={"DoxAda","DoxC","DoxCPlusPlus","DoxCSharp","DoxCSS","DoxDart","DoxElm","DoxFortran","DoxFSharp",
    "DoxGo","DoxGroovy","DoxHaskell","DoxHTML","DoxJava","DoxJavaScript","DoxJulia","DoxKotlin","DoxMatlab",
    "DoxObjectiveC","DoxPerl","DoxPHP","DoxPython","DoxRuby","DoxRust","DoxScala","DoxSwift","DoxTypeScript","DoxXML"};
for _,name in ipairs(names)do
    local Parser=Dox[name];
    local environment=setmetatable({DoxMime=Dox.DoxMime,
        class=function(className,meta,static,private,protected,public,parent,final)return {constructor=public[className],final=final};end},{__index=_G});
    local archived=assert(loadfile(pDox.."/legacy/dox/Parsers/"..name..".lua","t",environment))();
    local function arguments(title)
        local args;archived.constructor({},{},function(...)args=table.pack(...);end,title);return args;
    end
    local expected=arguments("Parser test");local expectedMimes={};local extension;
    for _,value in ipairs(expected[7])do expectedMimes[value.getName()]=true;extension=extension or value.getName();end
    local function reference(title)local args=arguments(title);return RemainingParserTest.Reference(table.unpack(args,1,args.n));end
    local function mime(o)
        local result,count;count=0;
        for key,value in o.getMimeTypes()()do check(expectedMimes[key],"original MIME key");if key==extension then result=value;end;count=count+1;end
        check(count==#expected[7],"original MIME count");return result;
    end
    local native,old=Parser("Parser test"),reference("Parser test");
    check(class.is(Parser) and class.getname(Parser)=="Dox."..name,"original class-name spelling");
    check(class.isa(native,Dox.Parser),"native base parser");
    check(rawget(_G,name)==nil,"no global aliases");
    check(archived.final==true,"original finality");
    for _,method in ipairs({"getName","getSyntax","getBlockOpen","getBlockClose","getTagOpen","getIntro","getOutputPath","getOutput"})do
        check(native[method]()==old[method](),"archived metadata: "..method);
    end
    check(native.getSyntax()==expected[6] and tostring(native)==name.." (! ... !)","syntax and string form");
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
    for _,text in ipairs({"","plain","&quot;&lt;&amp;",[=[\[brackets\]]=],"\n","\r\n","identity sample"})do
        check(nm.getPreProcessor()(text)==text and om.getPreProcessor()(text)==text,"identity preprocessing bytes");
    end
    check(nm.getPreProcessor()~=mime(Parser("Other")).getPreProcessor(),"fresh identity callback");
    for _,invalid in ipairs({""," ",false,1,{}})do reject(function()Parser(invalid);end);end
    reject(function()Parser();end);
    reject(function()LXC.loadSources({["NasmFinal.lxc"]="namespace RemainingParserTest { class Invalid : Dox."..name.." {} }"},_G);end);
    local function exportMemory(o)
        local open=io.open;local writes={};
        io.open=function(path,mode)
            if mode=="w" or mode=="wb"then
                local chunks={};writes[path]=chunks;
                return {write=function(_,text)chunks[#chunks+1]=text;return true;end,close=function()return true;end};
            end
            return open(path,mode);
        end;
        local ok,path=pcall(o.export,"ParserTest");io.open=open;assert(ok,path);
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
    local syntax=Dox.DoxSyntax.fromEnum(expected[6]);
    local source=syntax.getCommentOpen().."! @fqxn Demo.member\n@desc Original content remains &quot;encoded&quot;.\n@param number count Count of items.\n@return number result The result.\n@example example content\n!"..syntax.getCommentClose();
    local uuid=string.uuid;string.uuid=function()return "parser-example-id";end
    local ok,err=pcall(function()
        for _,o in ipairs({native,old})do
            o.setIntro("Parser intro");o.setOutputPath("out");o.setBanner("banner.png");
            o.setTheme(Dox.THEME.NORD);o.setPrismTheme(Dox.PRISM.TWILIGHT);
            o.importString(source,mime(o));o.importString(source,mime(o));
        end
        for _,builder in Dox.BUILDER()do
            native.setBuilder(builder);old.setBuilder(builder);
            local files=sameExport(native,old,"archived parser constructor");
            if builder==Dox.BUILDER.HTML then
                local html;for _,bytes in pairs(files)do html=bytes;end
                check(html:find("language-"..syntax.getPrismName(),1,true),"original highlighting name");
                check(html:find("example content",1,true) and html:find("Original content remains &quot;encoded&quot;.",1,true),"content parsed with identity preprocessing");
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
        -- Exercise every advertised extension, including case-insensitive file matching.
        for advertised in pairs(expectedMimes)do
            local open=io.open;local closed=0;local path="input."..advertised:upper();
            io.open=function(file,mode)
                if file==path then check(mode=="r","file read mode");return {read=function()return source;end,close=function()closed=closed+1;end};end
                return open(file,mode);
            end;
            local fileParser=Parser("Parser test");
            local imported,importError=pcall(function()fileParser.importFiles({path,"skip.unsupported"});end);
            io.open=open;assert(imported,importError);check(closed==1,"recognized file closed, unsupported extension skipped");
            local stringParser=Parser("Parser test");stringParser.importString(source,mime(stringParser));
            sameExport(fileParser,stringParser,"file/string import/"..advertised);
        end
    end);string.uuid=uuid;assert(ok,name..": "..tostring(err));
end
print("PASS remaining 28 parsers: "..checks.." checks.");
