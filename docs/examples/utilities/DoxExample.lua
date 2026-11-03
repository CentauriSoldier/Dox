-- Locate the shared bootstrap relative to this tutorial, regardless of cwd.
local pSource = debug.getinfo(1, "S").source:sub(2):gsub("\\", "/");
local pExamples = assert(pSource:match("^(.*)/[^/]+/[^/]+%.lua$"));
local tPaths = dofile(pExamples.."/support/bootstrap.lua");
local pDocs = tPaths.docs;

local D=require("examples.support.tutorial").new("Documentation generation","Generate HTML from real source comments, inspect output and preserve the generated artifact in memory.")

D.section("Your document", "A title is a string; imported comments provide the documentation structure.")
local title=D.input("title","LuaEx null documentation")
local dox=Dox.DoxLua(title)
D.section("Import source", "Import a known source file directly without native directory enumeration.")
local source=assert(package.searchpath("LuaEx.init", package.path)):gsub("init%.lua$", "lib/null.lua")
local file=assert(io.open(source,"r"));local text=file:read("*a");file:close()
D.show("Source bytes",#text);D.check("Source contains documentation",text:find("@fqxn",1,true)~=nil)
dox.importFile(source,true)
D.section("Introduction", "Escape user text before placing it into HTML markup.")
local escaped=title:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"):gsub('"',"&quot;")
dox.setIntro("<h1>"..escaped.."</h1><p>Generated from the real LuaEx null source.</p>")
D.show("Escaped title",escaped)
D.section("Build and export", "The HTML builder writes into the example resources directory.")
dox.refresh();dox.setOutputPath(tPaths.docs.."/examples/resources")
local destination=dox.export("DoxExample");D.show("Destination",destination)
D.section("Inspect generated data", "A complete document is a nonempty HTML string, not a class instance.")
local output=dox.getOutput();D.equal("Output type",type(output),"string")
D.check("Nonempty output",#output>0);D.show("HTML bytes",#output)
D.check("Contains your intro",output:find(escaped,1,true)~=nil)
D.section("Verify artifact", "Read the exported HTML; text-mode exports may use platform line endings.")
local saved=assert(io.open(tPaths.docs.."/examples/resources/DoxExample.html","rb"));local restored=saved:read("*a");saved:close()
D.show("Saved bytes", #restored)
D.check("Artifact matches output", restored:gsub("\r\n", "\n") == output:gsub("\r\n", "\n"))

D.finish()
