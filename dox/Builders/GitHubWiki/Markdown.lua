local ipairs     = ipairs;
local math       = math;
local rawtype    = rawtype;
local string     = string;
local table      = table;
local tonumber   = tonumber;
local utf8       = utf8;


local Markdown = {};
local _sTick   = string.char(96);
local _tEntities = {
    amp = "&", apos = "'", gt = ">", lt = "<", nbsp = " ", quot = '"',
};


--[[!
@fqxn Dox.Builders.GitHubWiki.Markdown.decode
@desc Decodes common named and valid numeric HTML entities once, preserving unknown entities.
@param string sText Encoded text.
@ret string sText Decoded text.
!]]
function Markdown.decode(sText)
    return (sText:gsub("&(#?[%w]+);", function(sEntity)
        local nCode;

        if (sEntity:sub(1, 2):lower() == "#x") then
            nCode = tonumber(sEntity:sub(3), 16);
        elseif (sEntity:sub(1, 1) == "#") then
            nCode = tonumber(sEntity:sub(2), 10);
        end

        if (nCode and nCode >= 0 and nCode <= 0x10ffff and
            not (nCode >= 0xd800 and nCode <= 0xdfff)) then
            return utf8.char(nCode);
        end

        return _tEntities[sEntity] or "&"..sEntity..";";
    end));
end


--[[!
@fqxn Dox.Builders.GitHubWiki.Markdown.attribute
@desc Reads a quoted or unquoted HTML attribute without matching a longer attribute name.
@param string sTag HTML opening tag.
@param string sName Lowercase attribute name.
@ret string|nil sValue Decoded attribute value.
!]]
function Markdown.attribute(sTag, sName)
    for sKey, sQuote, sValue in sTag:gmatch("([%w_:%-]+)%s*=%s*(['\"])(.-)%2") do
        if (sKey:lower() == sName) then
            return Markdown.decode(sValue);
        end
    end

    for sKey, sValue in sTag:gmatch("([%w_:%-]+)%s*=%s*([^%s'\">]+)") do
        if (sKey:lower() == sName) then
            return Markdown.decode(sValue);
        end
    end
end


