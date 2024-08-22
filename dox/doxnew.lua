local dox;
local doxdecoy;
local doxmodule;
local parse;

doxmodule = class("doxmodule", --this is the class we want!
{--metamethods

},
{--static public

},
{--private
    name_AUTO = "",
},
{--protected

},
{--public
    doxmodule = function(pFile) --TODO non-file constructor and ove this to import function

    end
},
nil,    --extending class
nil,    --interface(s) (either nil, an interface or a numerically-indexed table of interfaces)
false   --if the class is final
);



doxactual = {
    pri = {--private
    name_AUTO = "",
    getProcessList = function (this, cdat, sDir, bRecurse, tFiles)
        local tRet = type(tFiles) == "table" and tFiles or {};
        --TODO finish the unix commands
        --setup the commands
        local sGetFilesCommand 	= (_ == "\\") and	('dir "'..sDir..'\\*.*" /b /a-d'):gsub("\\\\", "\\") 	or ('find '..sDir.."/"..'-maxdepth 1 ! –type d'):gsub("//", "/");
        local sGetDirsCommand 	= (_ == "\\") and	('dir "'..sDir..'\\*.*" /b /d'):gsub("\\\\", "\\") 		or ("ls -a -d /*"):gsub("//", "/");

        local hFiles 	= io.popen(sGetFilesCommand);

        --process files and folders
        if (hFiles) then
            local bIgnore 		= false;
            local bIgnoreSub	= false;
            local bIgnoreAll 	= false;
            local tFiles 		= {};

            --look for ignore files
            for sFile in hFiles:lines() do

                if (sFile == sDoxIgnoreAllFile) then
                    bIgnoreAll = true;
                    break; --no need to continue at this point
                end

                if (sFile == sDoxIgnoreSubFile) then
                    bIgnoreSub = true;
                end

                if (sFile == sDoxIgnoreFile) then
                    bIgnore = true;
                end

                if not (bIgnoreAll or bIgnore) then
                    tFiles[#tFiles + 1] = sFile;
                end

            end

            --only process items if the .doxignoreall file was NOT found
            if not (bIgnoreAll) then

                --add (any) files that exist to the return table
                for nIndex, sFile in pairs(tFiles) do

                    --check that the file type is valid
                    if (sFile:len() >= nMinFileLength and sFile:reverse():sub(1, 4):lower() == "aul.") then
                        --add the file to the list
                        tRet[#tRet + 1] = sDir.._..sFile;
                    end

                end

                --process subdirectories
                if not (bIgnoreSub) then
                    local hDirs	= io.popen(sGetDirsCommand);

                    if (hDirs) then

                        for sDirectory in hDirs:lines() do
                            dox.util.getProcessList(sDir.._..sDirectory, bRecurse, tRet);
                        end

                    end

                end

            end

        end

        return tRet;
    end,
    },
    pub = {-- public
        importDir = function(this, cdat, pDir, bRecursive)

        end,
        importFile = function(this, cdat, pFile)

        end,

    },
};


return setmetatable({},
{--dox metatable


});
