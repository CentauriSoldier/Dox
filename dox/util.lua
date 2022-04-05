dox.util = {};

--ignore files cause dox to ignore files/folders where the files are found
local sDoxIgnoreFile 	= ".doxignore"; --ignores all files in current directory
local sDoxIgnoreSubFile = ".doxignoresub"; --ignores all files in sub directories
local sDoxIgnoreAllFile = ".doxignoreall"; --ignores all files current and subdirectories

local nMinFileLength = 5; --some character plus a dot then the file extension (e.g., t.lua)

--get directory spacer
local _ = package.config:sub(1,1);
--get the os type
local sOSType = _ == "\\" and "windows" or (_ == "/" and "unix" or "unknown");

local tFileFindMethods = {
	["unix"] = {
		fileFind = function(sDir, sFile, bRecursive)
			local sRecurs = bRecursive and "" or " -maxdepth 1 ";
			return 'find "'..sDir..'"'..sRecurs..'-name "'..sFile..'"'
		end,
	},
	["windows"] = {
		fileFind = function(sDir, sFile, bRecursive)
			local sRecurs = bRecursive and " /s" or "";
			return 'dir "'..sDir.."\\"..sFile..'" /b'..sRecurs;
		end,
	},
};


--[[!
@module dox.util
@func dox.util.getOSType
@desc Determines the operating system type the end-user if running.
@ret sOSType string returns 'windows' if it is a Windows systems and 'unix' if it a unix-based system.
!]]
function dox.util.getOSType()
	return sOSType;
end

local p = Dialog.Message;

function dox.util.getProcessList(sDir, bRecurse, tFiles)
	local tRet = type(tFiles) == "table" and tFiles or {};
	--TODO finish the unix commands
	--setup the commands
	local sGetFilesCommand 	= (_ == "\\") and	('dir "'..sDir..'\\*.*" /b /a-d'):gsub("\\\\", "\\") 	or ('find '..sDir.."/"..'-maxdepth 1 ! –type d'):gsub("//", "/");
	local sGetDirsCommand 	= (_ == "\\") and	('dir "'..sDir..'\\*.*" /b /d'):gsub("\\\\", "\\") 		or ("ls -a -d /*"):gsub("//", "/");
	
	local hFiles 	= io.popen(sGetFilesCommand);
	--p("", type(hFiles))
	--process files and folders
	if (hFiles) then
		local bIgnore 		= false;
		local bIgnoreSub	= false;
		local bIgnoreAll 	= false;
		local tFiles = {};
		
		--look for ignore files
		for sFile in hFiles:lines() do
			
			if (sFile == sDoxIgnoreAllFile) then
				bIgnoreAll = true;
				break; --no need to continue at this point
			elseif (sFile == sDoxIgnoreSubFile) then
				bIgnoreSub = true;
			elseif (sFile == sDoxIgnoreFile) then
				bIgnore = true;
			else
				tFiles[#tFiles + 1] = sFile;
			end
			
		end
	
		--only process items if the .doxignoreall file was NOT found
		if not (bIgnoreAll) then
	
			--process files
			if not (bIgnore) then
				
				for nIndex, sFile in pairs(tFiles) do
					
					--check that the file type is valid
					if (sFile:len() >= nMinFileLength and sFile:reverse():sub(1, 4):lower() == "aul.") then
						--add the file to the list
						tRet[#tRet + 1] = sDir.._..sFile;
					end			
					
				end
				
			end
			
			--process subdirectories
			if 1 == 4 then--(bIgnoreSub) then
				local hDirs	= io.popen(sGetDirsCommand);
				
				if (hDirs) then
				
					for sDirectory in hDirs:lines() do
						dox.util.getProcessList(sDir, bRecurse, tRet);
					end
				
				end
				
			end
			
		end
	
	end
		
	return tRet;
end


--[[!
@module dox.util
@func dox.util.fileFind
@desc Searches for file(s) based on the input.
@param sDir string The directory which to search. The type of path formatting is irrelevant. I.e., Both "C:\\MyDirectory" and "/MyDirectory" are valid formatting methods for this input.
@param sFile string The file or file pattern to find.
@param bRecursive boolean,nil If true, the function will search for the file/pattern recursively.
@ret tFiles table A numerically-indexed table whose values are the paths of the found item(s). If no items are found, an empty table is returned.
!]]
function dox.util.fileFind(sDir, sFile, bRecursive)
	local tRet = {};
	local nIndex = 0;

	if type(sDir) == "string" and type(sFile) == "string" then

		--ensure the slashes are correct (for systems that use a unix separator '/' on Windows and vice versa)
		if sOSType == "windows" then
			sDir = sDir:gsub("/", "\\");

		elseif sOSType == "unix" then
			sDir = sDir:gsub("\\", "/");

		end

	--create the command
	local sCommand = tFileFindMethods[sOSType].fileFind(sDir, sFile, bRecursive)

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
				return nil --TODO this does not allow hFIle to close!
			end

			hFiles:close();
		end

	end

return tRet
end

--TODO isn't this a native lua function? check and, if so, replace
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
