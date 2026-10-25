local assert    = assert;
local class     = class;
local clone     = clone;
local enum      = enum;
local error     = error;
local ipairs    = ipairs;
local math      = math;
local pairs     = pairs;
local rawtype   = rawtype;
local type      = type;


local sImportError = "Cannot import column wrapper into DoxBuilder.";
--[[!
@fqxn Dox.Builders.DoxBuilder
@desc This is the class (when subclassed) that builds the output using Dox's finalized data.
!]]
return class("DoxBuilder",
{--METAMETHODS

},
{--STATIC PUBLIC
    MIME = enum("DoxBuilder.MIME", {"HTML", "LUACOMPLETERC", "MARKDOWN", "TXT"}, {"html", "luacompleterc", "MD", "txt"}, true),
},
{--PRIVATE
    mime                = null,
    Name__autoAF        = "",
},
{--PROTECTED
    blockWrapper = {
        open = "",
        close = "",
    },
    columnWrappers = {},
    copyToClipboardButton = "",
    defaultFilename = "",
    newLine = "",
    DoxBuilder = function(this, cdat, sName, eMime, sCopyToClipBoardButton, sDefaultFilename, sNewLine, tColumnWrappers)
        type.assert.custom(eMime, "DoxBuilder.MIME");
        type.assert.string(sName, "%S+");
        type.assert.string(sDefaultFilename);
        assert(sDefaultFilename:isfilesafe(), "Error creating DoxBuilder. Default filename must be a file-safe string.");

        if (sCopyToClipBoardButton ~= nil and rawtype(sCopyToClipBoardButton) ~= "string") then
            error("DoxBuilder copy button must be a string or nil.", 2);
        end
        local pri = cdat.pri;
        local pro = cdat.pro;

        pri.Name                    = sName;
        pri.mime                    = eMime;
        pro.copyToClipboardButton   = type(sCopyToClipBoardButton) == "string" and sCopyToClipBoardButton or "";
        pro.defaultFilename         = sDefaultFilename;
        pro.newLine                 = rawtype(sNewLine) == "string" and sNewLine or "\n";

        --import column wrappers
        if (type(tColumnWrappers) == "table") then

            for sDisplay, tWrapperSet in pairs(tColumnWrappers) do --indexed by DoxBlockTag Display name, contains tables of wrapper sets
                type.assert.string(sDisplay, "%S+", sImportError.." Tag display name cannot be empty.");

                    type.assert.table(tWrapperSet, "number", "table", 1, nil, sImportError.." Expected numerically-indexed column wrapper table for display, '"..sDisplay.."'.");

                if (pro.columnWrappers[sDisplay] == nil) then
                    pro.columnWrappers[sDisplay] = {};
                end

                for nColumn, tWrapper in ipairs(tWrapperSet) do

                        type.assert.table(tWrapper, "number", "string", 2, 2, sImportError.." Expected numerically-indexed wrapper table with string values for display, '"..sDisplay.."'.");

                    pro.columnWrappers[sDisplay][nColumn] = {};

                    for nIndex, sWrapper in ipairs(tWrapper) do
                        pro.columnWrappers[sDisplay][nColumn][nIndex] = sWrapper;
                    end

                end

            end

        end

    end,
},
{--PUBLIC
    --[[!
    @fqxn Dox.Builders.DoxBuilder.Methods.build
    @pulsarlua function DoxBuilder.build
    @desc This is the build method that does the heavy lifting in building the output file.
    <br><br>After the basic <em>this</em> and <em>cdat</em> parameters, this method must accept the following parameters in the following order:
    <ol>
        <li><em>(string)</em> <strong>sTitle</strong> The title of the documentation project.</li>
        <li><em>(string or nil)</em> <strong>vIntro</strong> The (optional) intro page code. If not provided here, the intro will be the default provided by Dox.</li>
        <li><em>(table)</em> <strong>tFinalizedData</strong> Dox's finalized data used to build the output document.</li>
        The finalized data table has keys of strings whose values are strings. The table is a heirarchical list of fqxn's (Fully Qualified Dox Names). The data for each item is stored in the <em><strong>__call</strong></em> metamethod. To extract the data from a given index, simply call it. A string will be returned containing the item's data.
    </ol>
    !]]
    build = function(this, cdat)
        error("Error in DoxBuilder. The 'build' method has not been defined in the child class.", 4);
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilder.Methods.clearColumnWrappers
    @pulsarlua function DoxBuilder.clearColumnWrappers
    @desc Removes all column wrappers, or only the named display group.
    @param string|nil sDisplay The display group to clear; nil clears all groups.
    !]]
    clearColumnWrappers = function(this, cdat, sDisplay)
        if (sDisplay == nil) then
            cdat.pro.columnWrappers = {};
        else
            type.assert.string(sDisplay, "%S+");
            cdat.pro.columnWrappers[sDisplay] = nil;
        end
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilder.Methods.eachColumnWrapper
    @pulsarlua function DoxBuilder.eachColumnWrapper
    @desc Iterates over copies of one display group's column wrappers.
    @param string sDisplay The display group.
    @return function fIterator Returns a column index and a copied wrapper pair; missing groups are empty.
    !]]
    eachColumnWrapper = function(this, cdat, sDisplay)
        type.assert.string(sDisplay, "%S+");
        local nIndex = 0;
        local tWrappers = this.getColumnWrappers(sDisplay);

        return function()
            nIndex = nIndex + 1;

            if (tWrappers[nIndex]) then
                return nIndex, clone(tWrappers[nIndex]);
            end
        end;
    end,
    formatBlockContent = function(this, cdat, sID, sDisplay, sContent)
        error("Error in DoxBuilder. The 'formatBlockContent' method has not been defined in the child class.", 4);
    end,
    formatCombinedBlockContent = function(this, cdat, sDisplay, sCombinedContent)
        error("Error in DoxBuilder. The 'formatCombinedBlockContent' method has not been defined in the child class.", 4);
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilder.Methods.getColumnWrapper
    @pulsarlua function DoxBuilder.getColumnWrapper
    @desc Returns a copy of one wrapper pair; missing wrappers return two empty strings.
    @param string sDisplay The display group.
    @param number nColumn The column index.
    @return table tWrapper Opening and closing strings.
    !]]
    getColumnWrapper = function(this, cdat, sDisplay, nColumn)
        local tColumnWrappers = cdat.pro.columnWrappers;
        local tRet = {
            [1] = "",
            [2] = "",
        };

        if (tColumnWrappers[sDisplay] ~= nil) then
            local tWrappers = tColumnWrappers[sDisplay];

            if (tWrappers[nColumn] ~= nil) then
                tRet = clone(tWrappers[nColumn]);
            end

        end

        return tRet;
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilder.Methods.getColumnWrappers
    @pulsarlua function DoxBuilder.getColumnWrappers
    @desc Returns a copy of a display group; missing groups return an empty table.
    @param string sDisplay The display group.
    @return table tWrappers The wrapper pairs.
    !]]
    getColumnWrappers = function(this, cdat, sDisplay)
        local tColumnWrappers = cdat.pro.columnWrappers;
        local tRet = {};

        if (tColumnWrappers[sDisplay] ~= nil) then
            tRet = clone(tColumnWrappers[sDisplay]);
        end

        return tRet;
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilder.Methods.getColumnWrapperCount
    @pulsarlua function DoxBuilder.getColumnWrapperCount
    @desc Gets the total number of column wrappers in this <strong>DoxBuilder</strong>.
    @return number nColumnWrappers The number of the column wrappers in this <strong>DoxBuilder</strong>.
    !]]
    getColumnWrapperCount = function(this, cdat, sDisplay)
        local nRet = 0;
        local tColumnWrappers = cdat.pro.columnWrappers;

        if (tColumnWrappers[sDisplay] ~= nil) then

            for _, __ in pairs(tColumnWrappers[sDisplay]) do
                nRet = nRet + 1;
            end

        end

        return nRet;
    end,
    getCopyToClipboardButton = function(this, cdat)
        return cdat.pro.copyToClipboardButton;
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilder.Methods.getDefaultFilename
    @pulsarlua function DoxBuilder.getDefaultFilename
    @desc Returns the default filename of the final ouput document that is used if one is not provided by the user.
    @ret string sFilename The default filename.
    !]]
    getDefaultFilename = function(this, cdat)
        return cdat.pro.defaultFilename;
    end,
    getBlockWrapper = function(this, cdat)
        return clone(cdat.pro.blockWrapper);
    end,
    getMime = function(this, cdat)
        return cdat.pri.mime;
    end,
    getNewLine = function(this, cdat)
        return cdat.pro.newLine;
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilder.Methods.setColumnWrapper
    @pulsarlua function DoxBuilder.setColumnWrapper
    @desc Replaces a wrapper or appends the next column, creating a group when necessary. Empty strings leave content unwrapped.
    @param string sDisplay The display group.
    @param number nColumn Positive integer column index; gaps are rejected.
    @param string sOpen Opening wrapper.
    @param string sClose Closing wrapper.
    !]]
    setColumnWrapper = function(this, cdat, sDisplay, nColumn, sOpen, sClose)
        local pro = cdat.pro;
        local tColumnWrappers = pro.columnWrappers;
        type.assert.string(sDisplay, "%S+");
        type.assert.number(nColumn, true, true, false, true, false);
        type.assert.string(sOpen);
        type.assert.string(sClose);

        local tWrappers = tColumnWrappers[sDisplay] or {};

        -- Permit replacement and sequential append, without introducing gaps.
        if (nColumn > #tWrappers + 1) then
            error("Error setting column wrapper for item, '"..sDisplay.."'. Column index "..nColumn.." is out of bounds.", 2);
        end

        tWrappers[nColumn] = {
            [1] = sOpen,
            [2] = sClose,
        };

        tColumnWrappers[sDisplay] = tWrappers;
    end,
},
nil,   --extending class
false, --if the class is final
nil    --interface(s) (either nil, or interface(s))
);
