local class     = class;
local clone     = clone;
local error     = error;
local ipairs    = ipairs;
local math      = math;
local pairs     = pairs;
local rawtype   = rawtype;
local table     = table;
local type      = type;


return class("DoxBlock",
{--METAMETHODS

},
{--STATIC PUBLIC

},
{--PRIVATE
    columns = 1,
    fqxn    = {};
    items   = {},
    getBlockTagForAlias = function(this, cdat, tBlockTags, sAlias)
        local oRet;

        for _, oBlockTag in pairs(tBlockTags) do

            if oBlockTag.hasAlias(sAlias) then
                oRet = oBlockTag;
                break;
            end

        end

        return oRet;
    end,
    getBlockData = function(this, cdat, sRawBlock, eLanguage, sTagOpen, tBlockTags)
        local pri   = cdat.pri;
        local tRet  = {};
        local sEscapeChar           = eLanguage.value.getEscapeCharater();
        local sTempAtSymbol         = "DOXAtSymbole7fa52f71cfe48298a9ad784026556fb";
        local sEscapedTagOpen       = sEscapeChar..sTagOpen;

        --replace the escaped @ symbols temporarily
        local sBlock = sRawBlock:gsub(sEscapedTagOpen, sTempAtSymbol);

        --break the block up into items
        local tBlockItems = sBlock:gsub("^%s+", ""):totable(sTagOpen);

        if not (tBlockItems) then
            error("Error creating DoxBlock object: malformed block:\n'"..sBlock.."'", 3);
        end

        --iterate over each block item
        for nItemIndex, sRawItem in ipairs(tBlockItems) do
            --replace the @ symbols and trim trailing space
            local sItemInProcess = sRawItem:gsub(sTempAtSymbol:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"), sTagOpen):gsub("%s+$", "");--gsub("\n$", "");
            local sItem = sItemInProcess:match("%S.*%S");

            --validate the item is still good
            if not (sItem) then
                error("Error creating DoxBlock object: malformed block item:\n'"..sItemInProcess.."'\n\nIn block string:\n'"..sBlock.."'", 3);
            end

            --get the alias
            local sAlias = sItem:match("%S+");

            --validate the item alias
            if not (sAlias) then
                error("Error creating DoxBlock object: malformed block item:\n'"..sItem.."'\n\nIn block string:\n'"..sBlock.."'", 3);
            end

            --get the BlockTag object associated with the item
            local oBlockTag = pri.getBlockTagForAlias(tBlockTags, sAlias);

            --make sure a BlockTag object was recovered
            if not (oBlockTag) then
                error("Error creating DoxBlock object: invalid block item alias, '"..sAlias.."', in item:\n'"..sItem.."'\n\nIn block string:\n'"..sBlock.."'", 3);
            end

            tRet[#tRet + 1] = {
                item      = sItem,
                blockTag  = oBlockTag,
            };
        end

        return tRet;
    end
},
{--PROTECTED

},
{--PUBLIC
    DoxBlock = function(this, cdat, sRawBlock, eLanguage, sTagOpen, tBlockTags, tRequiredBlockTags)
        local pri                = cdat.pri;
        type.assert.string(sRawBlock, "%S+", "Dox blockstring must not be blank.");
        --TODO asserts? Or, since this is internal, should I trust the input? Probably not.

        local tBlockData = pri.getBlockData(sRawBlock, eLanguage, sTagOpen, tBlockTags);

        --create a table for tracking required block tags found
        local tRequiredBlockTagsFound = {};
        for _, oBlockTag in pairs(tRequiredBlockTags) do
            tRequiredBlockTagsFound[oBlockTag] = false;--true if not found
        end

        --keeps track of block tag count
        local tBlockTagCounts = {};

        --process the block data
        for _, tLineData in ipairs(tBlockData) do
            local sRawItem      = tLineData.item;
            local oItemBlockTag = tLineData.blockTag;

            --log required block tags found
            for __, oRequiredBlockTag in pairs(tRequiredBlockTags) do
                if (oItemBlockTag == oRequiredBlockTag) then
                    --set as found
                    tRequiredBlockTagsFound[oRequiredBlockTag] = true;
                    break;
                end

            end

            --log block tag count
            if not (tBlockTagCounts[oItemBlockTag]) then
                tBlockTagCounts[oItemBlockTag] = 0;
            end
            tBlockTagCounts[oItemBlockTag] = tBlockTagCounts[oItemBlockTag] + 1;

            --split the string into tag and contents
            local sTag, sContent = sRawItem:match("([^%s]*)%s(.*)");
            type.assert.string(sContent, "%S+", "Dox BlockTag content must not be blank.\n"..tostring(oItemBlockTag).."\n\nIn Block:\n"..sRawBlock);

            --store the content
            if (oItemBlockTag.getDisplay() == "FQXN") then

                local tFQXN = sContent:totable('.');

                if not (tFQXN) then
                    error("Error creating DoxBlock: invalid FQXN\n"..tostring(oItemBlockTag).."\n\nIn Block:\n"..sRawBlock, 3);
                end

                pri.fqxn = tFQXN;
            else
                table.insert(pri.items, {
                    blockTag    = oItemBlockTag,
                    content     = sContent,
                });
            end

        end

        --make sure all required block tags were found in the block
        for oBlockTag, bBlockTagFound in pairs(tRequiredBlockTagsFound) do

            if not (bBlockTagFound) then
                error("Error creating DoxBlock: required block tag missing\n"..tostring(oBlockTag).."\n\nIn Block:\n"..sRawBlock, 3);
            end

        end

        --check for disallowed multiples
        for oBlockTag, nCount in pairs(tBlockTagCounts) do
            if (not oBlockTag.isMultipleAllowed() and nCount > 1) then
                error("Error creating DoxBlock: multiple block tags not permitted: \n"..tostring(oBlockTag).."\n\nIn Block:\n"..sRawBlock.."\nTotal count: "..nCount..'.', 3);
            end

        end

        --used to sort the items table
        local tSortOrder = {};

        for nIndex, oBlockTag in ipairs(tBlockTags) do
            tSortOrder[nIndex] = oBlockTag.getDisplay();
        end

        -- Create a mapping from the values in tSortOrder to their indices
        local function createSortMapping(tSortOrder)
            local mapping = {}
            for index, value in ipairs(tSortOrder) do
                mapping[value] = index
            end
            return mapping
        end
        -- Add index to each item to maintain original order
        local function addIndexToItems(items)
            for i, item in ipairs(items) do
                item.originalIndex = i;
            end
        end

        -- Custom sorting function with stable sort
        local function customSort(a, b, mapping)
            local displayA = a.blockTag:getDisplay();
            local displayB = b.blockTag:getDisplay();

            local indexA = mapping[displayA] or math.huge;
            local indexB = mapping[displayB] or math.huge;

            if indexA == indexB then
                -- If indices are the same, maintain original order
                return a.originalIndex < b.originalIndex;
            else
                -- Otherwise, sort based on indices
                return indexA < indexB;
            end
        end

        -- Function to sort pri.items based on tSortOrder
        local function sortItems()
            addIndexToItems(pri.items)  -- Add index to items
            local mapping = createSortMapping(tSortOrder);

            table.sort(pri.items, function(a, b)
                return customSort(a, b, mapping);
            end)
        end

        sortItems();
    end,
    eachItem = function(this, cdat)
        local tItems = cdat.pri.items;
        local nIndex    = 0;
        local nMax      = #tItems;

        return function()
            nIndex = nIndex + 1;

            if (nIndex <= nMax) then
                local tItem = tItems[nIndex];
                return clone(tItem.blockTag), tItem.content;
            end

        end

    end,
    fqxn = function(this, cdat)
        local tFQXN     = cdat.pri.fqxn;
        local nIndex    = 0;
        local nMax      = #tFQXN;

        return function()
            nIndex = nIndex + 1;

            if (nIndex <= nMax) then
                return nIndex == nMax, nIndex, tFQXN[nIndex];
            end

        end

    end,
    item = function(this, cdat, nIndex)
        local tItems = cdat.pri.items;

        -- Only existing, positive integer indexes identify documentation items.
        if (rawtype(nIndex) ~= "number" or nIndex % 1 ~= 0 or nIndex < 1 or nIndex > #tItems) then
            error("Error reading DoxBlock item: index must identify an existing item.", 2);
        end

        local tItem = tItems[nIndex];

        return clone(tItem.blockTag), tItem.content;
    end,
},
nil,   --extending class
true,  --if the class is final
nil    --interface(s) (either nil, or interface(s))
);
