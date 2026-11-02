-- Native Wiki builder versus archived page manifests and in-memory multi-file export.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local Builder=Dox.DoxBuilderGitHubWiki;local checks=0;
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
-- Use the archived base's actual write/close implementation, binding only class plumbing.
local baseEnvironment=setmetatable({enum=function()return {};end,
    class=function(name,meta,static,private,protected,public)return protected;end},{__index=_G});
local baseMethods=assert(loadfile(pDox.."/legacy/dox/Components/DoxBuilder.lua","t",baseEnvironment))();
local environment=setmetatable({DoxBuilder={MIME={MARKDOWN={value="MD"}}},
    class=function(name,meta,static,private,protected,public)
        return function()
            local object={};local data={pro={}};
            for method,fn in pairs(public)do
                if method~=name then object[method]=function(...)return fn(object,data,...);end;end
            end
            data.pro.writeOutput=function(...)return baseMethods.writeOutput(object,data,...);end;
            public[name](object,data,function()end);return object;
        end;
    end},{__index=_G});
local Reference=assert(loadfile(pDox.."/legacy/dox/Builders/GitHubWiki/DoxBuilderGitHubWiki.lua","t",environment))();
local native,old=Builder(),Reference();
check(class.is(Builder) and class.getname(Builder)=="Dox.DoxBuilderGitHubWiki");
check(rawget(_G,"DoxBuilderGitHubWiki")==nil,"no short alias");
check(class.isa(native,Dox.DoxBuilder) and native.getName()=="DoxBuilderGitHubWiki");
check(rawequal(native.getMime(),Dox.DoxBuilder.MIME.MARKDOWN) and native.getDefaultFilename()=="Home");
local LXC=require("LuaEx.lib.lxc");
LXC.loadSources({["WikiSyntax.lxe"]=[=[namespace WikiTest {
    public enum SYNTAX { LUA = Dox.DoxSyntax("Lua","--[[","]]","\\","lua"); }
}]=]},_G);
local syntax=WikiTest.SYNTAX.LUA;local legacySyntax={value=syntax.Value};
local Tag=Dox.DoxBlockTag;local fqxn=Tag({"fqxn"},"FQXN",true);
local tags={fqxn,Tag({"desc"},"Description",false,true),Tag({"param"},"Parameter(s)",false,true,false,false,2),
    Tag({"example"},"Example",false,true),Tag({"code"},"Code",false,true),
    Tag({"see"},"See",false,true,true),Tag({"internal"},"Internal",false,false,false,true),
    Tag({"inheritdoc"},"Inheritdoc")};
