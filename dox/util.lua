dox.util = {};

--directory spacer (reset at the end of the file for windows systems)
local _ = "/";
local sOSType = "linux";
local tFileMethods = {
	["linux"] = {
		fileFind = function(sDir, sFile, bRecursive)
		local sRecurs = " -maxdepth 1 ";
		
			if bRecursive then
			sRecurs = "";
			end
		 
		return 'find "'..sDir..'"'..sRecurs..'-name "'..sFile..'"'
		end,
	},
	["windows"] = {
		fileFind = function(sDir, sFile, bRecursive)
		local sRecurs = "";
		
			if bRecursive then
			sRecurs = " /s";
			end
		
		return 'dir "'..sDir.."\\"..sFile..'" /b'..sRecurs;
		end,
	},
};


--[[!
@module dox.util
@func dox.util.getOSType
@desc Determines the operating system type the end-user if running.
@ret sOSType string returns 'windows' if it is a Windows systems and 'linux' if it a unix-based system.
!]]
function dox.util.getOSType()
local sSlash = package.config:sub(1,1);

	if sSlash == "\\" then
	return "windows"
	
	elseif sSlash == "/" then
	return "linux"
		
	end
	
end


--[[!
@module dox.util
@func dox.util.fileFind
@desc Searches for file(s) based on the input.
@param sDir string The directory in which to search. The type of path formatting is irrelevant. I.e., Both "C:\\MyDirectory" and "/MyDirectory" are valid formatting methods for this input.
@param sFile string The file or file pattern to find.
@param bRecursive boolean,nil If true, the function will search for the file/pattern recursively.
@ret tFiles table A numerically-indexed table whose values are the paths of the found item(s). If no items are found, an empty table is returned.
!]]
function dox.util.fileFind(sDir, sFile, bRecursive)
local tRet = {};
local nIndex = 0;
	
	if type(sDir) == "string" and type(sFile) == "string" then
		
		--ensure the slashes are correct (for systems that use a linux separator '/' on Windows and vice versa)
		if sOSType == "windows" then
		sDir = sDir:gsub("/", "\\");
		
		elseif sOSType == "linux" then
		sDir = sDir:gsub("\\", "/");
			
		end
	
	--create the command
	local sCommand = tFileMethods[sOSType].fileFind(sDir, sFile, bRecursive) 

	--read the dir
	local hFiles = io.popen(sCommand);
			
		if hFiles then
			
			--add each file to the list
			for sFile in hFiles:lines() do
			nIndex = nIndex + 1;
			tRet[nIndex] = sFile;
			end
			
			--add the path names to the files (if needed)
			if sOSType == "windows" then
				
				if not bRecursive then
				
					for nIndex, sFile in pairs(tRet) do
					tRet[nIndex] = sDir.._..sFile;
					tRet[nIndex] = tRet[nIndex]:gsub("/", "\\");
					end
				
				end
				
			end
			
			--if the table has no files, return nil
			if not tRet[1] then
			return nil
			end
			
		hFiles:close();
		end
	
	end

return tRet
end


--[[!
@module dox.util
@func dox.util.interateChar
@desc Creates a string where the 'sString' input is concatenated n times where n = 'nCount' input.
@param sString string The string to be concatenated.
@param nCount number The number of times to concatenate the string.
@ret sString string Returns the concatenated string. If 'nCount' is nil or not a valid number then a blank string is returned.
!]]
function dox.util.interateChar(sChar, nCount)
local sRet = "";
	
	if type(sChar) == "string" and type(nCount) == "number" then
		
		for x = 1, nCount do
		sRet = sRet..sChar;
		end
		
	end
	
return sRet
end


--[[!
@module dox.util
@func dox.util.isEven
@desc Determines whether or not a number is even (or odd, implicitly).
@param nNumber number The number to evaluate.
@ret bEven boolean Returns true if the number is even and false if it is not.
!]]
function dox.util.isEven(nNumber)
local nAbsNumber = math.abs(nNumber) / 2;

	if nAbsNumber - math.floor(nAbsNumber) == 0 then
	return true
	end

return false
end


--[[!
@module dox.util
@func dox.util.tab
@desc Creates x number of tab strings.
@param nTabs number The number of tabs to stack together.
@param bNewLineFirst boolean,nil If true, this creates a new line before concatenating the tabs.
@ret sTabs string The concatenated string or a blank string is 'nTabs' is not a valid number.
!]]
function dox.util.tab(nTabs, bNewLineFirst)
local sRet = "";

	if bNewLineFirst then
	sRet = sRet.."\n";
	end
		
	if type(nTabs) == "number" then
		
		for x = 1, nTabs do
		sRet = sRet.."\t";
		end
		
	end
	
return sRet
end


--[[!
@module dox.util
@func dox.util.trim
@desc Trims the trailing and leading whitespace from a string. This function not by Centauri Soldier (http://en.wikipedia.org/wiki/Trim_(8programming))
@param sString string The string to be trimmed.
@ret sTrimmedString string The trimmed string.
!]]
function dox.util.trim(s)
  -- from PiL2 20.4
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--get the OS type for the file functions
sOSType = dox.util.getOSType();

--reset the directory spacer (if needed)
if sOSType == "WINDOWS" then
_ = "\\";
end