-- Native HTML builder compared byte-for-byte with archived algorithms and assets.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local Builder=Dox.DoxBuilderHTML;local checks=0;
local function check(condition,message)assert(condition,message);checks=checks+1;end
local function reject(action,fragment)
    local ok,err=pcall(action);check(not ok and (not fragment or tostring(err):find(fragment,1,true)),
        "Expected rejection "..tostring(fragment)..", got "..tostring(err));
end
local function read(path)local f=assert(io.open(path,"rb"));local s=f:read("*a");f:close();return s;end
local legacy={PRISM={},THEME={},SYNTAX={}};
for _,name in ipairs({"PRISM","THEME","SYNTAX"})do
    for _,member in Dox[name]()do legacy[name][member.Name]={family="Dox."..name,
        value=name=="SYNTAX" and Dox.DoxSyntax.fromEnum(member) or member.Value};end
end
local typeProxy=setmetatable({assert=setmetatable({custom=function(value,expected,...)
    if expected:match("^Dox")then assert(rawtype(value)=="table" and value.family==expected,"Wrong legacy enum family");return;end
    return type.assert.custom(value,expected,...);
end},{__index=type.assert})},{__call=function(_,...)return type(...);end,__index=type});
local baseEnvironment=setmetatable({type=typeProxy,enum=function()return {};end,
    class=function(name,meta,static,private,protected,public)return {protected=protected,public=public};end},{__index=_G});
local base=assert(loadfile(pDox.."/legacy/dox/Components/DoxBuilder.lua","t",baseEnvironment))();
local environment=setmetatable({Dox=legacy,type=typeProxy,DoxBuilder={MIME={HTML={family="DoxBuilder.MIME",value="html"}}},
    class=function(name,meta,static,private,protected,public)
        return function()
            local object={};local data={pri={Name="",mime=null},pro={blockWrapper={open="",close=""},
                columnWrappers={},copyToClipboardButton="",defaultFilename="",newLine="",outputExtension="",outputMode="w"},pub=object};
            for method,fn in pairs(base.protected)do if method~="DoxBuilder" and rawtype(fn)=="function"then data.pro[method]=function(...)return fn(object,data,...);end;end;end
            for method,fn in pairs(base.public)do object[method]=function(...)return fn(object,data,...);end;end
            for method,fn in pairs(private)do data.pri[method]=function(...)return fn(object,data,...);end;end
            for method,fn in pairs(public)do if method~=name then object[method]=function(...)return fn(object,data,...);end;end;end
            object.getName=function()return data.pri.Name;end;
            public[name](object,data,function(...)return base.protected.DoxBuilder(object,data,...);end);
            return object;
        end;
    end},{__index=_G});
-- Source name points at the retained original location so its source-relative
-- asset fallback is tested with the same directory layout as the native class.
local Reference=assert(load(read(pDox.."/legacy/dox/Builders/HTML/DoxBuilderHTML.lua"),
    "@"..pDox.."/dox/Builders/HTML/DoxBuilderHTML.lua","t",environment))();
local native,old=Builder(),Reference();
check(class.is(Builder) and class.getname(Builder)=="Dox.DoxBuilderHTML");
check(rawget(_G,"DoxBuilderHTML")==nil,"no short alias");
check(class.isa(native,Dox.DoxBuilder) and native.getName()==old.getName());
check(native.getDefaultFilename()==old.getDefaultFilename() and native.getNewLine()==old.getNewLine());
check(native.getBlockWrapper().open==old.getBlockWrapper().open and native.getBlockWrapper().close==old.getBlockWrapper().close);
for _,display in ipairs({"Parameter(s)","Field(s)","Return(s)","Code","Example"})do
    check(native.getColumnWrapperCount(display)==old.getColumnWrapperCount(display));
    for index=1,native.getColumnWrapperCount(display)do
        local a,b=native.getColumnWrapper(display,index),old.getColumnWrapper(display,index);check(a[1]==b[1] and a[2]==b[2]);
    end
end
for _,member in Dox.SYNTAX()do
    local a,b=native.getExampleWrapper(member),old.getExampleWrapper(legacy.SYNTAX[member.Name]);
    check(a[1]==b[1] and a[2]==b[2],"all syntax wrappers preserve Prism names");
end
reject(function()native.getExampleWrapper(Dox.THEME.NORD);end);
local Tag=Dox.DoxBlockTag;local fqxn=Tag({"fqxn"},"FQXN",true);
local tags={fqxn,Tag({"desc"},"Description",false,true),Tag({"param"},"Parameter(s)",false,true,false,false,2),
    Tag({"example"},"Example",false,true),Tag({"see"},"See",false,true,true),
    Tag({"internal"},"Internal",false,false,false,true),Tag({"inheritdoc"},"Inheritdoc")};
local function block(text)return Dox.DoxBlock(text,Dox.SYNTAX.LUA,"@",tags,{fqxn});end
local blocks={block('@fqxn Demo.member\n@desc Content with "quotes", `ticks`, ${interpolation} and </script>.\n@param number count Description.\n@example local x = 1\n@see First link.\n@see Second link.\n@internal Hidden metadata.'),
    block('@fqxn Demo.copy\n@inheritdoc Demo.member'),block('@fqxn Demo.Deep.value\n@desc Unicode café and a child node.')};