local function block(text)return Dox.DoxBlock(text,syntax,"@",tags,{fqxn});end
local fixtures={
    block('@fqxn Demo.member\n@desc <p>A <strong>bold</strong> member with <a href="#Demo.other">another member</a>.</p>\n@param number count The number.\n@example print(&quot;hello&quot;)\n@see <a href="https://example.com/a(b)">External</a>\n@see <a href="#local-section">Section</a>\n@internal Must stay hidden.'),
    block('@fqxn Demo.other\n@desc Other member.\n@code local x = 1'),
    block('@fqxn Demo.inherited\n@inheritdoc Demo.member'),
    block('@fqxn Café\n@desc Unicode entry.'),
    block('@fqxn Tilde~Name\n@desc Literal tilde.'),
};
local function compare(blocks,title)
    local a,b=native.refresh(blocks),old.refresh(blocks);
    check(equal(a,b),"archived Wiki hierarchy and sharing");
    local fa=native.build(title,'<p>Intro <a href="#Demo.member">member</a></p>',a,nil,"https://example.com/banner(a).png",nil,syntax);
    local fb=old.build(title,'<p>Intro <a href="#Demo.member">member</a></p>',b,nil,"https://example.com/banner(a).png",nil,legacySyntax);
    check(equal(fa,fb),"byte-identical archived page manifests");
    local count=0;for name,content in pairs(fa)do
        check(type(content)=="string" and name:sub(-3)==".md","Markdown page manifest");count=count+1;
    end
    check(count==#a.names+2,"one page per name plus Home and sidebar");
    return a,fa;
end
local data,files=compare(fixtures,"Awesome Wiki");
check(data.entries.Demo and not data.entries.Demo.documented and #data.entries.Demo.children==3,"navigation ancestors");
check(rawequal(data.entries["Demo.inherited"].items,data.entries["Demo.member"].items),"inheritance shares resolved content");
check(files["API-Caf~C3~A9.md"] and files["API-Tilde~7EName.md"],"portable UTF-8 and tilde filenames");
local page=files["API-Demo.member.md"];
check(page:find("(API-Demo.other)",1,true) and page:find("```lua",1,true),"known links and source code language");
check(not page:find("Must stay hidden",1,true),"utility metadata omitted");
check(page:find("https://example.com/a%28b%29",1,true),"unsafe Markdown destinations escaped");
local _,headings=page:gsub("## See","");check(headings==1,"combined repeated sections have one heading");
compare({},"Empty Wiki");
for count=1,30 do
    local blocks={};for i=1,count do blocks[i]=block("@fqxn Generated.Group.item"..i.."\n@desc Entry "..i..".");end
    compare(blocks,"Generated Wiki "..count);
end
for _,blocks in ipairs({{fixtures[1],fixtures[1]},
    {block("@fqxn Case\n@desc Upper."),block("@fqxn case\n@desc Lower.")},
    {block("@fqxn Missing\n@inheritdoc nowhere")},
    {block("@fqxn Cycle.A\n@inheritdoc Cycle.B"),block("@fqxn Cycle.B\n@inheritdoc Cycle.A")},
    {block("@fqxn "..string.rep("a",241).."\n@desc Too long.")}})do
    check(not pcall(native.refresh,blocks) and not pcall(old.refresh,blocks),"archived duplicate/collision/inheritance/name rejection");
end
local function capture(action,failAt)
    local open=io.open;local result={files={["output/unrelated.txt"]="preserve"},order={},closed=0,opened=0};
    io.open=function(path,mode)
        result.opened=result.opened+1;check(mode=="wb","Wiki uses binary mode");
        local failing=result.opened==failAt;
        return {write=function(_,text)
            if failing then return nil,"injected Wiki write failure";end
            result.files[path]=text;result.order[#result.order+1]=path;return true;
        end,close=function()result.closed=result.closed+1;return true;end};
    end;
    local returns=table.pack(pcall(action));io.open=open;return returns,result;
end
for _,filename in ipairs({"Home","Start Here","bad/name"})do
    local ra,wa=capture(function()return native.export("output",filename,"Wiki","Intro",data,nil,nil,nil,syntax);end);
    local rb,wb=capture(function()return old.export("output",filename,"Wiki","Intro",data,nil,nil,nil,legacySyntax);end);
    check(ra[1] and rb[1] and ra[2]==rb[2] and ra[3]==rb[3],"archived landing-page return");
    check(equal(wa.files,wb.files) and equal(wa.order,wb.order),"byte-identical exports and write order");
    check(wa.files["output/unrelated.txt"]=="preserve" and wa.closed==wa.opened,"unrelated files preserved and handles closed");
end
for _,filename in ipairs({"API-reserved","_Sidebar"})do
    local result,writes=capture(function()native.export("output",filename,"Wiki","Intro",data);end);
    check(not result[1] and writes.opened==0,"reserved landing names fail before writing");
end
local ra,wa=capture(function()native.export("output",nil,"Wiki","Intro",data,nil,nil,nil,syntax);end,2);
local rb,wb=capture(function()old.export("output",nil,"Wiki","Intro",data,nil,nil,nil,legacySyntax);end,2);
check(not ra[1] and not rb[1] and equal(wa.files,wb.files) and equal(wa.order,wb.order),"partial failure preserves identical prior writes");
check(wa.opened==2 and wa.closed==2 and wa.files["output/unrelated.txt"]=="preserve","failed exports close files and do not delete unrelated content");
local restored=deserialize(serialize(native));
check(class.isinstanceof(restored,Builder) and equal(restored.build("Wiki","Intro",data,nil,nil,nil,syntax),native.build("Wiki","Intro",data,nil,nil,nil,syntax)),"native restoration");
check(equal(clone(native).build("Wiki","Intro",data),native.build("Wiki","Intro",data)),"native clone output without syntax");
check(rawequal(clone(Builder),Builder) and rawequal(deserialize(serialize(Builder)),Builder),"canonical class references");
reject(function()LXC.loadSources({["WikiChild.lxc"]="namespace WikiTest { class Child : Dox.DoxBuilderGitHubWiki {} }"},_G);end,"final");
print("PASS Wiki builder: "..checks.." checks.");
