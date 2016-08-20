dox.html = {};
local tab = dox.util.tab;


--[[!
@module dox.html
@func appendBody
@desc Adds the input string to the dox.PageVars.Body variable.
@param sInput string The string to append to the body of the HTML.
!]]
local function appendBody(sInput)

	if type(sInput) == "string" then
	dox.PageVars.Body = dox.PageVars.Body..sInput;
	return true
	end

return false
end



--
--[[!
@module dox.html
@func getAccordionList
@scope local
@desc Used by 'dox.html.buildModule()' to insert mod info detail list items.
@param tModule table The module table to be processed.
@param nTabStart number A number that represents how many tabs to indent the returned menu.
@ret string The HTML of the accordion menu for the module
!]]
local function getAccordionList(tModule, nTabStart)
local sRet = "";
local nTab = 1;
local nItemCount = 0;
local nTabsWidth = 0;
--[[This number (in pixels) is subject to change if the .accordian menu
is reworked. Don't trust the accoridan website to show the accurate numbers,
simply calculate it manually if the menu gets changed.]]
local nTabWidth = 35;

	
	--set the tab start count
	if type(nTabStart) == "number" then
	nTab = nTabStart;
	end
	
	--prep the menu
	sRet = sRet..tab(nTab, true)..'<div class="accordion">';
		sRet = sRet..tab(nTab + 1, true)..'<ul>';
	
	if tModule then
		
		if tModule.Info then
		local tInfo = tModule.Info;
				
			--sort the table alphabetically
			local tProcessOrder = {};
			
			for sIndex, _ in pairs(dox.ModuleItems) do
			tProcessOrder[#tProcessOrder + 1] = sIndex;
			end
			
			table.sort(tProcessOrder);
			
			for _, sIndex in pairs(tProcessOrder) do
			local tItem = dox.ModuleItems[sIndex];
			local sTitle = "";	
			local sContent = "";
			local bAddItemToList = true;
			
				--if the module has that info...
				if tInfo[sIndex] then
					
					--check to see if this item gets added to the list
					if tItem.IsListItem then
						
						--get the display name of the item
						sTitle = tItem.Display;
						
						--get the content
						sContent = tInfo[sIndex];
						
						--make sure the list item title and content exist
						if type(sTitle) ~= "string" or type(sContent) ~= "string" then
						bAddItemToList = false;
						end
						
						--make sure the list item and text have content
						if sTitle:gsub("%s,", "") == "" or sContent:gsub("%s,", "") == ""then
						bAddItemToList = false;
						end
						
						--if it's a website then add a link
						--if sIndex == "website" then
						--sContent = '<a href="'..sContent..'" target="_blank">'..sContent..'</a>'
						--end
						
						if bAddItemToList then
						
							--if all went well above, create the code
							sRet = sRet..tab(nTab + 2, true)..'<li>';
								sRet = sRet..tab(nTab + 3, true)..'<input type="radio" name="select" class="accordion-select" checked />';
								--Title
								sRet = sRet..tab(nTab + 3, true)..'<div class="accordion-title">';
									sRet = sRet..tab(nTab + 4, true)..'<span>'..sTitle..'</span>';
								sRet = sRet..tab(nTab + 3, true)..'</div>';
								--Content
								sRet = sRet..tab(nTab + 3, true)..'<div class="accordion-content">';
								   sRet = sRet..tab(nTab + 4, true)..''..sContent..'';
								sRet = sRet..tab(nTab + 3, true)..'</div>';
								--Separator
								sRet = sRet..tab(nTab + 3, true)..'<div class="accordion-separator"></div>';
							sRet = sRet..tab(nTab, true)..'</li>';		

							--increment the list width for each item
							nTabsWidth = nTabsWidth + nTabWidth;
							
						end
						
					end
					
				end
			
			end
			
		end
		
	end
	
	--only return the menu if there are items in it
	if nTabsWidth > 0 then
		sRet = sRet..tab(nTab + 1, true)..'</ul>';
	sRet = sRet..tab(nTab, true)..'</div>';
	
	else
	sRet = "";
	
	end
	
return sRet, nTabsWidth
end



local function insertFooter(nTabStart)
local nTab = 0;
	
	if type(nTabStart) == "number" then
	nTab = nTabStart;
	end
	--<li><a href="modules/'..sModule..'.html#'..sFunction..'" target="module">'..sFunction..'</a></li>
		appendBody(tab(nTab, true)..'<div id="footer">');
			
		appendBody(tab(nTab, true)..'</div>');


end


--[[!
@module dox.html
@func parseLine
@desc Used for processing values that are stored in tables such as Return or Parameter line types. Used in 'buildHTML()'.
@param sLine string The line to be processed.
@param sType The tyoe if line it is (Function, Description. etc.)
@scope local
@ret sLine string A string that contains the concatenated line.
!]]
local function parseLine(sLine, sType)
local sRet = "";
local tLines = {};
local sParserSeparator = " | ";
local bParse = false;	
local tParser = -1;

	if dox.Types[sType] then
		
		--esnure that a parser table exists
		if dox.Types[sType].Parser then
		tParser = dox.Types[sType].Parser;
		bParse = true;		
		end
		
		--use a custom separator if present		
		if dox.Types[sType].ParserSeparator then
					
			if type(dox.Types[sType].ParserSeparator) == "string" then
			
				if dox.Types[sType].ParserSeparator:gsub("%s", "") ~= "" then
				sParserSeparator = dox.Types[sType].ParserSeparator;
				end

			end
			
		end
	
	end
	
	if bParse then
		--parse the line and store it in the 'tLines' table
		if type(sLine) == "string" and type(tParser) == "table" then
		
		local nLength = sLine:len();
			
			--increment the 'tLines' table to match the parser table's length
			for nIndex, _ in pairs(tParser) do
			tLines[nIndex] = "";
			end
			
			--set the first line in the table to be the whole line in case that's all there is
			tLines[1] = sLine;
			
			if sLine:len() > 0 then
			--look for the first space
			local nFirstSpace, _ = sLine:find(" ", 0);
				
				if nFirstSpace then			
				--set index 1 to be everything up to the first space
				tLines[1] = sLine:sub(0, nFirstSpace - 1);
				--(tentatively) set index 2 to be the rest of the line
				tLines[2] = sLine:sub(nFirstSpace + 1, nLength);
				
				--look for the second space
				local nSecondSpace, _ = sLine:find(" ", nFirstSpace + 1);
					
					if nSecondSpace then
					--reset line 2 to account for the tertiary block's existence
					tLines[2] = sLine:sub(nFirstSpace + 1, nSecondSpace - 1);
					
					--store line 3				
					tLines[3] = sLine:sub(nSecondSpace + 1, nLength);
					
					end
				
				end
				
			end
			
		end
			
		--wrap each line with the start and end tags dictated by the parser
		local nMaxLines = #tLines;
		local bLastItemExists = false;
		for nIndex, sItem in pairs(tLines) do
			
			if sItem:gsub(" ", "") ~= "" then
			local sDivider = "";
		
				if bLastItemExists then
				sDivider = sParserSeparator;
				end
				
			tLines[nIndex] = tParser[nIndex].StartTag..sDivider..sItem..tParser[nIndex].EndTag;
			
			--let the next item know it needs a divider
			bLastItemExists = true;
			
			else
			bLastItemExists = false;
			
			end
		
		end
		
		--process the 'tLines' table to form the return string
		for nIndex, sItem in pairs(tLines) do
		--replace new lines with '<br>' tags
		sRet = sRet..sItem:gsub("\n", "<br>");
		end
		
	end
	
return sRet
end


--[[!
@module dox.html
@func tryString
@desc Tests to see if a string is blank or nil and if so, returns the second argument. If it is not blank or nil, it returns the original string.
@param sInput string The string to test.
@param sAlt string The string to return is the sInput string is blank or nil.
@scope local
@ret sRet string Either the original string (sInput) or the Alternate string (sAlt) if the sInput is blank or nil.
!]]
function tryString(sInput, sAlt)
local sRet = sAlt;
	
	if type(sInput) == "string" then
	
		if sInput:gsub(" ", "") ~= "" then
		sRet = sInput;
		end
	
	end

return sRet
end


--[[!
@module dox.html
@func dox.html.buildIndex
@desc Called from the Dox file contructor functions for each module in the 'dox.Modules' table. It is responsible for building and returning the html used in the 'index.html' page.
@ret sHTML string The complete html string saved in the 'index.html' file.
!]]
function dox.html.buildIndex()
local tModules = dox.Modules;
--this has the process order for the modules
local tMeta = getmetatable(tModules);
	
	--==================================================
	--First, build the navmenu then the page afterward
	--==================================================
	
	--reset the 'dox.PageVars.Body' variable
	dox.PageVars.Body = "";

	local sNavMenu = '\n'..tab(3)..'<div class="navmenu">\n'..tab(4)..'<nav class="menu">';
	
	--process the modules to create a nav menu
	for nIndex, sModule in pairs(tMeta.ProcessOrder) do
	local tModule = tModules[sModule];
	sNavMenu = sNavMenu..'\n'..tab(5)..'<ul class="menu">\n'..tab(6)..'<li>\n'..tab(7)..'<a href="modules/'..sModule..'.html" target="module">'..sModule..'</a>\n';
	
		--this will create the navigation menu on the left
		local sFunctionList = tab(7)..'<ul class="menu">\n';
		
		for _, nBlockID in pairs(tModule.ProcessOrder) do				
		local sHTML = ""
		local tBlock = tModule.Blocks[nBlockID];
		local sFunction = tBlock.Function;
		--[[add each function item to the function nav list (which is subordinate of the modulelist,
			both working together to form the complete navigation menu)]]
			--THESE NEED TO BE UNIQUE...FIND A WAY (PERHAPS INVISIBLE TEXT) TO ADD THE MODULE NAME TO THE ANCHOR POINTS
		sFunctionList = sFunctionList..tab(8)..'<li><a href="modules/'..sModule..'.html#'..sFunction..'" target="module">'..sFunction..'</a></li>\n';
		end
		
		--close the function list part of the menu
		sFunctionList = sFunctionList..tab(7)..'</ul>';
		
		--add the funciton list to the nav menu and close the nav menu
		sNavMenu = sNavMenu..sFunctionList..tab(6, true)..'</li>'..tab(5, true)..'</ul>';
		
	end
	
	--close the nav menu
	sNavMenu = sNavMenu..tab(4, true)..'</nav>'..tab(3, true)..'</div>';
	
	--==================================================
	--Build the page (and insert the navmenu into it)
	--==================================================
	 
	--page header
	appendBody(tab(3, true)..'<div id="topsection">');
		appendBody(tab(4, true)..'<div class="innertube">');
			appendBody(tab(5, true)..'<h1>'..dox.PageVars.Title..'</h1>');			
		appendBody(tab(4, true)..'</div>');
	appendBody(tab(3, true)..'</div>');	
		
	--the main content of the page
	appendBody(tab(3, true)..'<div id="contentwrapper">'..tab(4, true)..'<div id="contentcolumn">');
	
	--the welcome page
	appendBody(tab(5, true)..'<iframe id="module" name="module" src="dox/welcome.html"></iframe>');
	
	--close the 'contentwrapper' (and subordinate) div
	appendBody(tab(4, true)..'</div>'..tab(3, true)..'</div>');
	
	--add the navmenu
	appendBody(sNavMenu);
	
	--add the footer
	insertFooter(3);
	
	--adjust the upcoming, closing div (from 'maincontainer')
	appendBody(tab(2, true));


--push all the HTML together
return [[<!doctype html>
<html lang="en">

	<head>
		<meta charset="utf-8">
		
		<title>]]..dox.PageVars.Title..[[</title>
		<meta name="description" content="]]..dox.PageVars.Description..[[">
		<meta name="author" content="]]..dox.PageVars.Author..[[">	  
		<link rel="stylesheet" type="text/css" href="style.css">
		<link rel="shortcut icon" href="data:image/jpeg;base64,]]..dox.base64.getData("favicon")..[[">
		<link rel="icon" href="data:image/jpeg;base64,]]..dox.base64.getData("favicon")..[["> 
		
	</head>

	<body>		
		<div id="maincontainer">]]..dox.PageVars.Body..[[</div>
	</body>

</html>]]
end



--used to return nothing if there is no link but returns the html if one does exist
local function getLinkHTML(sLink, sTargetText, sClassName, sIDName)
local sRet = "";

	if type(sLink) == "string" then
	local sClass = 'class ="link"'; --default class link style
	local sID = "";
	local sTarget = "";
		
		--get the class text
		if type(sClassName) == "string" then
		
			if sClassName:gsub(" ", "") ~= "" then
			sClass = ' class="'..sClassName..'"';
			end
			
		end
		
		--get the class text
		if type(sIDName) == "string" then
		
			if sIDName:gsub(" ", "") ~= "" then
			sID = ' id="'..sIDName..'"';
			end
			
		end
		
		--get the target text
		if type(sTargetText) == "string" then
		
			if sTargetText:gsub(" ", "") ~= "" then
			sTarget = ' target="'..sTargetText..'"';
			end
			
		end
		
		sRet = sRet..'<a href="'..sLink..'"'..sClass..sID..sTarget..'>'..sLink..'</a>';
	
	end

return sRet
end


--[[!
@module dox.html
@func dox.html.buildModule
@desc Called from the Dox file contructor functions for each module in the 'dox.Modules' table. It is responsible for building and returning the html used in each module file.
@param sModule string The name of the module that is to be processed.
@ret sHTML string The complete html string saved in the module's html file.
!]]
function dox.html.buildModule(sModule)
local tModule = dox.Modules[sModule];
	
	--set the page title
	--dox.PageVars.Title = "Dox: "..sModule;
	--set the page description
	dox.PageVars.Description = "Module page auto-generated for the "..sModule.." module.";
	--set the author
	dox.PageVars.Author = "Dox auto-generator";
	--reset the 'dox.PageVars.Body' variable
	dox.PageVars.Body = "";
				
	--the main content of the page
	appendBody(tab(3, true)..'<div id="modulecontentwrapper">'..tab(4, true)..'<div id="modulecontentcolumn">');
		
	--get the mod info html list and item width addition
	local sList, nTabsWidth = getAccordionList(tModule, 6);
	
	--module info
	local tInfo = tModule.Info;
	
	--create the module info section
	appendBody(
		tab(5, true)..'<div>'..
			--tab(6, true)..'<hr>'..
			tab(6, true)..'<h1 id="midisplayname">'..tryString(tInfo.displayname, sModule)..
				tab(7, true)..'<span id="miversion">v'..tryString(tInfo.version, "0.0.1")..'</span>'..
			tab(6, true)..'</h1>'..
			tab(6, true)..'<h2 id="miauthors">by '..tryString(tInfo.authors, "Unknown")..'</h2>'..
			tab(6, true)..'<h3 id="miwebsite">'..getLinkHTML(tryString(tInfo.website, ""), "_blank", "link")..'</h3>'..
			sList..
		tab(5, true)..'</div>'	
	);
		
	appendBody(tab(5, true)..'<br><br>');
	
	--for adding <hr> tags appropriately
	local nMaxBlocks = #tModule.ProcessOrder;
		
	for nCount, nBlockID in pairs(tModule.ProcessOrder) do
	local sAlt = "";
		
		--alternate the color of the module section background
		if dox.util.isEven(nCount) then
		sAlt = "alt";
		end
		
	local tBlock = tModule.Blocks[nBlockID];
	local sExample = tBlock.Example:gsub("\n", "<br>");--[x]
	local sFile = tBlock.File:gsub("\n", "<br>"); --[x] TODO - MAKE THIS AUTO-GENERATE WHEN THERE IS NO TAG FOR IT.
	local sFunction = tBlock.Function; --[x]
	local sDescription = tBlock.Description:gsub("\n", "<br>"); --[x]
	--local sModule = tBlock.Module;   already declared in the for-loop	[x]
	local sParameters = ""; -- the long description of each
	local sParametersShort = ""; --the short list that goes in between the parentheses UNUSED ATM UNUSED ATM UNUSED ATM UNUSED ATM!!!!
	local tParameters = tBlock.Parameters;--[x]
	local sReturn = "";
	local tReturn = tBlock.Return; --[x]
	local sScope = tBlock.Scope; --[x]
	local sUsage = tBlock.Usage:gsub("\n", "<br>");
			
		--process any parameters that exist
		local nMaxParameters = #tBlock.Parameters;
		if nMaxParameters > 0 then
		sParameters = tab(5, true)..'<h3 class="blocklineheader">Parameters</h3>';
		end
				
		--comma informer variable
		local bOneCameBefore = false;
		
		for nIndex, sLine in pairs(tBlock.Parameters) do
		local sComma = ",";
			
			--remove the comma if not needed
			if not bOneCameBefore or nIndex == nMaxParameters then
			sComma = "";
			end
		
		--the long line
		local sLine = parseLine(sLine, "Parameters");
		--_RETHINK HOW THIS WORKS
		--shorten (gsub) it for the type value(s)
		--sParametersShort = sLine:gsub..sComma;
		
		--the parameters' descriptions
		sParameters = sParameters..tab(6, true)..'<p class="parameter">['..sLine..']</p>';
		
		bOneCameBefore = true;
		end
		
		--TODO MAKE THIS DEFAULT TO THE ORIGINATING FILE
		if sFile:gsub(" ", ""):gsub("<br>", "") ~= "" then
		sFile = '<span class="file">'..sFile..'</span>';
		end
		
		--append the main page content
		appendBody(
			tab(5, true)..'<div id="'..sFunction..'" class="innertubecontent'..sAlt..'"><h2 class="functionname">'..
			tBlock.Function..'()'..'</h2><span class="scope">'..sScope..'</span>'			
		);
		
		--append the parameters (if any)
		appendBody(tab(5, true)..sParameters);
		
		--description
		if sDescription:gsub(" ", ""):gsub("<br>", "") ~= "" then
		
		sDescription = '<p class="blockdesc">'..sDescription..'</p>';
		appendBody(
			tab(5, true)..'<h3 class="blocklineheader">Description</h3>'..
			tab(5, true)..sDescription
		);
		end
		
		--usage
		if sUsage:gsub(" ", ""):gsub("<br>", "") ~= "" then
		sUsage = '<p class="blockdesc">'..sUsage..'</p>';
		
		appendBody(
			tab(5, true)..'<h3 class="blocklineheader">Usage</h3>'..
			tab(5, true)..sUsage
		);		
		end
		--TODO TRY <pre> tags here
		--examples
		if sExample:gsub(" ", ""):gsub("<br>", "") ~= "" then
		sUsage = '<code>'..sUsage..'</code>';
		
		appendBody(
			tab(5, true)..'<h3 class="blocklineheader">Example</h3>'..
			tab(5, true)..sExample
		);		
		end
		
		
		--process any return items that exist
		local nMaxReturns = #tBlock.Return;
		if nMaxReturns > 0 then
		sReturn = tab(5, true)..'<h3 class="blocklineheader">Return</h3>';
		end
		
		--comma informer variable
		bOneCameBefore = false;
		
		for nIndex, sLine in pairs(tBlock.Return) do
		local sComma = ",";
			
			--remove the comma if not needed
			if not bOneCameBefore or nIndex == nMaxReturns then
			sComma = "";
			end
		
		--the long line
		sLine = parseLine(sLine, "Return");
		--_RETHINK HOW THIS WORKS
		--shorten (gsub) it for the type value(s)
		--sParametersShort = sLine:gsub..sComma;
		
		--the return values' descriptions
		sReturn = sReturn..tab(6, true)..'<p class="return" class="blockdesc">['..sLine..']</p>';
		
		bOneCameBefore = true;
		end
		
		--append the return values (if any)
		appendBody(tab(5, true)..sReturn);
		
		--close the 'innertubecontent' class div
		appendBody(tab(5, true)..'</div>');
		
		--add an <hr> tag (if needed)
		if nMaxBlocks > 1 and nCount < nMaxBlocks then
		appendBody(tab(5, true)..'<hr class="moduleitem">');
		end
	
	end
	
	--close the 'contentwrapper' (and subordinate) div
	appendBody(tab(4, true)..'</div>'..tab(3, true)..'</div>');
	
	--add the navmenu
	appendBody(sNavMenu);
		
	--adjust the upcoming, closing div (from 'maincontainer')
	appendBody(tab(2, true));


--push all the HTML together
return [[<!doctype html>
<html lang="en">

	<head>
		<meta charset="utf-8">
		
		<title>]]..dox.PageVars.Title..[[</title>
		<meta name="description" content="]]..dox.PageVars.Description..[[">
		<meta name="author" content="]]..dox.PageVars.Author..[[">
		<link rel="stylesheet" type="text/css" href="../style.css">
		<style>
		.accordion {
			-webkit-box-shadow: 0px 75px 35px -55px rgba(10, 30, 65, 0.6);
			-moz-box-shadow: 0px 75px 35px -55px rgba(10, 30, 65, 0.6);
			box-shadow: 0px 75px 35px -55px rgba(10, 30, 65, 0.6);
			font-family: Arial, Helvetica, sans-serif;
			border-color: ]]..dox.theme.getColor("BackgroundOutline")..[[;
			border-style: solid;
			border-width: 3px;
			border-radius: 20px;
			margin: 0 auto;
			height: 310px;
			width: calc(700px + ]]..nTabsWidth..[[px);
		}
		</style>
		
	</head>

	<body>
		<div id="maincontainer">]]..dox.PageVars.Body..[[</div>
	</body>

</html>]]
end


--[[!
@module dox.html
@func dox.html.buildWelcome
@desc Called from the Dox file constructor functions. Builds and returns the HTML used to build the 'welcome.html' page shown in the main frame when the 'index.html' page first loads.
@ret sHTML string The complete html string saved in the 'welcome.html' file.
!]]
function dox.html.buildWelcome()
	
	--reset the 'dox.PageVars.Body' variable
	dox.PageVars.Body = "";
	
	--adjust the upcoming, closing div (from 'maincontainer')
	appendBody(tab(2, true));


--push all the HTML together
return [[<!doctype html>
<html lang="en">

	<head>
		<meta charset="utf-8">
		
		<title>Welcome</title>
		<meta name="description" content="Dox Welcome Page">
		<meta name="author" content="]]..dox.PageVars.Author..[[">
		<link rel="stylesheet" type="text/css" href="../style.css">
		
	</head>

	<body id="welcome">		
		<div id="maincontainer">]]..dox.PageVars.Body..[[</div>
	</body>

</html>]]
end