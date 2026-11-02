local DoxBuilder = DoxBuilder;
local assert     = assert;
local class      = class;
local error      = error;
local ipairs     = ipairs;
local pairs      = pairs;
local rawtype    = rawtype;
local require    = require;
local string     = string;
local table      = table;
local tonumber   = tonumber;


local Markdown = require("dox.Builders.GitHubWiki.Markdown");
local PageName;
local ResolveLink;
local FormatEntry;


--[[!
@fqxn Dox.Builders.GitHubWiki.Functions.PageName
@desc Creates a deterministic portable page name. Unsafe UTF-8 bytes and literal tildes are hex-encoded; a fixed prefix reserves Home and sidebar names.
@param string sName Fully qualified documentation name.
@ret string sPage Wiki page basename.
!]]
PageName = function(sName)
    local sPage = "API-"..sName:gsub("[^%w_.%-]", function(sByte)
        return string.format("~%02X", sByte:byte());
    end);

    -- Trailing dots are invalid on Windows even when the full name is safe.
    sPage = sPage:gsub("%.$", "~2E");
    assert(#sPage <= 240, "GitHub Wiki page filename exceeds 240 bytes: "..sName);

    return sPage;
end;


--[[!
@fqxn Dox.Builders.GitHubWiki.Functions.ResolveLink
@desc Maps known FQXN fragments to Wiki pages, leaving external URLs and ordinary local section anchors unchanged.
@param string sURL Source URL.
@param table tEntries FQXN lookup.
@ret string sURL Wiki link target.
!]]
ResolveLink = function(sURL, tEntries)
    local sName;
    local sDecoded;

    if (sURL:sub(1, 1) == "#") then
        sName = sURL:sub(2);
        sDecoded = sName:gsub("%%(%x%x)", function(sByte)
            return string.char(tonumber(sByte, 16));
        end);

        if (tEntries[sDecoded]) then
            return tEntries[sDecoded].page;
        end
    end

    -- Parentheses and whitespace must not terminate a Markdown destination.
    return (sURL:gsub("[%s()<>]", function(sByte)
        return string.format("%%%02X", sByte:byte());
    end));
end;


--[[!
@fqxn Dox.Builders.GitHubWiki.Functions.FormatEntry
@desc Formats ordered tags, preserving repeated sections and inherited content. Utility metadata is excluded; code examples retain the parser's language.
@param table tEntry Resolved documentation entry.
@param table tEntries Complete FQXN lookup.
@param string sLanguage Source-language identifier.
@ret string sContent Markdown documentation sections.
!]]
FormatEntry = function(tEntry, tEntries, sLanguage)
    local tLines = {};
    local sPrevious;

    local function fLink(sURL)
        return ResolveLink(sURL, tEntries);
    end

    for _, tItem in ipairs(tEntry.items) do
        local sDisplay = tItem.display;
        local sContent;

        if (sDisplay ~= sPrevious or not tItem.combined) then
            tLines[#tLines + 1] = "## "..sDisplay;
        end

        if (sDisplay == "Example") then
            sContent = Markdown.code(Markdown.decode(tItem.content), sLanguage);
        elseif (sDisplay == "Code" and not tItem.content:find("<pre", 1, true)) then
            sContent = Markdown.code(Markdown.decode(tItem.content));
        elseif (tItem.columns > 1) then
            local tColumns = {};
            local sRest = tItem.content;

            -- Retain the final description column as a whole, including newlines.
            for nColumn = 1, tItem.columns - 1 do
                local sValue, sTail = sRest:match("^(%S+)%s+(.*)$");
                assert(sValue, "Missing documentation column in "..tEntry.name..": "..sDisplay);
                tColumns[#tColumns + 1] = sValue;
                sRest = sTail;
            end

            sContent = "- "..string.char(96)..table.concat(tColumns, " ")..string.char(96)..
                       ": "..Markdown.convert(sRest, fLink);
        else
            sContent = Markdown.convert(tItem.content, fLink);
        end

        tLines[#tLines + 1] = sContent;
        sPrevious = sDisplay;
    end

    return table.concat(tLines, "\n\n");
end;


--[[!
@fqxn Dox.Builders.GitHubWiki
@desc Builds GitHub Wiki Markdown from raw Dox blocks. Produces Home, a sidebar and one page per FQXN, including navigation-only ancestors. Export writes into the existing directory selected by Dox.setOutputPath; it does not publish or delete files.
@ex
local oDocument = DoxLua("MyProject");
oDocument.setOutputPath("wiki");
oDocument.importFiles({"MyLibrary.lua"});
oDocument.setBuilder(Dox.BUILDER.GITHUB_WIKI);
oDocument.export(); --writes wiki/Home.md and linked pages
!]]
return class("DoxBuilderGitHubWiki", {}, {}, {}, {}, {
    --[[!
    @fqxn Dox.Builders.GitHubWiki.Constructor
    @pulsarlua function DoxBuilderGitHubWiki
    @desc Initializes a Markdown builder without mutable document or filesystem settings.
    !]]
    DoxBuilderGitHubWiki = function(this, cdat, super)
        super("DoxBuilderGitHubWiki", DoxBuilder.MIME.MARKDOWN, "", "Home", "\n", {});
    end,


    --[[!
    @fqxn Dox.Builders.GitHubWiki.Methods.refresh
    @pulsarlua function DoxBuilderGitHubWiki.refresh
    @desc Collects raw tags and navigation ancestors, validates case-insensitive filenames and resolves complete inheritdoc chains. Duplicate FQXNs, missing inheritance targets and cycles are rejected before file writes.
    @param table tBlocks Parsed documentation blocks.
    @param function fProcessBlockItem Shared formatter; unused because raw tags are retained.
    @ret table tData Sorted entries and name lookup, owned by this document.
    !]]
    refresh = function(this, cdat, tBlocks, fProcessBlockItem)
        local tEntries   = {};
        local tNames     = {};
        local tFilenames = {};
        local tResolving = {};
        local tResolved  = {};
        local fResolve;

        -- Build the complete name map before resolving references.
        for _, oBlock in ipairs(tBlocks) do
            local tParts = {};
            local tEntry;

            for _, _, sPart in oBlock.fqxn() do
                local sName;
                tParts[#tParts + 1] = sPart;
                sName = table.concat(tParts, ".");

                if (not tEntries[sName]) then
                    local sPage = PageName(sName);
                    local sKey  = sPage:lower();

                    assert(not tFilenames[sKey], "GitHub Wiki filename collision: "..sName);
                    tFilenames[sKey] = sName;
                    tEntries[sName] = {name = sName, page = sPage, items = {}, children = {}, documented = false};
                    tNames[#tNames + 1] = sName;

                    if (#tParts > 1) then
                        local sParent = table.concat(tParts, ".", 1, #tParts - 1);
                        tEntries[sParent].children[#tEntries[sParent].children + 1] = sName;
                        tEntries[sName].parent = sParent;
                    end
                end

                tEntry = tEntries[sName];
            end

            assert(tEntry, "Empty GitHub Wiki FQXN.");
            assert(not tEntry.documented, "Duplicate GitHub Wiki FQXN: "..tEntry.name);
            tEntry.documented = true;

            for oTag, sContent in oBlock.eachItem() do
                local sDisplay = oTag.getDisplay();

                if (sDisplay == "Inheritdoc") then
                    tEntry.inherited = sContent:match("^%s*(.-)%s*$");
                elseif (not oTag.isUtil()) then
                    tEntry.items[#tEntry.items + 1] = {
                        display  = sDisplay,
                        content  = sContent,
                        columns  = oTag.getColumnCount(),
                        combined = oTag.isCombined(),
                    };
                end
            end
        end

        -- Validate the inheritance graph before sharing resolved read-only content.
        fResolve = function(tEntry)
            local tParent;

            if (tResolved[tEntry]) then
                return;
            end

            assert(not tResolving[tEntry], "Circular Wiki documentation inheritance: "..tEntry.name);
            tResolving[tEntry] = true;

            if (tEntry.inherited) then
                tParent = tEntries[tEntry.inherited];
                assert(tParent and tParent.documented, "Missing Wiki documentation inheritance target: "..tEntry.inherited);
                fResolve(tParent);
                tEntry.items = tParent.items;
            end

            tResolving[tEntry] = nil;
            tResolved[tEntry]  = true;
        end;

        table.sort(tNames);

        for _, sName in ipairs(tNames) do
            table.sort(tEntries[sName].children);
            fResolve(tEntries[sName]);
        end

        return {entries = tEntries, names = tNames};
    end,


    --[[!
    @fqxn Dox.Builders.GitHubWiki.Methods.build
    @pulsarlua function DoxBuilderGitHubWiki.build
    @desc Builds a complete page manifest without filesystem side effects. HTML theme settings are ignored; code language comes from the parser syntax.
    @param string sTitle Project title.
    @param string sIntro Optional HTML or Markdown introduction.
    @param table tData Prepared Wiki entries.
    @param Dox.PRISM ePrismTheme Unused HTML theme.
    @param string sBannerURL Optional banner image.
    @param Dox.THEME ePageTheme Unused HTML theme.
    @param Dox.SYNTAX eSyntax Parser syntax.
    @ret table tFiles Filename-to-content map; export controls the home filename.
    !]]
    build = function(this, cdat, sTitle, sIntro, tData, ePrismTheme, sBannerURL, ePageTheme, eSyntax)
        local tFiles   = {};
        local tEntries = tData.entries;
        local tHome    = {"# "..Markdown.label(sTitle)};
        local tSidebar = {};
        local sLanguage = eSyntax and eSyntax.value.getPrismName() or "";

        local function fLink(sURL)
            return ResolveLink(sURL, tEntries);
        end

        if (rawtype(sBannerURL) == "string" and sBannerURL ~= "") then
            tHome[#tHome + 1] = "![Documentation banner]("..fLink(sBannerURL)..")";
        end

        if (rawtype(sIntro) == "string" and sIntro:find("%S")) then
            tHome[#tHome + 1] = Markdown.convert(sIntro, fLink);
        end

        tHome[#tHome + 1] = "## API";

        for _, sName in ipairs(tData.names) do
            local tEntry = tEntries[sName];
            local tPage  = {"# "..Markdown.label(sName)};
            local sLink  = "["..Markdown.label(sName).."]("..tEntry.page..")";

            tSidebar[#tSidebar + 1] = "- "..sLink;

            if (not tEntry.parent) then
                tHome[#tHome + 1] = "- "..sLink;
            else
                local tParent = tEntries[tEntry.parent];
                tPage[#tPage + 1] = "Parent: ["..Markdown.label(tParent.name).."]("..tParent.page..")";
            end

            tPage[#tPage + 1] = FormatEntry(tEntry, tEntries, sLanguage);

            if (#tEntry.children > 0) then
                tPage[#tPage + 1] = "## Members";

                for _, sChild in ipairs(tEntry.children) do
                    tPage[#tPage + 1] = "- ["..Markdown.label(sChild).."]("..tEntries[sChild].page..")";
                end
            end

            tFiles[tEntry.page..".md"] = table.concat(tPage, "\n\n").."\n";
        end

        tFiles["Home.md"]     = table.concat(tHome, "\n\n").."\n";
        tFiles["_Sidebar.md"] = table.concat(tSidebar, "\n").."\n";

        return tFiles;
    end,


    --[[!
    @fqxn Dox.Builders.GitHubWiki.Methods.export
    @pulsarlua function DoxBuilderGitHubWiki.export
    @desc Writes a validated page manifest to Dox's existing output directory. Defaults to Home.md; an explicit safe filename renames the landing page. Matching files are overwritten; unrelated and obsolete files are not deleted. A filesystem failure can leave previously written pages and is reported.
    @param string pOutputPath Existing directory from Dox.setOutputPath.
    @param string|nil sFilename Optional landing-page basename.
    @param string sTitle Project title.
    @param string sIntro Optional introduction.
    @param table tData Prepared Wiki data.
    @param Dox.PRISM ePrismTheme Unused HTML theme.
    @param string sBannerURL Optional banner URL.
    @param Dox.THEME ePageTheme Unused HTML theme.
    @param Dox.SYNTAX eSyntax Source syntax.
    @ret string pOut Written landing-page path.
    @ret string sOutput Landing-page Markdown for Dox.getOutput.
    !]]
    export = function(this, cdat, pOutputPath, sFilename, sTitle, sIntro, tData, ePrismTheme, sBannerURL, ePageTheme, eSyntax)
        local pro     = cdat.pro;
        local tFiles  = this.build(sTitle, sIntro, tData, ePrismTheme, sBannerURL, ePageTheme, eSyntax);
        local tNames  = {};
        local sHome   = tFiles["Home.md"];
        local sHomeURL;
        local pOut;

        assert(rawtype(pOutputPath) == "string", "Wiki output path must be a string.");
        sFilename = rawtype(sFilename) == "string" and sFilename:isfilesafe() and sFilename or "Home";
        assert(sFilename:sub(1, 4):lower() ~= "api-" and sFilename:sub(1, 1) ~= "_",
               "Wiki landing-page name is reserved: "..sFilename);
        sHomeURL = sFilename:gsub("[^%w_.~%-]", function(sByte)
            return string.format("%%%02X", sByte:byte());
        end);
        tFiles["Home.md"] = nil;
        tFiles[sFilename..".md"] = sHome;
        tFiles["_Sidebar.md"] = "- [Home]("..sHomeURL..")\n"..tFiles["_Sidebar.md"];

        -- Finish all naming/content validation before opening the first file.
        for sName in pairs(tFiles) do
            assert(sName:isfilesafe(), "Invalid Wiki filename: "..sName);
            tNames[#tNames + 1] = sName;
        end

        table.sort(tNames);

        for _, sName in ipairs(tNames) do
            pro.writeOutput(pOutputPath.."/"..sName, tFiles[sName], "wb");
        end

        pOut = pOutputPath.."/"..sFilename..".md";
        return pOut, sHome;
    end,
}, DoxBuilder, true);