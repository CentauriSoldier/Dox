-- Native base builder/MIME: archived wrapper behavior and injected I/O outcomes.
local pTests=assert(debug.getinfo(1,"S").source:match("^@(.+)[/\\][^/\\]+$"));
local pDox=pTests.."/..";
package.path=pDox.."/?.lua;"..pDox.."/../LuaEx/?.lua;"..package.path;
require("LuaEx.load")(2);
local Builder=Dox.DoxBuilder;local checks=0;
local function check(condition,message)assert(condition,message);checks=checks+1;end
local function reject(action,fragment)
    local ok,err=pcall(action);check(not ok and (not fragment or tostring(err):find(fragment,1,true)),
        "Expected rejection "..tostring(fragment)..", got "..tostring(err));
end
local LXC=require("LuaEx.lib.lxc");
LXC.loadSources({["BuilderTest.lxc"]=[=[namespace BuilderTest {
    class Basic : Dox.DoxBuilder {
        public Basic(name,mime,button,filename,newline,wrappers) { base(name,mime,button,filename,newline,wrappers); }
        public override build(title,intro,data,prism,banner,theme,syntax) { return title.."|"..intro; }
        public write(path,content,mode) { return this.writeOutput(path,content,mode); }
        public setMode(mode) { this.outputMode=mode; }
    }
    class Missing : Dox.DoxBuilder {
        public Missing() { base("Missing",Dox.DoxBuilder.MIME.TXT,"","default","\n",{}); }
    }
}]=]},_G);
local Native=BuilderTest.Basic;
local legacyMimes;
local typeProxy=setmetatable({assert=setmetatable({custom=function(value,expected,...)
    if expected=="DoxBuilder.MIME" then
        assert(rawtype(value)=="table" and value.legacyMime,"Expected legacy MIME member");return;
    end
    return type.assert.custom(value,expected,...);
end},{__index=type.assert})},{__call=function(_,...)return type(...);end,__index=type});
local environment=setmetatable({type=typeProxy,
    enum=function(name,names,values)
        local result={};for index,key in ipairs(names)do result[key]={value=values[index],legacyMime=true};end
        legacyMimes=result;return result;
    end,
    class=function(name,meta,static,private,protected,public)
        return function(...)
            local object={};local data={pri={Name="",mime=null},pro={blockWrapper={open="",close=""},
                columnWrappers={},copyToClipboardButton="",defaultFilename="",newLine="",outputExtension="",outputMode="w"}};
            for method,fn in pairs(protected)do
                if rawtype(fn)=="function" and method~=name then data.pro[method]=function(...)return fn(object,data,...);end;end
            end
            for method,fn in pairs(public)do object[method]=function(...)return fn(object,data,...);end;end
            object.getName=function()return data.pri.Name;end;
            object.build=function(title,intro)return title.."|"..intro;end;
            object.write=data.pro.writeOutput;
            object.setMode=function(mode)data.pro.outputMode=mode;end;
            protected[name](object,data,...);return object;
        end;
    end},{__index=_G});
