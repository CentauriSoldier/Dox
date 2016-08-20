--[[*
@authors Centauri Soldier
@copyright Copyright © 2016 Centauri Soldier
@description
	<h2>Dox</h2>
	<h3>The Simple Lua Documentation Generator</h3>	
	<p>Dox is a light-weight script designed to parse crafted lua comments regarding modules and functions and output them to readable, sorted and linked HTML. Dox enables you to quickly and simply create documentation for your lua code without the need to install programs or to run anything other than the Dox script. In fact, it's so simple, you can have documentation in as few as 2 lines of code.</p>
@email
@features
	<h3>Multi-platform</h3>
	<p>Dox works with all major versions of Windows and Linux.</p>
	<p>Dox can be used on unix based systems or Windows without having to convert directory or file paths. Dox will auto-detect and convert paths as needed.</p>
	<h3>No Dependencies</h3>
	<p>Dox needs nothing but itself and your lua files in order to run correctly. No installing, no configuring, no mess.</p>
	<h3>Dox is Robust</h3>
	<p>Dox is fine with you mixing up your code. Functions from different modules may be in one single file or you may even have a single module spread around different files. Dox is very forgiving in how you organize your modules. You could even have all your dox comments for multiple modules in a single file <i>(although such a practice is not likely to be desired or cenvenient, just meant as demonstration)</i>. Simply put, Dox loves your code no matter where it's at and how it's organized <i>(or unorganized, for that matter)</i>. Dox will sort it all out for you when it's processed. There's no need for you go out of your way to organize functions or modules a certain way. Organize them how you please and Dox will do the rest.</p>		
@license <p>The MIT License (MIT)<br>
<br>
Copyright (c) 2016 Centauri Soldier<br>
<br>
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:<br>
<br>
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.<br>
<br>
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
</p>
@plannedfeatures
<ul>
	<li>Allow themes to set images</li>
	<li>Set return section in the html to show no return if none are listed.</li>
	<li>Finish and port the new util filesystem function to 'os.lua' in the luax module</li>
	<li>Allow Table Input for themes</li>
	<li>Responsive CSS for menus</li>
	<li>Force all menu items into the top menu if there only one module in the output</li>
	<li>Dox menu item with home, usage and other useful pages</li>
	<li>Add project info function (for all compiled modules);</li>
	<li>ADD the ability to get HTML string only without needing to write a file</li>
	<li>TODO - AddSupport for custom, external css ===>>> PUT INTO HTML HEAD <link rel="stylesheet" href="..dox.PageVars.CSSPathAndVersion.."></li>	
	<li>Add a 'Custom' line type</li>	
	<li>Add support for new lines after certain tags in the function block</li>
	<li>Add Support for TODO, Current Features and Planned Feature</li>
	<li>Add auto-css assignment if css tag is not present in file (using lua debug library to get directory of this file)</li>	
	<li>More theme support.</li>
</ul>
@moduleid dox|Dox,dox.base64|Dox.Base64,dox.css|Dox.CSS,dox.html|Dox.HTML,dox.theme|Dox.Theme,dox.parse|Dox.Parse,dox.util|Dox.Util
@todo
<ul>
	<li>Add Mac Support</li>
	<li>Test wrapping block items in '&lt;pre&gt;' html tags</li>
	<li>Auto-remove parantheses in function name before processing</li>
	<li>Return the paramters/return as a table instead of a string (convert blockToTable to work for the html)</li>
	<li>More awareness in function sorting</li>
	<li>Put question marks where version info goes when the info is not available</li>
	<li>Redo Block layout to be simpler</li>
	<li>Fix HTML bug that occurs when module info is not present</li>
	<li>Create css for inner--module html classes such as 'parameter'.</li>
	<li>Create code glossary for the terms used within the dox code such as 'module', 'block', etc.</li>
	<li>Allow multiple types in parameters for functions</li>
	<li>Clean up css and html (get some help from someone who knows html/css well)</li>
	<li>Fix the space-finding (%s) pattern matching attempt in gsub</li>
	<li>Fix the top-right contentwrapper corner, it's cutting off part of the scroll bar</li>
	<li>CONSIDER AUTO-CHECKING FOR LINKS AND ADDING THEM FOR THE 'getAccordionList()' method in dox.html</li>
	<li>Deal with module name conflicts</li>
	<li>Add CSS/HTML validation tags to the footer, update the footer with real data back to the github</li>
	<li>Fix the width issue in the css #contentwrapper (it's currently using a hack)</li>
	<li>Write a short guide showing how to add tags to the different block types (HIGH)</li>
	<li>Create a LOVE-based GUI for making these blocks (LOW)</li>	
	<li>Find out why 'funct' triggers an error (as it should) but 'function' does not when looking for an extra character on the 'func' tag LOW PRIORITY</li>
	
</ul>
@usage
	<h2>Take a breath...</h2>
	Now, I know this is a new way to document your code, but I've made it as painless as possible. Once you read this section, you'll be ready to start documenting and you'll see how simple Dox is to use.
	<h2>Function Info Block</h2>
		<p>
		This is primary element of Dox that makes it work. In fact, without at least one function info block, Dox will not process the target module since there would be no information to process.
		<br><br>
		The function info block is wrapped in a multi-line lua comment whose start tag is <i><b>--<span>[</span>[!</b></i> and end tag is <i><b>!]<span>]</span></b></i>.						
		</p>
	<h3>Function Info Block Block Tags</h3>
		<p>
		Elements inside the function info block are designated by an "\@" symbol directly followed by the desired tag and tag information.
		<br>
		Below is a list of currently usable tags for this block as well as their formatting and usage details.
		</p>
		<ul>
			<li>Description</li>
			<li>Example</li>
			<li>Function</li>
			<li>Module</li>
			<li>Parameter</li>
			<li>Return</li>
			<li>Scope</li>
			<li>Usage</li>			
		</ul>		
	<h2>Module Info Block</h2>
		<p>
		The module information is wrapped in a multiline lua comment whose start tag is <i><b>--<span>[</span>[</b><b>*</b></i> and end tag is <i><b>*</b></i><b>]<span>]</span></b>. The content of this block is displayed at the top of the module page within and accordion menu (the one you're using right now).
		<br><br>
		<b>Note:</b> Unlike (at least one) function info block, the module info block is <b>not</b> required. Dox will function just fine with or without the module info block; you may omit the entire thing if you wish. Additionaly, if you do choose to use the module info block, only one of the tags (listed below) are required: the 'module' tag is required if using the module info block although you may use one, all or none of the remaining tags (or anything in between).
		<br><br>
		Unlike the function info block, the module info block has <b>no</b> tags that are sensitive to spaces and new lines. This feature makes it very easy to use html with your module info block. As you can see, you're reading text right now that has been formatted within the comment block of the dox.lua file.
		<br><br>
		Within the block are tags. These tags start and end just like html tags do, with <i>&lt;tagname&gt;</i> as the start tag and <i>&lt;/tagname&gt;</i> as the end tag where <i>tagname</i> is the name of the tag. Below is a complete list of supported tags.
		</p>
		<ul>
			<li>authors</li>
			<li>copyright</li>			
			<li>dependencies</li>
			<li>description</li>
			<li>features</li>
			<li>email</li>
			<li>license</li>
			<li>moduleid<i>(required)</i></li>
			<li>plannedfeatures</li>
			<li>todo</li>
			<li>usage</li>
			<li>version</li>
			<li>versionhistory</li>
			<li>website</li>
		</ul>
		<h3>The moduleid Tag</h3>
		<p>You may enter one to many items for the <i>'moduleid'</i> tag. For example, if your module name is <b><i>myClass</i></b> then you'd enter it exactly as the class name since the <i>'moduleid'</i> tag <b>is</b> case sensitive.; however, you can control how it's displayed at the top of the page. To include a display name, simply use a pipe (<b>|</b>) and type the display next like this <b><code>myClass|MyClass</code></b>.
		<br><br>
		If you have sub modules such as <b><i>myClass.otherStuff</i></b> and you'd like the module block for <b><i>myClass</i></b> to display on the <b><i>myClass.otherStuff</i></b> page, use a comma to indicate another module and simlpy add it the <i>'moduleid'</i> tag like so: <b><code>myClass|MyClass,myClass.otherStuff</code></b> and if you'd like a differnt display name for that module too, just add it in: <b><code>myClass|MyClass,myClass.otherStuff|MyClass.otherStuff</code></b>. It's that easy.
		</p>
	<h2>Special Characters</h2>
		<p>The '\@' symbol cannot be used in your text without escaping it since it is a special character that tells Dox where to start a line; however, you can escape it in your text using a backslash <i>(\)</i> and the '\@' will be put there by Dox when processing is complete: E.g., \@. Additionaly, any text inside free-format items (like authors, website, description, etc. as opposed to items like param, function, etc. that are more restricted) is treated like html including any html tags you may want to use. Of course, this means that you'll need to escape the '\<' and '\>' symbols in your text if you want them to be presented as-is.
		<br><br>
		Below is a complete list of special characters that need escaped to be displayed as themselves.
		</p>
		<br>
		<ul>
			<li>\@</li>
			<li>&gt;</li>
			<li>&lt;</li>
		</ul>
@version 0.0.8
@versionhistory
<ul>
	<li>
		<b>0.0.9</b>
		<br>
		<p>Added support for linux.</p>
	</li>
	<li>
		<b>0.0.8</b>
		<br>
		<p>Fixed a bug in the local 'import()' function.</p>
	</li>
	<li>
		<b>0.0.7</b>
		<br>		
		<p>Added the ability to allow a module block to be displayed for multiple modules as desired</p>
		<p>Module names can now be displayed differently as desired.</p>
	</li>
	<li>
		<b>0.0.6</b>
		<br>
		<p>Fixed a bug that was omitting the last entry of blocks.</p>		
		<p>Added the ability for dox to normally and recursively scan directories and process all files at once.</p>
	</li>
	<li>
		<b>0.0.5</b>
		<br>
		<p>Fixed a bug that allowed empty modules and empty blocks.</p>
		<p>Reconfigured Start and End tags to be easier to use.</p>
		<p>Reconfigured function blocks tags to be easier to use.</p>
	</li>
	<li>
		<b>0.0.4</b>
		<br>
		<p>Added the binary module and included embeded images for the output.</p>
		<p>Added the <i>Welcome.html</i> page.</p>		
	</li>
	<li>
		<b>0.0.3</b>
		<br>
		<p>Moved from a single-page output to a multi-page one.</p>
		<p>Added the Module Info panel for each module.</p>
		<p>Output CSS to and external file (style.css).</p>
	</li>
	<li>
		<b>0.0.2</b>
		<br>
		<p>Refactored the code and ported all logical functions to modules.</p>		
	</li>	
	<li>
		<b>0.0.1</b>
		<br>
		<p>Created Dox in all its wonder...and despair.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier/Dox
*]]
dox = {};

--warn the user if debug is missing
if not debug then
error("Dox requires the debug library to operate. Please use a version of lua that includes debug.")
end

--prevents 'processFile()' from resetting 'dox.Modules' and writing files while being called by 'processDir()'
local bDirProcessing = false;

--[[!
@module dox
@func getLocalPath
@scope local
@desc Determines the relative path from which the script is called.
@ret sPath string The local path from which dox is run.
!]]
local function getLocalPath()
--determine the call location
local sPath = debug.getinfo(1, "S").source;
--remove the calling filename
sPath = sPath:gsub("@", ""):gsub("dox.lua", "");
--remove the "/" at the end
return sPath:sub(1, sPath:len() - 1)
end

--allows the loading of files relatively without the need for absolute paths
--[[!
@module dox
@func import
@scope local
@desc A version of the 'require()' function that uses the local path. Used to require the other local modules the 'dox.lua' file needs.
@file dox.lua
!]]
local function import(sFile)
sPath = getLocalPath();

--format the path to be suitable for the 'require()' function
sPath = sPath:gsub("\\", "."):gsub("/", ".");
sFile = sFile:gsub("\\", "."):gsub("/", ".");

--call it in
require(sPath..'.'..sFile);
end

--import the utility functions
import("util");

--rename some of the util functions for convenience
local trim = dox.util.trim;

--import the settings file
import("settings");
--import the theme file
import("theme");
--import the base64 file
import("base64");
--import the css file
import("css");
--import the parse file
import("parse");
--import the html file
import("html");


--MAKE THIS RETURN THE STATUS OF THE WRITE PROCESS TOO!!!
--[[!
@module dox
@func writeOutput
@scope local
@desc Write the index file, welcome files, modules files and CSS as well as any other files required for a complete output. Used in 'dox.processFile()' and 'dox.processDir'
@param sDirectory string The desired output directory.
!]]
local function writeOutput(pDir)
	
	if type(pDir) == "string" then
		
		--TODO - DELETE THE LAST DASH IN THE INPUT STRING (IF THE DASH EXISTS)
		if pDir:gsub("%s", "") ~= "" then
			
			--sort and purge the modules
			dox.parse.sortModules();
			
			if dox.parse.getModuleCount() > 0 then

				--create all critical folders
				for nIndex, sFolder in pairs(dox.CriticalFolders) do
				os.execute('mkdir "'..pDir..'/'..sFolder..'"');			
				end
				
			--update the css (in case of theme changes)
			dox.css.update();
			
			--the css file
			local hCSSFile = io.open(pDir.."/style.css", "w");
		
				if hCSSFile then
				hCSSFile:write(dox.PageVars.CSS);
				hCSSFile:close();		
				end
			
			--the welcome file
			local hWelcomeFile = io.open(pDir.."/dox/welcome.html", "w");
		
				if hWelcomeFile then
				hWelcomeFile:write(dox.html.buildWelcome());
				hWelcomeFile:close();		
				end			
			
			--the index file
			local hIndexFile = io.open(pDir.."/index.html", "w");
		
				if hIndexFile then
				hIndexFile:write(dox.html.buildIndex());
				hIndexFile:close();		
				end
			
			--the module(s)
			local tModules = dox.Modules;
			--this has the process order for the modules
			local tMeta = getmetatable(tModules);
					
			--process the modules
				for nIndex, sModule in pairs(tMeta.ProcessOrder) do
				local tModule = tModules[sModule];	
				
				--write the module file
				local hModuleFile = io.open(pDir.."/modules/"..sModule..".html", "w");
			
					if hModuleFile then				
					hModuleFile:write(dox.html.buildModule(sModule));
					hModuleFile:close();		
					end
				
				end
				
			end
			
		end
			
	end
	
end
	

	
	
--ADD THE ABILITY TO CHECK IF THE FILE EXISTS
--[[!
@module dox
@func dox.processFile
@desc Processes a Lua file for use with Dox and readies it for output. This is one of two functions, including 'dox.processDir' that are used by the end-user. Use either of these two functions to create HTML output. While 'dox.processDir' is used for an entire directory, this funcitons will process only one file.
@param pInputFile string The path to the file dox reads.
@param pOutputFile string The path to the directory in which Dox writes the output file.
@param sTheme string,nil The name of the color scheme to use in the out HTML. If nil, Dox will use the default theme.
@example dox.processFile("C:\\Files\\myModule.lua", "C:\\Files\\Dox Output");
!]]
function dox.processFile(pInputFile, pOutDir, sTheme)
local hInputFile = io.open(pInputFile, "r");
	
	--ensure the 'pOutDir' has a '/' on the end (for linux)
	if package.config:sub(1,1) =="/" then
	
		if pOutDir:sub(pOutDir:len()) ~= "/" then
		pOutDir = pOutDir.."/";
		end
		
	end
	
	
	if hInputFile then
	
		--ignore the module reset if called by 'processDir()'
		if not bDirProcessing then
		--reset the modules table
		dox.Modules = {};
		end
	
	--set the default theme
	dox.theme.setActive("Plain");
	
	--ADD PROCESSING FOR CUSTOM THEME
	if type(sTheme) == "table" then
	
	--import only the table items that exists in other themes and fill in the gaps with elements from the default themes table !~!~!!!!!!!!!!!!!!!!!!!!!!!!!
	
	elseif type(sTheme) == "string" then
		
		--if the themes exists, set it as active
		if dox.Theme.Themes[sTheme] then		
		dox.theme.setActive(sTheme);
		end
	
	end
		
	--read the file	
	local sLuaString = hInputFile:read("*all");
		
	--get a list of all dox comment blocks
	local tBlocks = dox.parse.getBlocks(sLuaString);
		
		--process all dox comment blocks
		for nIndex, sBlock in pairs(tBlocks) do
		--LOG("Processing Block #"..nIndex..":\n"..sBlock.."\n");
		local tBlock = dox.parse.processBlock(sBlock);
		
			--make sure there's a valid block
			if tBlock then
			dox.parse.importBlockToModules(tBlock);
			end
			
		end			
	
	--read the source file (again) since the gabage collector destoys it's contents before it gets here
	hInputFile:close();
	hInputFile = io.open(pInputFile, "r");
	sLuaString = hInputFile:read("*all");
		
	--[[get the module info and store it in the module's 'Info' table
	but only if the module already exists. This means that there are
	no modules without this info table (even if it's entries are blank)
	and no info tables for modules that have no	substance (e.g., no
	info tables for modules that have no function entries).]]	
	dox.parse.importModuleInfo(sLuaString);
	
	--close the source file (again)
	hInputFile:close();
	
		--write the file but only if not called by 'processDir()'
		if not bDirProcessing then
		--write the files
		writeOutput(pOutDir);
		end
	
	end
	
return false
end





--[[!
@mod dox
@func dox.processDir
@desc Does the same as dox.processFile() but for an entire directory.
@param sDir string The full path to the directory.
@param pOutDir string The full path to the directory that will store the output.
@param sTheme string,nil The name of the color scheme to use in the out HTML. If nil, Dox will use the default theme.
@param bRecursive bool,nil If true, Dox will search all subdirectories of the given path as well in search of lua files.
!]]
function dox.processDir(sDir, pOutDir, sTheme, bRecursive)
--tell dox to process the entire directory before writing
bDirProcessing = true;

--get all the files in the directory
local tFiles = dox.util.fileFind(sDir, "*.lua", bRecursive);
	
	if tFiles then
	--reset the modules table
	dox.Modules = {};
			
		for nIndex, pFile in pairs(tFiles) do
		dox.processFile(pFile, pOutDir, sTheme);
		end
	
	--write the file
	writeOutput(pOutDir);
	end	
	
--allow 'processFile()' access to the 'writeOutput()' function again
bDirProcessing = false;

return false
end