--[[!
@fqxn Dox.Builders.GitHubWiki.Markdown.code
@desc Fences code using a delimiter longer than any backtick sequence in its content.
@param string sText Literal code.
@param string|nil sLanguage Highlighting language identifier.
@ret string sCode Markdown code block.
!]]
function Markdown.code(sText, sLanguage)
    local nLength = 3;
    local sFence;

    for sRun in sText:gmatch(_sTick.."+") do
        nLength = math.max(nLength, #sRun + 1);
    end

    sLanguage = rawtype(sLanguage) == "string" and sLanguage:match("^[%w_+%-]+$") or "";
    sFence    = string.rep(_sTick, nLength);

    return sFence..sLanguage.."\n"..sText..(sText:sub(-1) == "\n" and "" or "\n")..sFence;
end


--[[!
@fqxn Dox.Builders.GitHubWiki.Markdown.label
@desc Escapes text used as a Markdown link label.
@param string sText Label text.
@ret string sLabel Escaped label.
!]]
function Markdown.label(sText)
    return (sText:gsub("([\\%[%]])", "\\%1"):gsub("[\r\n]+", " "));
end


--[[!
@fqxn Dox.Builders.GitHubWiki.Markdown.convert
@desc Converts static HTML descriptions to Markdown, preserving fenced and inline code. Handles headings, emphasis, lists, tables, links and images; drops script/style content and layout tags. Interactive controls and CSS behavior are not reproduced.
@param string sText Source description or introduction.
@param function fLink Link-target resolver.
@ret string sMarkdown Converted content.
!]]
function Markdown.convert(sText, fLink)
    local tProtected = {};
    local tSegments  = {};
    local tLists     = {};
    local sPrefix    = "\1DOX";
    local nIndex     = 1;
    local sOutput;

    -- Reserve markers absent from the source, so authored text cannot collide.
    while (sText:find(sPrefix, 1, true)) do
        sPrefix = sPrefix.."X";
    end

    local function fProtect(sContent)
        tProtected[#tProtected + 1] = sContent;
        return sPrefix..#tProtected.."\2";
    end

    local function fConvert(sContent)
        return Markdown.convert(sContent, fLink);
    end

    sOutput = sText:gsub("\r\n", "\n");


    -- HTML code is protected before scanning authored Markdown backticks.
    sOutput = sOutput:gsub("<pre([^>]*)>(.-)</pre%s*>", function(sAttributes, sBody)
        local sLanguage = sBody:match('class%s*=%s*["\']language%-([%w_+%-]+)');
        sBody = sBody:gsub("^%s*<code[^>]*>", ""):gsub("</code>%s*$", "");
        return "\n\n"..fProtect(Markdown.code(Markdown.decode(sBody), sLanguage)).."\n\n";
    end);

    -- Match complete delimiter runs; partial runs must never consume code bytes.

    while (nIndex <= #sOutput) do
        local nOpen, nAfterOpen = sOutput:find(_sTick.."+", nIndex);
        local nClose;
        local nAfterClose;
        local nSearch;

        if (not nOpen) then
            tSegments[#tSegments + 1] = sOutput:sub(nIndex);
            break;
        end

        tSegments[#tSegments + 1] = sOutput:sub(nIndex, nOpen - 1);
        nSearch = nAfterOpen + 1;

        while (nSearch <= #sOutput) do
            local nCandidate, nAfterCandidate = sOutput:find(_sTick.."+", nSearch);

            if (not nCandidate) then
                break;
            end

            if (nAfterCandidate - nCandidate == nAfterOpen - nOpen) then
                nClose, nAfterClose = nCandidate, nAfterCandidate;
                break;
            end

            nSearch = nAfterCandidate + 1;
        end

        if (nClose) then
            tSegments[#tSegments + 1] = fProtect(sOutput:sub(nOpen, nAfterClose));
            nIndex = nAfterClose + 1;
        else
            tSegments[#tSegments + 1] = sOutput:sub(nOpen, nAfterOpen);
            nIndex = nAfterOpen + 1;
        end
    end

    sOutput = table.concat(tSegments);
    if (sOutput:find("</?[%a]")) then
        sOutput = sOutput:gsub("\n[ \t]+", "\n");
    end
    sOutput = sOutput:gsub("<code[^>]*>(.-)</code%s*>", function(sBody)
        local nLength = 1;
        local sFence;
        sBody = Markdown.decode(sBody);

        for sRun in sBody:gmatch(_sTick.."+") do
            nLength = math.max(nLength, #sRun + 1);
        end

        sFence = string.rep(_sTick, nLength);
        return fProtect(sFence.." "..sBody.." "..sFence);
    end);
    sOutput = sOutput:gsub("<!%-%-.-%-%->", "");
    sOutput = sOutput:gsub("<[sS][cC][rR][iI][pP][tT][^>]*>.-</[sS][cC][rR][iI][pP][tT]%s*>", "");
    sOutput = sOutput:gsub("<[sS][tT][yY][lL][eE][^>]*>.-</[sS][tT][yY][lL][eE]%s*>", "");
    sOutput = sOutput:gsub("(%b[])(%b())", function(sLabel, sTarget)
        local sURL = sTarget:sub(2, -2);
        return fProtect(sLabel.."("..fLink(sURL)..")");
    end);
    sOutput = sOutput:gsub("<a(%s[^>]*)>(.-)</a%s*>", function(sAttributes, sBody)
        local sURL = Markdown.attribute(sAttributes, "href");
        local sLabel = fConvert(sBody);
        return sURL and fProtect("["..sLabel.."]("..fLink(sURL)..")") or sLabel;
    end);
    sOutput = sOutput:gsub("<img(%s[^>]*)/?>", function(sAttributes)
        local sURL = Markdown.attribute(sAttributes, "src");
        local sAlt = Markdown.attribute(sAttributes, "alt") or "";
        return sURL and fProtect("!["..Markdown.label(sAlt).."]("..fLink(sURL)..")") or "";
    end);
    sOutput = sOutput:gsub("<table[^>]*>(.-)</table%s*>", function(sTable)
        local tRows = {};
        local nColumns = 0;
        local tLines = {};

        for sRow in sTable:gmatch("<tr[^>]*>(.-)</tr%s*>") do
            local tCells = {};

            for sCell in sRow:gmatch("<t[dh][^>]*>(.-)</t[dh]%s*>") do
                local sCellText = fConvert(sCell):gsub("\n+", "<br>"):gsub("|", "\\|");
                tCells[#tCells + 1] = sCellText;
            end

            if (#tCells > 0) then
                nColumns = math.max(nColumns, #tCells);
                tRows[#tRows + 1] = tCells;
            end
        end

        for nRow, tCells in ipairs(tRows) do
            for nColumn = #tCells + 1, nColumns do
                tCells[nColumn] = "";
            end

            tLines[#tLines + 1] = "| "..table.concat(tCells, " | ").." |";

            if (nRow == 1) then
                tLines[#tLines + 1] = "|"..string.rep(" --- |", nColumns);
            end
        end

        return "\n\n"..fProtect(table.concat(tLines, "\n")).."\n\n";
    end);
    sOutput = sOutput:gsub("<[hH]([1-6])[^>]*>(.-)</[hH]%1%s*>", function(sLevel, sBody)
        return "\n\n"..string.rep("#", tonumber(sLevel)).." "..fConvert(sBody).."\n\n";
    end);
    sOutput = sOutput:gsub("<[bB][rR]%s*/?>", "\n");
    sOutput = sOutput:gsub("<[hH][rR][^>]*>", "\n\n---\n\n");
    sOutput = sOutput:gsub("</?[sS][tT][rR][oO][nN][gG][^>]*>", "**");
    sOutput = sOutput:gsub("</?[bB]%s*>", "**");
    sOutput = sOutput:gsub("</?[eE][mM]%s*>", "*");
    sOutput = sOutput:gsub("</?[iI]%s*>", "*");
    -- Preserve list nesting and ordered numbering while ignoring layout attributes.
    sOutput = sOutput:gsub("<(/?)([%a]+)([^>]*)>", function(sClose, sTag, sAttributes)
        local sName = sTag:lower();

        if (sName == "ul" or sName == "ol") then
            if (sClose == "/") then
                tLists[#tLists] = nil;
            else
                tLists[#tLists + 1] = {ordered = sName == "ol", count = 0};
            end

            return "\n";
        elseif (sName == "li") then
            if (sClose == "/") then
                return "";
            end

            local tList = tLists[#tLists];
            local sMarker = "- ";

            if (tList and tList.ordered) then
                tList.count = tList.count + 1;
                sMarker = tList.count..". ";
            end

            return "\n"..string.rep("    ", math.max(0, #tLists - 1))..sMarker;
        end

        return "<"..sClose..sTag..sAttributes..">";
    end);
    sOutput = sOutput:gsub("</?[pP]%s*>", "\n\n");
    sOutput = sOutput:gsub("</?[dD][iI][vV][^>]*>", "\n\n");
    sOutput = sOutput:gsub("</?[dD][eE][tT][aA][iI][lL][sS][^>]*>", "\n\n");
    sOutput = sOutput:gsub("</?[sS][uU][mM][mM][aA][rR][yY][^>]*>", "\n\n");
    sOutput = sOutput:gsub("</?[%a][^>]*>", "");
    sOutput = sOutput:gsub("(\n[ \t]*%- )%s*\n%s*", "%1");
    sOutput = sOutput:gsub("(\n[ \t]*%d+%. )%s*\n%s*", "%1");
    sOutput = Markdown.decode(sOutput);
    sOutput = sOutput:gsub("[ \t]+\n", "\n"):gsub("\n\n\n+", "\n\n"):gsub("^%s+", ""):gsub("%s+$", "");

    -- Restore protected code and links after all text transformations.
    for nPass = 1, #tProtected do
        local nRestored;
        sOutput, nRestored = sOutput:gsub(sPrefix.."(%d+)\2", function(sIndex)
            return tProtected[tonumber(sIndex)];
        end);

        if (nRestored == 0) then
            break;
        end
    end

    return sOutput;
end


return Markdown;