-- Reuse the archived host formatter, binding its builder and syntax values only.
local host=read(pDox.."/dox/Dox.lua");local args,body=host:match('    processBlockItem = function%((.-)%)\n(.-)\n    end,');assert(args and body);
local process=assert(load("return function("..args..")\n"..body.."\nend","archived-host-formatter","t",_G))();
local function deterministic(action)
    local uuid=string.uuid;local index=0;string.uuid=function()index=index+1;return string.format("00000000-0000-4000-8000-%012d",index);end;
    local result=table.pack(pcall(action));string.uuid=uuid;assert(result[1],result[2]);return table.unpack(result,2,result.n);
end
local function refresh(builder,syntax,input)
    local data={pri={builder={value=builder},syntax=syntax}};
    return deterministic(function()return builder.refresh(input,function(tag,content)return process(nil,data,tag,content);end);end);
end
local a,b=refresh(native,Dox.SYNTAX.LUA,blocks),refresh(old,legacy.SYNTAX.LUA,blocks);
local function compareTree(left,right)
    for key,node in pairs(left)do check(right[key]~=nil and node()==right[key](),"archived finalized content");compareTree(node,right[key]);end
    for key in pairs(right)do check(left[key]~=nil,"archived finalized names");end
end
compareTree(a,b);check(a.Demo.copy()==a.Demo.member(),"inheritance shares resolved output");
check(not a.Demo.member():find("Hidden metadata",1,true),"utility content excluded");
local function compare(prism,theme,intro,banner)
    local output=native.build("HTML Test",intro,a,prism,banner,theme,Dox.SYNTAX.LUA);
    local expected=old.build("HTML Test",intro,b,prism and legacy.PRISM[prism.Name],banner,theme and legacy.THEME[theme.Name]);
    if output~=expected then
        local at=1;while at<=math.min(#output,#expected) and output:byte(at)==expected:byte(at)do at=at+1;end
        error("HTML difference at "..at.." native="..output:sub(at-80,at+160).." expected="..expected:sub(at-80,at+160));
    end
    check(output==expected,"byte-identical archived HTML");
    check(output:find("HTML Test",1,true) and output:find("prism.min.js",1,true),"title and Prism core");
    return output;
end
local default=compare(nil,nil,"",nil);
for _,theme in Dox.THEME()do compare(Dox.PRISM.OKAIDIA,theme,"<p>Intro `ticks` ${text}.</p>",nil);end
for _,prism in Dox.PRISM()do compare(prism,Dox.THEME.MIDNIGHT_BLUE,"",nil);end
local banner=compare(nil,nil,"<p>Custom intro</p>",'https://example.org/a?x=1&y="quoted"');
check(banner:find("&amp;",1,true) and banner:find("&quot;",1,true),"banner attributes escaped");
check(default:find("prism-okaidia.min.css",1,true) and default:find("prism-lua.min.js",1,true),"default Prism CSS and Lua scripts");
reject(function()native.build("Bad","",a,Dox.THEME.NORD);end);
reject(function()native.build("Bad","",a,nil,nil,Dox.PRISM.DARK);end);
-- Force package-search failure; both implementations must find sibling assets.
local searchpath=package.searchpath;
package.searchpath=function(module,path,...)if module:match('^dox%.Builders%.HTML%.Data%.')then return nil,"forced search miss";end;return searchpath(module,path,...);end;
local fallback=table.pack(pcall(compare,nil,nil,"",nil));package.searchpath=searchpath;
check(fallback[1] and fallback[2]==default,"source-relative asset fallback");
-- The actual I/O helper writes only to memory, with build's asset reads untouched.
local open=io.open;local saved,closed;
io.open=function(path,mode)
    if path=="output/chosen.html"then
        check(mode=="w","HTML export mode");return {write=function(_,content)saved=content;return true;end,
            close=function()closed=true;return true;end};
    end
    return open(path,mode);
end;
local exported=table.pack(pcall(native.export,"output","chosen","HTML Test","",a,nil,nil,nil,Dox.SYNTAX.LUA));io.open=open;
check(exported[1] and exported[2]=="output/chosen.html" and exported[3]==default and saved==default and closed,"native inherited HTML export");
for _,input in ipairs({{block('@fqxn Missing\n@inheritdoc nowhere')},
    {block('@fqxn Cycle.A\n@inheritdoc Cycle.B'),block('@fqxn Cycle.B\n@inheritdoc Cycle.A')}})do
    check(not pcall(refresh,native,Dox.SYNTAX.LUA,input) and not pcall(refresh,old,legacy.SYNTAX.LUA,input),"archived inheritance rejection");
end
local restored=deserialize(serialize(native));
check(class.isinstanceof(restored,Builder) and restored.build("HTML Test","",a)==default,"native builder restoration");
check(clone(native).build("HTML Test","",a)==default,"native clone output");
check(rawequal(clone(Builder),Builder) and rawequal(deserialize(serialize(Builder)),Builder),"canonical class references");
print("PASS HTML builder: "..checks.." checks.");
