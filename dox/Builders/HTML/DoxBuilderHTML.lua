local DoxBuilder    = DoxBuilder;
local class         = class;
local debug         = debug;
local dofile        = dofile;
local error         = error;
local io            = io;
local ipairs        = ipairs;
local next          = next;
local package       = package;
local pairs         = pairs;
local rawtype       = rawtype;
local require       = require;
local setmetatable  = setmetatable;
local string        = string;
local table         = table;
local tostring      = tostring;
local type          = type;


--load in the builder's required files
local _pRequirePath        = "dox.Builders.HTML.Data";

--[[!
@fqxn Dox.Builders.DoxBuilderHTML.Functions.LoadDoxAsset
@vis local
@desc Loads a required builder asset using the module path, then paths relative to this file; reports all attempted paths on failure.
!]]
local function LoadDoxAsset(sModule)
    local pFile, sErr = package.searchpath(sModule, package.path);

    if (pFile) then
        return dofile(pFile);
    end

    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Functions.IsAbsolutePath
    @vis local
    @desc Tests whether a path is absolute before attempting a source-folder fallback.
    !]]
    local function IsAbsolutePath(pPath)
        return type(pPath) == "string"
            and (
                pPath:match("^%a:[/\\]") ~= nil
                or pPath:match("^[/\\][^/\\]") ~= nil
            );
    end

    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Functions.TryOpenAndLoad
    @vis local
    @desc Loads an existing asset file; returns nil when the file cannot be opened.
    !]]
    local function TryOpenAndLoad(pPath)
        local hFile = io.open(pPath, "rb");

        if (hFile) then
            hFile:close();
            return dofile(pPath);
        end

        return nil;
    end

    local sLeaf = sModule:match("([^.]+)$");
    local tTried = {};

    -- resolve relative to THIS loaded file, not package.path
    local tInfo = debug.getinfo(LoadDoxAsset, "S");
    local sSource = tInfo and tInfo.source or nil;
    local pThisFile = (type(sSource) == "string" and sSource:sub(1, 1) == "@") and sSource:sub(2) or nil;

    if (type(pThisFile) == "string" and not pThisFile:isempty()) then
        local pDir = pThisFile:match("^(.*)[/\\]") or ".";
        local sFolder = sLeaf == "Themes" and "\\" or "\\Data\\";
        local pAsset = pDir..sFolder..sLeaf..".lua";
        tTried[#tTried + 1] = pAsset;

        local vRet = TryOpenAndLoad(pAsset);
        if (vRet ~= nil) then
            return vRet;
        end

        if not (IsAbsolutePath(pAsset)) and type(_SourceFolder) == "string" and not _SourceFolder:isempty() then
            local pAnchored = (_SourceFolder.."\\ "..pAsset):gsub("\\ ", "\\"):gsub("[/\\]+", "\\");
            tTried[#tTried + 1] = pAnchored;

            vRet = TryOpenAndLoad(pAnchored);
            if (vRet ~= nil) then
                return vRet;
            end
        end
    end

    error(
        ("DoxBuilderHTML: failed to locate required asset module '%s'.\n" ..
         "package.searchpath failed.\nDetails:\n%s\n" ..
         "Paths tried:\n%s")
            :format(sModule, tostring(sErr), table.concat(tTried, "\n")),
        2
    );
end
local _sCSS  = LoadDoxAsset(_pRequirePath .. ".CSS");
local _sHTML = LoadDoxAsset(_pRequirePath .. ".HTML");
local _sJS   = LoadDoxAsset(_pRequirePath .. ".JS");

local _tThemes          = LoadDoxAsset("dox.Builders.HTML.Themes");
local _tPrismLanguages  = require(_pRequirePath..".PrismLanguages");
local _sPrismStable     = "1.30.0";
local _sDefaultFilename = "index";

return class("DoxBuilderHTML",
{--METAMETHODS

},
{--STATIC PUBLIC

},
{--PRIVATE
    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.buildJS
    @vis private
    @desc Combines serialized documentation data, optional introduction and browser navigation code.
    !]]
    buildJS = function(this, cdat, sIntro, tFinalizedData)
        local sRet          = "";
        local pri           = cdat.pri;
        local bFound        = false;
        local bIntro        = (rawtype(sIntro) == "string" and sIntro:find("%S+") ~= nil);
        local sIntro        = bIntro and sIntro or "";
        local sStartRead    = bIntro and "//—©_END_DOX_DEFAULT_INTRO_©—" or "//—©_END_DOX_TESTDATA_©—";
--
        --if a proper intro string has been provided, prep it
        if (bIntro) then
            sIntro = [[

    const doxData = {
        "Modules": {
            "value": `

            <div class="DOX_intro container">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="p-5 rounded">

        ]]..sIntro:gsub("`", "\\`"):gsub("${", "\\${")..[[

                        </div>
                    </div>
                </div>
            </div>

        `,
        "subtable": userData
        }
    };

    ]];
        end

        -- Read the input text line by line (split by newline character)
        for sLine in _sJS:gmatch("[^\r\n]+") do

            -- Check if the search string is in the current line
            if bFound then
                sRet = sRet .. sLine .. "\n";
            elseif string.find(sLine, sStartRead, 1, true) then
                bFound = true;
            end
        end

        if not bFound then
            error("DoxBuilderHTML: JavaScript template is missing required marker "..sStartRead..".", 2);
        end

        local sUserData = "const userData = "..pri.buildJSONTable(tFinalizedData);
        return sUserData.."\n\n"..sIntro.."\n\n"..sRet;
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.buildJSONTable
    @vis private
    @desc Serializes the hierarchical documentation model into JavaScript data, escaping keys and content.
    !]]
    buildJSONTable = function(this, cdat, tFinalizedData)
        local pri        = cdat.pri;


        --[[!
        @fqxn Dox.Builders.DoxBuilderHTML.Functions.luaTableToJson
        @vis local
        @desc Serializes the root documentation hierarchy using sorted keys and readable indentation.
        !]]
        local function luaTableToJson(tbl, startIndent)
            startIndent = startIndent or 0;
            local indentSpace = string.rep(" ", startIndent);

            --[[!
            @fqxn Dox.Builders.DoxBuilderHTML.Functions.processTable
            @vis local
            @desc Recursively serializes each callable documentation node and its children.
            !]]
            local function processTable(t, indent)
                local result = {};
                local sortedKeys = {};

                for key in pairs(t) do
                    table.insert(sortedKeys, key);
                end

                table.sort(sortedKeys);

                for _, key in ipairs(sortedKeys) do
                    local subtable       = t[key];
                    local value          = subtable();

                    --prep the value
                    value = pri.prepJSONString(value):gsub('`', "\\`"):gsub("${", "\\${");
                    local subtableResult = processTable(subtable, indent .. "    ");
                    local newstring = indent .. '"' .. pri.prepJSONString(key):gsub(" ", "%%20") .. '": {\n' ..
                                      indent .. '    "value": `' .. value .. '`,\n' ..
                                      indent .. '    "subtable": ' .. (next(subtableResult) and "{\n" .. table.concat(subtableResult, ",\n") .. "\n" .. indent .. "    }" or "null") .. '\n' ..
                                      indent .. '}';

                    table.insert(result, newstring);
                end

                return result;
            end

            local jsonResult = processTable(tbl, indentSpace);
            return "{\n" .. table.concat(jsonResult, ",\n") .. "\n" .. indentSpace .. "}";
        end

        -- Convert the Lua table to JSON format
        local nIndentSpaces = 4;
        return luaTableToJson(tFinalizedData, nIndentSpaces);
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.generatePrismScripts
    @vis private
    @desc Collects code language classes and emits the required Prism script dependencies.
    !]]
    generatePrismScripts = function(this, cdat, sHTML)
        -- Define the mapping between language tags and script URLs
        local prismBaseURL = "https://cdnjs.cloudflare.com/ajax/libs/prism/${stable}/components/prism-" % {stable = _sPrismStable};

        -- Set to store found languages to avoid duplicates
        local tFoundLanguages = {};

        -- Pattern to match the code blocks with language tags
        for lang in sHTML:gmatch('class=\\"language%-(%w+)\\"') do
        --for lang in sHTML:gmatch('class="language-lua"') do

            -- Check if the language is supported and add it to the set
            if _tPrismLanguages[lang] then
                tFoundLanguages[_tPrismLanguages[lang]] = true;
            else
                tFoundLanguages[lang] = true;
            end

        end

        -- Generate the script tags
        local scripts = {}
        --insert the main prism js script
        table.insert(scripts, '<script src="https://cdnjs.cloudflare.com/ajax/libs/prism/${stable}/prism.min.js"></script>' % {stable = _sPrismStable});

        --insert the js toolbar script
        table.insert(scripts, '<script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/prism/${stable}/plugins/toolbar/prism-toolbar.js"></script>' % {stable = _sPrismStable});

        --insert the various languages
        for lang, _ in pairs(tFoundLanguages) do
            table.insert(scripts, string.format('<script src="%s%s.min.js"></script>', prismBaseURL, lang))
        end

        return table.concat(scripts, "\n")
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.prepJSONString
    @vis private
    @desc Escapes documentation strings for embedding in the generated script.
    !]]
    prepJSONString = function(this, cdat, s)
        if type(s) ~= "string" then
            return ""
        end
        s = s:gsub("\\", "\\\\")
        s = s:gsub('"', '\\"')
        s = s:gsub("\b", "\\b")
        s = s:gsub("\f", "\\f")
        s = s:gsub("\n", "\\n")
        s = s:gsub("\r", "\\r")
        s = s:gsub("\t", "\\t")
        return s:gsub("</", "<\\/");
    end,
},
{--PROTECTED
},
{--PUBLIC
    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Constructor
    @pulsarlua function DoxBuilderHTML
    @desc Initializes HTML content wrappers, the copy control and output defaults.
    !]]
    DoxBuilderHTML = function(this, cdat, super)
        local sCopyToClipBoardButton = '<button class="copy-to-clipboard-button" onclick="Dox.copyToClipboard(this)">Copy</button>';
        local pro = cdat.pro;

        pro.blockWrapper.open       = '<div class="container-fluid">';
        pro.blockWrapper.close      = '</div>';

        local tColumnWrappers = {
            ["Parameter(s)"] = {
                [1] = {"<strong><em>", "</em></strong>"},
                [2] = {"<em>", "</em>"},
            },
            ["Field(s)"] = {
                [1] = {"<strong><em>", "</em></strong>"},
                [2] = {"<em>", "</em>"},
            },
            ["Field(s) - Private"] = {
                [1] = {"<strong><em>", "</em></strong>"},
                [2] = {"<em>", "</em>"},
            },
            ["Field(s) - Protected"] = {
                [1] = {"<strong><em>", "</em></strong>"},
                [2] = {"<em>", "</em>"},
            },
            ["Field(s) - Public"] = {
                [1] = {"<strong><em>", "</em></strong>"},
                [2] = {"<em>", "</em>"},
            },
            ["Field(s) - Static Private"] = {
                [1] = {"<strong><em>", "</em></strong>"},
                [2] = {"<em>", "</em>"},
            },
            ["Field(s) - Static Public"] = {
                [1] = {"<strong><em>", "</em></strong>"},
                [2] = {"<em>", "</em>"},
            },
            ["Return(s)"] = {
                [1] = {"<strong><em>", "</em></strong>"},
                [2] = {"<em>", "</em>"},
            },
            ["Code"] = {
                [1] = {"<pre>", "</pre>"},
            },
            ["Example"] = { -- Parser-specific wrappers are supplied by getExampleWrapper.
                [1] = {"<pre><code class=\"language-lua\">", "</code></pre>"},
            },
        };

        super("DoxBuilderHTML", DoxBuilder.MIME.HTML, sCopyToClipBoardButton, _sDefaultFilename, "<br>", tColumnWrappers);

    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.build
    @pulsarlua function DoxBuilderHTML.build
    @desc Builds the HTML page with its stylesheet, documentation data, navigation and required Prism scripts.
    @param Dox.PRISM ePrismTheme Optional code theme; defaults to Okaidia and is used only for this build.
    @param string sBannerURL Optional image URL. Failed images show a notice while preserving the normal header.
    @param Dox.THEME ePageTheme Optional page palette; defaults to Midnight Blue and does not affect Prism.
    !]]
    build = function(this, cdat, sTitle, sIntro, tFinalizedData, ePrismTheme, sBannerURL, ePageTheme)
        type.assert.string(sTitle);
        local pri        = cdat.pri;
        local eTheme     = ePrismTheme;

        -- Direct builder calls retain the same default as Dox objects.
        if (eTheme == nil) then
            eTheme = Dox.PRISM.OKAIDIA;
        end

        type.assert.custom(eTheme, "Dox.PRISM");

        local sPrismCSS = '<link href="https://cdnjs.cloudflare.com/ajax/libs/prism/${stable}/themes/${theme}.min.css" rel="stylesheet" />' % {
            stable = _sPrismStable,
            theme  = eTheme.value,
        };

        _sCSS  = LoadDoxAsset(_pRequirePath .. ".CSS");
        _sHTML = LoadDoxAsset(_pRequirePath .. ".HTML");
        _sJS   = LoadDoxAsset(_pRequirePath .. ".JS");

        -- Resolve the page palette for this build, without mutating shared assets.
        local eThemePage = ePageTheme or Dox.THEME.MIDNIGHT_BLUE;

        type.assert.custom(eThemePage, "Dox.THEME");

        local tTheme = _tThemes[eThemePage.value];

        if (not tTheme) then
            error("DoxBuilderHTML: no page palette exists for "..eThemePage.value..".", 2);
        end

        local sPageCSS = _sCSS.."\n"..tTheme.css;

        --update and write the html
        local sHTML = _sHTML % {__DOX__CSS__ = sPageCSS};
        sHTML = sHTML % {
            __DOX__TITLE__          = sTitle,
            __DOX__PRISM_CSS__      = sPrismCSS,
        };

        -- Escape the URL as an attribute; a failed image leaves the normal header visible.
        if (rawtype(sBannerURL) == "string" and sBannerURL ~= "") then
            local sURL = sBannerURL:gsub("&", "&amp;"):gsub('"', "&quot;"):gsub("<", "&lt;"):gsub(">", "&gt;");
            local sBanner = '<div class="dox-banner"><img src="'..sURL..'" alt="Documentation banner" style="display:block;max-width:100%;max-height:220px;margin:0 auto 16px;object-fit:contain" onerror="this.nextElementSibling.hidden=false;this.remove()"><p hidden role="status">Banner image unavailable</p></div>';

            sHTML = sHTML:gsub('(<header id="titlebg">)', function(sHeader)
                return sHeader..sBanner;
            end, 1);
        end

        --inject the javascript
        sHTML = sHTML % {__DOX__INTERNAL_JS__ = pri.buildJS(sIntro, tFinalizedData)};

