dox.parse = {};


--[[!
@module dox.parse
@func blockToTable
@desc Searches through a block (of any kind: module, function, etc.) and splits it based on the 'dox.SpecialChars[1].Intended' special character.
@param sBlock string The plain text of the block to be processed.
@scope local
@ret tBlock table A table containg each valid item from the block string (such as description, function, authors. etc.).
!]]
local function blockToTable(sBlock)
	
	if sBlock ~= "" then
	local tRet = {};
	local bContinue = true;
	local nSearchIndex = 0;
	local sDelimiter = dox.SpecialChars[1].Intended;
		
		--escape special characters with something else until the table is constructed.
		for nIndex, tChar in pairs(dox.SpecialChars) do		
		sBlock = sBlock:gsub(tChar.Escaped, tChar.Temp);
		end
		
		while bContinue do
		local nStart, nEnd = sBlock:find(sDelimiter, nSearchIndex);

			if nStart then
			tRet[#tRet + 1] = sBlock:sub(nSearchIndex, nStart - 1);
			nSearchIndex = nEnd + 1;

			else
			tRet[#tRet + 1] = sBlock:sub(nSearchIndex);
			bContinue = false;

			end

		end
		
		
		if tRet[1] then
			
			--clear out the blank entries (if any exist). [1] is blank by default so it must be removed.
			for nLine, sLine in pairs(tRet) do
				
				if sLine:gsub(" ", ""):gsub("\n", "") == "" then
				table.remove(tRet, nLine);
				end
			
			end
			
			--put the special chars back but as they were intended to be displayed
			for nLine, sLine in pairs(tRet) do

				for nIndex, tChar in pairs(dox.SpecialChars) do	
				
				tRet[nLine] = tRet[nLine]:gsub(tChar.Temp, tChar.Intended);				
				end
			
			end
			
		end		

	return tRet
	end

end


--[[!
@module dox.parse
@func createModuleEntry
@desc Adds a module entry to the 'dox.Modules' table (if it doesn't already exist).
@param sModule string The plain text of the module.
@scope local
!]]
local function createModuleEntry(sModule)

	if not dox.Modules[sModule] then	
		
	dox.Modules[sModule] = {
		Blocks = {},
		Info = {},
		ProcessOrder = {}, --organized alphabetically			
	};
	
		--populate the module's info table
		for sInfoAtt, _ in pairs(dox.ModuleItems) do
			
			--[[add each attribute placeholder to the table except
				'moduleid' as it's only used for detecting which
				module to put the info into during processing.]]
			if sInfoAtt ~= "moduleid" then
			dox.Modules[sModule].Info[sInfoAtt] = "";		
			end
			
		end
		
	end
	
end


--[[!
@module dox.parse
@func getDefaultValue
@desc Gets what the default value should be for each item in the 'tRet' table found within the 'processBlock()' function. It is worth noting that placing a default value at 'dox.Types[sType].DefaultValue' where 'sType' is the name of the type desired, causes this function to return that value.
@param sType string The type desired such as Function, Description, etc.
@ret vRet string,table This returns a table if multiple lines with this same type are allowed (such as param) and a string if not.
@scope local
@file parse.lua
!]]
local function getDefaultValue(sType)
local vRet = "";
		
	if dox.Types[sType] then
		
		if dox.Types[sType].AllowMultiple then
		vRet = {};
		end
		
	end

	--check for an explicit, default value within the types table
	if dox.Types[sType].DefaultValue then
	vRet = dox.Types[sType].DefaultValue;
	end
	
return vRet
end


--[[!
@module dox.parse
@func getLineType
@scope local
@desc Determines what sort of line the given string is: such as description, function, parameter, etc.
@param sLine string The plain text of the line.
@return sType string The type of the line or "__UNKNOWN__" if it doesn't exist.
@return sVariation string The varation of the input. For example, if the line type is 'function', it may return 'func' or 'function' depending on what the user typed. This is not returned if the line type is unknown.
!]]
local function getLineType(sLine)
local sRet = "__UNKNOWN__";

	if type(sLine) == "string" then
	
		if sLine:len() > 0 then
	
			for sType, tTypeProperties in pairs(dox.Types) do
							
				for nIndex, sVariation in pairs(tTypeProperties.Variations) do
				local nLength = sVariation:len();
				
					--ensure the type is one of those listed
					if sLine:sub(0, nLength):lower() == sVariation:lower() then
					
						if sLine:sub(0, nLength + 1):find("[%s]") then
						return sType, sVariation
						end
					
					end
					
				end
				
			end
			
		end
			
	end

return sRet
end


--[[!
@module dox.parse
@func parseModuleIDs
@scope local
@desc Parses the 'moduleid' tag in the module block. Used in 'importModuleInfo()'.
@param sModuleIDsText string the string from the 'moduleid' tag.
@ret tModules table A numerically-indexed table whose values are tables with 'id' and 'displayname' as indices.
!]]
local function parseModuleIDs(sModuleIDsText) 
--place the input into bith fields to start just in case there is only one word
local tRet = {
	[1] = {
		displayname = sModuleIDsText,
		id = sModuleIDsText,
	},
};
	
--start by splitting the IDs by commna delimiter
local tIDs = {};
local bContinue = true;
local nSearchIndex = 0;
local sDelimiter = dox.ModuleDelimiter;

	while bContinue do
	local nStart, nEnd = sModuleIDsText:find(sDelimiter, nSearchIndex);

		if nStart then
		tIDs[#tIDs + 1] = sModuleIDsText:sub(nSearchIndex, nStart - 1);
		nSearchIndex = nEnd + 1;

		else
		tIDs[#tIDs + 1] = sModuleIDsText:sub(nSearchIndex);
		bContinue = false;

		end

	end

	
	--now look for display names for each module
	for nIndex, sModuleText in pairs(tIDs) do
	nSearchIndex = 0;
	sDelimiter = dox.ModuleInfoNameDelimiter;
	nStart, nEnd = sModuleText:find(sDelimiter, nSearchIndex);

		if nStart then
		nSearchIndex = nEnd + 1;
		
		tRet[nIndex] =  {
			displayname = sModuleText:sub(nStart + 1),
			id = sModuleText:sub(1, nStart - 1),
		};

		else
		tRet[nIndex] =  {
			displayname = sModuleText,
			id = sModuleText,
		};
		
		end

	end	

return tRet
end


--[[!
@module dox.parse
@func dox.parse.getBlocks
@desc Retrieves the blocks (such as module and function blocks) from a string of lua code. Used in 'dox.processFile()'.
@param sLua string The lua code to be processed.
@ret tBlocks table A table containing any blocks found. If no blocks were found, an empty table is returned.
!]]
function dox.parse.getBlocks(sLua)
local tBlocks = {};
local nSearchStart = 0;
local tBlockMarkers = dox.Markers.Block;

	if type(sLua) == "string" then
		
		if sLua:len() > 0 then
		local _nBlockStart, nBlockStart_;
		local nSafety = 0;
		
			repeat
			nSafety = nSafety + 1;
			
			--look for the start of the block
			_nBlockStart, nBlockStart_ = sLua:find(tBlockMarkers.Start, nSearchStart, true);
			
				if _nBlockStart then
				local _nBlockEnd, nBlockEnd_;
				--look for the end of the block
				_nBlockEnd, nBlockEnd_ = sLua:find(tBlockMarkers.End, nSearchStart, true);
					
					if _nBlockEnd then
					local nSubStart = _nBlockStart + tBlockMarkers.Start:len();
					local nSubEnd = nBlockEnd_ - tBlockMarkers.End:len();					
					local sBlock = sLua:sub(nSubStart, nSubEnd)
								
					--add the block to the 'tBlocks' table
					tBlocks[#tBlocks + 1] = sBlock;
					
					--update the search index
					nSearchStart = nBlockEnd_ + 1;

					--reset the safety value
					nSafety = 0;
					end
					
				end
			
			until _nBlockStart == nil or nSafety == 5
			
		end
	
	end

return tBlocks
end


--[[!
@module dox.parse
@func dox.parse.getModuleCount
@desc Counts the number of modules to rpevent processing if none are present. Used in 'dox.processFile()'.
@ret nModules number returns the number of modules that exist. Will return 0 if there are no modules.
!]]
function dox.parse.getModuleCount()
local nModules = 0;
	
	for sIndex, tModule in pairs(dox.Modules) do
		
		--confirm that this module contains info to be processed
		if #tModule.Blocks > 0 then
		nModules = nModules + 1
		end
		
	end
	
return nModules
end


--[[!
@module dox
@func dox.parse.importBlockToModules
@desc Pushes a block into the 'dox.Modules' table to await processing. Used in 'dox.processFile()'.
!]]
function dox.parse.importBlockToModules(tBlock)

	if type(tBlock) == "table" then
	local sModule = tBlock.Module;	

		--create the module index if it doesn't already exist
		createModuleEntry(sModule);
	
		--import the module
		local nIndex = #dox.Modules[sModule].Blocks + 1;
		dox.Modules[sModule].Blocks[nIndex] = tBlock;
		
	end

end


--[[!
@module dox.parse
@func dox.parse.importModuleInfo
@desc Gets the module info from a lua string, processes it and stores it in the module's Info table. There can be only one!...module block per module, that is. Any subsequent blocks will overwrite by the previous one(s). Also, at this point, the module must already exist or this will not process the block even if found. Modules without any functions are not processed.
@param sLuaString string The lua string to search for the module block.
!]]
--
function dox.parse.importModuleInfo(sLuaString)
local sMarkerStart = dox.Markers.Module.Start;
local sMarkerEnd = dox.Markers.Module.End;
	
	--look for the start of the module block
	local _nModuleStart, nModuleStart_ = sLuaString:find(sMarkerStart, 0, true);

	if _nModuleStart then
	--look for the end of the module block
	local _nModuleEnd, nModuleEnd_ = sLuaString:find(sMarkerEnd, nModuleStart_ + 1, true);
		
		if _nModuleEnd then
		local sModuleBlock = sLuaString:sub(nModuleStart_ + 1, _nModuleEnd - 1);
				
			--if the string has text to process
			if sModuleBlock:gsub(" ", "") ~= "" then
			local tLines = {};
			local tModuleNames;
			local tTempLines = blockToTable(sModuleBlock);
			local tModulesIDs;
			local tModuleItems = {};
			
				for nIndex, sLine in pairs(tTempLines) do
				local nTypeEnd = sLine:find("[%s]");
					
					if not nTypeEnd then
					--nTypeEnd = sLine:find("\n");
					end
					
					if nTypeEnd then
					local sType = sLine:sub(1, nTypeEnd - 1):lower():gsub(" ", "");
					
						if dox.ModuleItems[sType] then
						local sFormattedLine = sLine:sub(nTypeEnd + 1);
						
							if sType ~= "moduleid" then
							tLines[sType] = sFormattedLine;
							
							else --if this is the module name(s)
							local sModuleRaw = sFormattedLine:gsub(" ", ""):gsub("\n","");
								
								if sModuleRaw ~= "" then
								tModuleNames = parseModuleIDs(sModuleRaw);
								end
								
							end
							
						end
						
					end
				
				end
				
				--TODO DONT FORGET TO ESCAPE HTML CHARS /???? Do I need to do this?

				if tModuleNames then				
					
					for nIndex, tModule in pairs(tModuleNames) do 
					local sModule = tModule.id;
					local sDisplayName = tModule.displayname;
						
						--create the module if it doesn't exist
						if not dox.Modules[sModule] then
						createModuleEntry(sModule);
						end
						
						--process each item
						for sMarker, tMarker in pairs(dox.ModuleItems) do
							
							if sMarker ~= "moduleid" and sMarker ~= "displayname" then
								
								if tLines[sMarker] then								
								dox.Modules[sModule].Info[sMarker] = tLines[sMarker];								
								end					
							
							elseif sMarker == "displayname" then
							dox.Modules[sModule].Info.displayname = sDisplayName;
							
							end
							
						end

					end
					
				end
				
			end
			
		end
		
	end
	
end


--[[!
@module dox.parse
@func dox.parse.processBlock
@desc Processes a function block and validates all the lines input in the blocks string. Used in 'dox.processFile()'.
@param sBlock string The function block to be processed.
@ret tBlock table,nil The final Block table which can be used to create HTML or nil if any 'Required' line items are missing or blank.
!]]
function dox.parse.processBlock(sBlock)
local tRet;

	if type(sBlock) == "string" then
		
		if sBlock:len() > 0 then
		tRet = {
			Description = getDefaultValue("Description"),
			Example = getDefaultValue("Example"),
			File = getDefaultValue("Example"),
			Function = getDefaultValue("Function"),
			Module = getDefaultValue("Module"),
			Parameters = getDefaultValue("Parameters"),
			Return = getDefaultValue("Return"),
			Scope = getDefaultValue("Scope"),
			Usage = getDefaultValue("Usage"),
		};

		
			--escape special characters with something else until the table is constructed.
			--[[for nIndex, tChar in pairs(dox.SpecialChars) do
			sBlock = sBlock:gsub(tChar.Escaped, tChar.Temp);
			end]]
				
		--construct the table
		local tLines = blockToTable(sBlock);
			
			--process each line
			for nIndex, sLine in pairs(tLines) do
				
				--[[put the special chars back
				for nIndex, tChar in pairs(dox.SpecialChars) do
				sLine = sLine:gsub(tChar.Temp, tChar.Intended);
				end]]
			
			--get the line type and remove the type indicator from the line itself so it's clean and ready for print-processing
			local sType, sVariation = getLineType(sLine);
			
				if dox.Types[sType] then
				--remove the tag form the line
				sLine = sLine:sub(sVariation:len() + 2); --account for the '@' symbol and the space
				
				--trim the whitespace
				sLine = dox.util.trim(sLine);				
				
					--check for values belonging to types that may have multiple items and store in the appropriate table
					if dox.Types[sType].AllowMultiple then
					local nIndex = #tRet[sType] + 1;
					tRet[sType][nIndex] = sLine;
					
					--or store the value as-is in the appropriate table index
					else
						
						--check for type alias violations
						local tAllowedValues = dox.Types[sType].AllowedValues;
						local sDefaultValue = dox.Types[sType].DefaultValue;
						
						if tAllowedValues and sDefaultValue then
						local bIsAllowed = false;
						
							for nValueIndex, sValue in pairs(tAllowedValues) do
								
								--check to see if the input strings matches any of the allowed ones
								if sValue:gsub(" ", ""):lower() == sLine:gsub(" ", ""):lower() then
								bIsAllowed = true;
								break;
								end											
							
							end
							
							--if it's not allowed, set it to the default value
							if not bIsAllowed then
							sLine = sDefaultValue;
							end
							
						end
						
					tRet[sType] = sLine;
					end
				
				end
					
			end
				
			--ensure the block is valid before returning it
			for sType, tType in pairs(dox.Types) do
			local sDataType = type(tRet[sType]);
			local bIsEmpty = false;
				
				--discover if the the item is empty
				if sDataType == "string" then
					
					if tRet[sType]:gsub(" ", "") == "" then
					bIsEmpty = true;
					end
					
				elseif sDataType == "table" then
					
					if #tRet[sType] < 1 then
					bIsEmpty = true;
					end
					
				end
				
				
				--try to get the default values for empty items
				if (tType.MustHaveChars or tType.RequiredType) and tType.DefaultValue and bIsEmpty then
				local sDefaultType = type(tType.DefaultValue);
				local bAllowDefault = false;
				
					--make sure the default value isn't empty
					if sDefaultType == "string" then
					
						if tType.DefaultValue:gsub(" ", "") ~= "" then
						bAllowDefault = true;
						end						
						
					elseif sDefaultType == "table" then
						
						if #tType.DefaultValue > 0 then
						bAllowDefault = true;
						end						
					
					end
					
					--insert the default value if allowed
					if bAllowDefault then
					tRet[sType] = tType.DefaultValue;
					bIsEmpty = false;
					end
					
				end
				
				--now, after all that, if the item is still invalid, return nil
				if tType.RequiredType and bIsEmpty then
				return nil
				end
				
			end
			
		end
	
	end
	
return tRet
end


--[[!
@module dox.parse
@func dox.parse.sortModules
@desc Sorts the modules and functions alphabetically.
!]]
function dox.parse.sortModules()
	--process the modules
	if dox.Modules then
	--sort them alphabetically
	local tModuleSorter = {};
	--...but do so without case sensitivety
	local tModuleIndexer = {};
	
		--store the 'dox.Modules' names in a numerically-indexed table for sorting
		for sModule, tModule in pairs(dox.Modules) do
			
			if #tModule.Blocks > 0 then
			--setup the module sorting tables
			local sModuleLC = string.lower(sModule);
			tModuleSorter[#tModuleSorter + 1] = sModuleLC;
			tModuleIndexer[sModuleLC] = sModule;
			
			local tFunctionSorter = {};
			local tFunctionIndexer = {};
			
				--sort the functions inside the modules as well
				for nIndex, tBlock in pairs(tModule.Blocks) do
				local sFunctionLC = string.lower(tBlock.Function);
				tFunctionSorter[nIndex] = sFunctionLC;
				tFunctionIndexer[sFunctionLC] = tBlock.Function
				end
				
				--sort the functions
				table.sort(tFunctionSorter);
				
				--reset the 'ProcessOrder' table
				dox.Modules[sModule].ProcessOrder = {};
				
				--store the results in the 'ProcessOrder' table of each module
				for _, sFunctionLC in pairs(tFunctionSorter) do
				local sFunction = tFunctionIndexer[sFunctionLC];
				
					for nBlockID, tBlock in pairs(tModule.Blocks) do
						
						if sFunction == tBlock.Function then					
						local nNextIndex = #dox.Modules[sModule].ProcessOrder + 1;
						dox.Modules[sModule].ProcessOrder[nNextIndex] = nBlockID;
						break;
						end
						
					end
					
				end
			
			end
			
		end
		
	--sort it
	table.sort(tModuleSorter);

	--re/create the process order table
	local tMeta = {
		ProcessOrder = {},
	};
	
		--store the items in the metatable
		for nIndex, sModuleLC in pairs(tModuleSorter) do
		tMeta.ProcessOrder[nIndex] = tModuleIndexer[sModuleLC];
		end

	--record the info in the meta table for later use
	setmetatable(dox.Modules, tMeta);

	--cleanup
	tTempModules = nil;
	end
	
end