local Reference=assert(loadfile(pDox.."/legacy/dox/Components/DoxBuilder.lua","t",environment))();
check(class.is(Builder) and class.getname(Builder)=="Dox.DoxBuilder");
check(rawget(_G,"DoxBuilder")==nil,"no short alias");
check(lxe.isEnum(Builder.MIME) and #Builder.MIME==4,"native embedded MIME");
local expected={HTML="html",LUACOMPLETERC="luacompleterc",MARKDOWN="MD",TXT="txt"};
for name,value in pairs(expected)do check(Builder.MIME[name].Value==value and legacyMimes[name].value==value,"MIME payload preserved");end
reject(function()Builder("Base",Builder.MIME.TXT);end,"constructor");
local function wrappers()return {Description={{"<p>","</p>"}},Parameters={{"<type>","</type>"},{"<name>","</name>"}}};end
local function newPair(mime,input)
    input=input or wrappers();
    return Native("Test",mime or Builder.MIME.HTML,"copy","default","\n",input),
        Reference("Test",legacyMimes[(mime or Builder.MIME.HTML).Name],"copy","default","\n",input);
end
local native,old=newPair();
local function equalPair(a,b)
    check(a[1]==b[1] and a[2]==b[2],"archived wrapper pair");
end
for _,method in ipairs({"getName","getCopyToClipboardButton","getDefaultFilename","getNewLine"})do
    check(native[method]()==old[method](),"archived "..method);
end
check(rawequal(native.getMime(),Builder.MIME.HTML));
check(native.getBlockWrapper().open==old.getBlockWrapper().open and native.getBlockWrapper().close==old.getBlockWrapper().close,"archived block wrapper");
for step=1,120 do
    local display=step%2==0 and "Description" or "Custom";
    local index=1+step%3;
    local count=native.getColumnWrapperCount(display);
    index=math.min(index,count+1);
    check(native.setColumnWrapper(display,index,"<"..step..">","</"..step..">")==old.setColumnWrapper(display,index,"<"..step..">","</"..step..">"));
    equalPair(native.getColumnWrapper(display,index),old.getColumnWrapper(display,index));
    check(native.getColumnWrapperCount(display)==old.getColumnWrapperCount(display));
    local a,b=native.getColumnWrappers(display),old.getColumnWrappers(display);
    check(#a==#b);for i,pair in ipairs(a)do equalPair(pair,b[i]);end
end
local external=wrappers();local independent=Native("Copied",Builder.MIME.TXT,nil,"default",false,external);
external.Description[1][1]="changed";
check(independent.getColumnWrapper("Description",1)[1]=="<p>" and independent.getNewLine()=="\n","constructor copies wrappers and newline fallback");
local returned=independent.getColumnWrapper("Description",1);returned[1]="changed";
check(independent.getColumnWrapper("Description",1)[1]=="<p>","getter copies wrappers");
local iterator=independent.eachColumnWrapper("Description");local i,pair=iterator();pair[1]="changed";
check(i==1 and independent.getColumnWrapper("Description",1)[1]=="<p>" and iterator()==nil);
native.clearColumnWrappers("Custom");old.clearColumnWrappers("Custom");
check(native.getColumnWrapperCount("Custom")==old.getColumnWrapperCount("Custom"));
native.clearColumnWrappers();old.clearColumnWrappers();check(native.getColumnWrapperCount("Description")==0);
equalPair(native.getColumnWrapper("missing",1),{"",""});
reject(function()independent.setColumnWrapper("Description",3,"a","b");end,"out of bounds");
check(independent.getColumnWrapperCount("Description")==1,"failed append is atomic");
for _,args in ipairs({{"",Builder.MIME.HTML,"","default"},{"Name","html","","default"},
    {"Name",Builder.MIME.HTML,false,"default"},{"Name",Builder.MIME.HTML,"","bad/name"},
    {"Name",Builder.MIME.HTML,"","default","\n",{Description={{1,"close"}}}}})do
    reject(function()Native(table.unpack(args));end);
end
local missing=BuilderTest.Missing();
reject(function()missing.build();end,"has not been defined");
reject(function()missing.formatBlockContent("id","Display","Content");end,"has not been defined");
reject(function()missing.formatCombinedBlockContent("Display","Content","id");end,"has not been defined");
-- Intercept I/O so export tests cannot overwrite user files.
local function output(action,mode)
    local open=io.open;local record={writes=0,closes=0};
    io.open=function(path,access)
        record.path,record.mode=path,access;
        if mode=="open" then return nil,"injected open failure";end
        return {write=function(_,text)
            record.writes=record.writes+1;record.text=text;
            if mode=="raiseWrite"then error("injected write failure");end
            if mode=="returnWrite"then return nil,"injected write failure";end
            return true;
        end,close=function()
            record.closes=record.closes+1;
            if mode=="raiseClose"then error("injected close failure");end
            if mode=="returnClose"then return nil,"injected close failure";end
            return true;
        end};
    end;
    local result=table.pack(pcall(action));io.open=open;return result,record;
end
for name,extension in pairs(expected)do
    local a,b=newPair(Builder.MIME[name]);
    for _,filename in ipairs({"chosen","bad/name",false})do
        local ra,wa=output(function()return a.export("output",filename,"Title","Intro",{});end);
        local rb,wb=output(function()return b.export("output",filename,"Title","Intro",{});end);
        check(ra[1] and rb[1] and ra[2]==rb[2] and ra[3]==rb[3],"archived export result");
        check(wa.path==wb.path and wa.text==wb.text and wa.mode==wb.mode and wa.closes==1,"archived export output");
        check(wa.path:sub(-#extension)==extension,"MIME extension case preserved");
    end
end
for _,mode in ipairs({"open","raiseWrite","returnWrite","raiseClose","returnClose"})do
    local result,record=output(function()independent.write("output/failure.txt","bytes","wb");end,mode);
    check(not result[1] and tostring(result[2]):find("output/failure.txt",1,true),"I/O failure reports destination");
    check(record.closes==(mode=="open" and 0 or 1),"opened handles close once after any write failure");
    local oldResult,oldRecord=output(function()old.write("output/failure.txt","bytes","wb");end,mode);
    check(not oldResult[1] and oldRecord.closes==record.closes and oldRecord.writes==record.writes,
        "archived failure/cleanup behavior");
end
local fallbackResult,fallbackWrite=output(function()return independent.export("output",nil,"bad/name","Intro",{});end);
check(fallbackResult[1] and fallbackWrite.path=="output/default.txt","unsafe title uses default filename");
local copy=clone(independent);copy.setColumnWrapper("Description",1,"copy","copy");
check(independent.getColumnWrapper("Description",1)[1]=="<p>","native clone wrapper independence");
local graph={builder=independent,alias=independent};graph.self=graph;
local loaded=deserialize(serialize(graph));
check(rawequal(loaded.builder,loaded.alias) and rawequal(loaded.self,loaded),"graph sharing/cycles");
check(class.isinstanceof(loaded.builder,Native) and loaded.builder.getName()=="Copied","concrete builder restoration");
check(rawequal(loaded.builder.getMime(),Builder.MIME.TXT) and loaded.builder.getColumnWrapper("Description",1)[1]=="<p>");
check(rawequal(deserialize(serialize(Builder.MIME.HTML)),Builder.MIME.HTML),"canonical MIME persistence");
reject(function()LXC.loadSources({["BuilderFinal.lxc"]="namespace BuilderTest { class Bad : Dox.DoxBuilder { public override getName() {} } }"},_G);end,"final");
print("PASS DoxBuilder: "..checks.." checks.");