--print(pri.buildJS("", tFinalizedData))
        --insert the prism scripts for the found languages
        local sPrismScripts = pri.generatePrismScripts(sHTML);
        sHTML = sHTML % {__DOX__PRISM__SCRIPTS__ = sPrismScripts};

        return sHTML;
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.formatBlockContent
    @pulsarlua function DoxBuilderHTML.formatBlockContent
    @desc Formats one documentation item as a content card.
    !]]
    formatBlockContent = function(this, cdat, sID, sDisplay, sContent)
        return [[<div class="custom-section"><div${id} class="section-title">${display}</div><div class="section-content">${content}</div></div>]] % {id = sID, display = sDisplay, content = sContent};
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.formatCombinedBlockContent
    @pulsarlua function DoxBuilderHTML.formatCombinedBlockContent
    @desc Formats repeated documentation items as one content card, with one section ID.
    @param string sID Optional complete HTML ID attribute; a unique ID is generated when omitted.
    !]]
    formatCombinedBlockContent = function(this, cdat, sDisplay, sCombinedContent, sID)
        -- One ID belongs to the combined section rather than each repeated item.
        local sSectionID = sID or ' id="'..string.uuid()..'"';
        return [[<div class="custom-section"><div${id} class="section-title">${display}</div><div class="section-content">${content}</div></div>]] % {id = sSectionID, display = sDisplay, content = sCombinedContent};
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.getExampleWrapper
    @pulsarlua function DoxBuilderHTML.getExampleWrapper
    @desc Returns an example wrapper using the active source parser's Prism language. The language is supplied for each item, avoiding mutable state in shared builders.
    @param Dox.SYNTAX eSyntax The active parser's syntax definition.
    @return table tWrapper Opening and closing HTML strings for the example.
    !]]
    getExampleWrapper = function(this, cdat, eSyntax)
        type.assert.custom(eSyntax, "Dox.SYNTAX");
        local sLanguage = eSyntax.value.getPrismName();

        if (not sLanguage:match("^[%w_%-]+$")) then
            error("Dox example language must be a Prism language identifier.", 2);
        end

        return {
            [1] = '<pre><code class="language-'..sLanguage..'">',
            [2] = '</code></pre>',
        };
    end,


    --[[!
    @fqxn Dox.Builders.DoxBuilderHTML.Methods.refresh
    @pulsarlua function DoxBuilderHTML.refresh
    @desc Builds the hierarchical documentation data and applies inherited documentation.
    !]]
    refresh = function(this, cdat, tBlocks, fProcessBlockItem)
        local pro = cdat.pro;
        local pub = cdat.pub;

        local tBlockWrapper     = pro.blockWrapper;
        local sBuilderNewLine   = pro.newLine;
        local tInheritDocs      = {};
        local tFinalized        = {};

        --inject all block strings into finalized data table
        for _, oBlock in pairs(tBlocks) do
            local tActive = tFinalized;

            for bLastItem, nFQXNIndex, sFQXN in oBlock.fqxn() do --bLastItem is a boolean? Don't think so

                --create the active table if it doesn't exist
                if not (tActive[sFQXN]) then
                    tActive[sFQXN] = setmetatable({}, {
                        __call = function(t)
                            return "";
                        end,
                    });
                end

                --update the active table variable
                tActive = tActive[sFQXN];
            end

            --local tCombinedBlockItems   = {};
            local tToCombine = {};

            --check for and concat combineable items
            for oBlockTag, sRawInnerContent in oBlock.eachItem() do

                if not (oBlockTag.isUtil()) then
                    local bIsCombined = oBlockTag.isCombined();

                    if (bIsCombined) then
                        local sDisplay  = oBlockTag.getDisplay();

                        --create the blocktag index if it doesn't exist
                        if (tToCombine[sDisplay] == nil) then
                            tToCombine[sDisplay] = {};
                        end

                        --append the item to be combined
                        tToCombine[sDisplay][#tToCombine[sDisplay] + 1] = fProcessBlockItem(oBlockTag, sRawInnerContent);
                    end

                end

            end

            --create the content string
            local sContent = tBlockWrapper.open;
            --keep track of combined items so they don't duplicated
            local tCompletedDisplays = {};

            --build the row (block item)
            for oBlockTag, sRawInnerContent in oBlock.eachItem() do

                if not (oBlockTag.isUtil()) then
                    local sDisplay      = oBlockTag.getDisplay();
                    local sInnerContent = "";

                    --check for inheritdoc
                    if (sDisplay == "Inheritdoc") then
                        --store the table index with the value of the inner content to be processed later
                        tInheritDocs[tActive] = sRawInnerContent;
                    else

                        if not (tCompletedDisplays[sDisplay]) then
                            --process combineable items
                            if (oBlockTag.isCombined()) then
                                local sCombinedContent = "";

                                local nMaxItems = #tToCombine[sDisplay];
                                for nIndex, tBlockItemData in ipairs(tToCombine[sDisplay]) do
                                    local sNewLine = nIndex < nMaxItems and "" or sBuilderNewLine;
                                    sCombinedContent = sCombinedContent..tBlockItemData.content..sNewLine;
                                end

                                sInnerContent = pub.formatCombinedBlockContent(sDisplay, sCombinedContent);

                                --delete the entry since we're done processing this display item
                                tCompletedDisplays[sDisplay] = true;

                            else --process non-combineable items
                                local tBlockItemData = fProcessBlockItem(oBlockTag, sRawInnerContent);
                                sInnerContent = pub.formatBlockContent(tBlockItemData.id, tBlockItemData.display, tBlockItemData.content);
                            end

                            sContent = sContent..sInnerContent;
                        end

                    end

                end

            end

            --set the call to get the content
            setmetatable(tActive, {
                __call = function(t)
                    return sContent..tBlockWrapper.close;
                end,
            });

        end

        -- Resolve dependencies before copying content, regardless of table traversal order.
        local tResolved = {};
        local tResolving = {};
        local resolveInheritance;

        --[[!
        @fqxn Dox.Builders.DoxBuilderHTML.Functions.resolveInheritance
        @vis local
        @desc Resolves an inherited documentation chain, rejects missing targets and cycles, and caches each completed node's content.
        @param table tTarget The finalized documentation node to resolve.
        @return string sContent The resolved documentation HTML.
        !]]
        resolveInheritance = function(tTarget)
            if (tResolved[tTarget] ~= nil) then
                return tResolved[tTarget];
            end

            local sLink = tInheritDocs[tTarget];

            if (sLink == nil) then
                return tTarget();
            end

            if (tResolving[tTarget]) then
                error("Circular documentation inheritance detected at target: "..sLink, 2);
            end

            tResolving[tTarget] = true;
            local tSource = tFinalized;

            for _, sPart in ipairs(string.totable(sLink, '.')) do
                if (tSource[sPart] == nil) then
                    error("Inherited documentation target does not exist: "..sLink.." (missing "..sPart..")", 2);
                end

                tSource = tSource[sPart];
            end

            local sContent = resolveInheritance(tSource);
            tResolving[tTarget] = nil;
            tResolved[tTarget] = sContent;

            return sContent;
        end;

        -- Validate the complete graph before replacing any inherited content.
        for tTarget in pairs(tInheritDocs) do
            resolveInheritance(tTarget);
        end

        for tTarget in pairs(tInheritDocs) do
            local sContent = tResolved[tTarget];

            setmetatable(tTarget, {
                __call = function()
                    return sContent;
                end,
            });
        end

        return tFinalized;
    end,
},
DoxBuilder, --extending class
false,      --if the class is final
nil         --interface(s) (either nil, or interface(s))
);
