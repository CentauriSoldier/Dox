local DoxBuilder = DoxBuilder;
local class      = class;
local error      = error;
local ipairs     = ipairs;
local next       = next;
local pairs      = pairs;
local require    = require;
local string     = string;
local table      = table;
local type       = type;


local _pModules = "dox.Builders.Pulsar.Lua";
local _tJSON    = require(_pModules..".JSON");
local _tPackage = require(_pModules..".PulsarPackage");

local definition;
local insert;
local normalizeName;
local prepareBlock;


--[[!
@fqxn Dox.Builders.PulsarLua.Functions.definition
@desc Maps documented Lua primitive types or references to named documentation types. Ambiguous union types remain unknown.
@param string sType Documented type.
@return table tDefinition Provider type definition.
!]]
definition = function(sType)
    local tPrimitive = {boolean = true, ["function"] = true, number = true, string = true, table = true, unknown = true};

    if (tPrimitive[sType]) then
        local tDefinition = {type = sType};

        if (sType == "table") then
            tDefinition.fields = {};
        end

        return tDefinition;
    end

    if (sType and sType:match("^[%a_][%w_%.]*$")) then
        return {type = "ref", name = sType};
    end

    return {type = "unknown"};
end;


--[[!
@fqxn Dox.Builders.PulsarLua.Functions.insert
@desc Inserts a dotted name into nested provider tables, preserving existing children. Callable classes retain their table members.
@param table tRoot Global environment definition.
@param string sName Dotted name.
@param table tDefinition Documentation definition.
@return table tNode Inserted node.
!]]
insert = function(tRoot, sName, tDefinition)
    local tNode = tRoot;
    local tParts = {};

    for sPart in sName:gmatch("[^%.]+") do
        tParts[#tParts + 1] = sPart;
    end

    for _, sPart in ipairs(tParts) do
        tNode.fields = tNode.fields or {};
        tNode.fields[sPart] = tNode.fields[sPart] or {type = "table", fields = {}};
        tNode = tNode.fields[sPart];
    end

    for sKey, vValue in pairs(tDefinition) do
        if (sKey ~= "fields") then
            tNode[sKey] = vValue;
        end
    end

    if (tDefinition.fields) then
        tNode.fields = tNode.fields or {};

        for sKey, vValue in pairs(tDefinition.fields) do
            tNode.fields[sKey] = vValue;
        end
    end

    return tNode;
end;


--[[!
@fqxn Dox.Builders.PulsarLua.Functions.normalizeName
@desc Maps the conventional Methods documentation section to its callable owner. Explicit PulsarLua names bypass this convention.
@param string sName Documentation-qualified name.
@return string sName Code-qualified name.
!]]
normalizeName = function(sName)
    return sName:gsub("%.Methods%.", ".");
end;


--[[!
@fqxn Dox.Builders.PulsarLua.Functions.prepareBlock
@desc Converts all documentation entries into provider definitions; honors existing PulsarLua overrides without requiring that tag.
@param DoxBlock oBlock Parsed documentation block.
@return table tEntry Name, type, parameters, returns and field metadata.
!]]
prepareBlock = function(oBlock)
    local tArgs       = _tJSON.array();
    local tArgTypes   = _tJSON.array();
    local tDescriptions = {};
    local tFields     = {};
    local tNames      = {};
    local tReturns    = _tJSON.array();
    local tParameterDocs = {};
    local sExplicit;
    local sInherited;
    local sType;

    for _, _, sPart in oBlock.fqxn() do
        tNames[#tNames + 1] = sPart;
    end

    local sName = table.concat(tNames, ".");
    local sOriginalName = sName;
    local bFunction = sName:find("%.Methods%.") ~= nil or sName:find("%.Functions%.") ~= nil;

    for oTag, sRaw in oBlock.eachItem() do
        local sDisplay = oTag.getDisplay();
        local sText = string.htmltomd(sRaw):trim();

        if (sDisplay == "PulsarLua") then
            sType, sExplicit = sText:match("^(%S+)%s+(%S+)$");

            if (not sType or not sExplicit) then
                error("PulsarLua metadata must contain a type and code name.", 2);
            end
        elseif (sDisplay == "Inheritdoc") then
            sInherited = sText;
        elseif (sDisplay == "Description" or sDisplay == "Summary") then
            tDescriptions[#tDescriptions + 1] = sText;
        elseif (sDisplay == "Parameter(s)") then
            local sArgType, sArgName, sDescription = sText:match("^(%S+)%s+(%S+)%s*(.*)$");

            if (not sArgName) then
                error("Pulsar parameter requires a type and name in "..sName..".", 2);
            end

            bFunction = true;
            tArgs[#tArgs + 1] = {name = sArgName, displayName = sArgName};
            tArgTypes[#tArgTypes + 1] = definition(sArgType);
            tParameterDocs[#tParameterDocs + 1] = sArgName.." ("..sArgType.."): "..sDescription;
        elseif (sDisplay == "Return(s)") then
            local sReturnType = sText:match("^(%S+)");

            bFunction = true;
            tReturns[#tReturns + 1] = definition(sReturnType);
            tParameterDocs[#tParameterDocs + 1] = "Returns: "..sText;
        elseif (sDisplay:find("Field(s)", 1, true) == 1) then
            local sFieldType, sFieldName, sDescription = sText:match("^(%S+)%s+(%S+)%s*(.*)$");

            if (sFieldName) then
                local tField = definition(sFieldType);
                tField.description = sDescription;
                tFields[sFieldName] = tField;
            end
        end
    end

    sName = sExplicit or normalizeName(sName);
    sType = sType or (bFunction and "function" or "table");

    local tDefinition = definition(sType);
    tDefinition.description = table.concat(tDescriptions, "\n\n");

    if (#tParameterDocs > 0) then
        tDefinition.description = tDefinition.description.."\n\n"..table.concat(tParameterDocs, "\n");
    end

    if (sType == "function") then
        local tArgNames = {};

        for _, tArg in ipairs(tArgs) do
            tArgNames[#tArgNames + 1] = tArg.name;
        end

        tDefinition.args = tArgs;
        tDefinition.argTypes = tArgTypes;
        tDefinition.argsDisplay = table.concat(tArgNames, ", ");
        tDefinition.returnTypes = tReturns;
    else
        tDefinition.fields = tFields;
    end

    return {name = sName, sourceName = sOriginalName, inherited = sInherited, definition = tDefinition};
end;


--[[!
@fqxn Dox.Builders.PulsarLua
@desc Builds Lua autocomplete data for every imported Dox entry and project-named Pulsar option-provider packages. No documented source is executed.
!]]
return class("DoxBuilderPulsarLua", {}, {}, {}, {}, {
    --[[!
    @fqxn Dox.Builders.PulsarLua.Constructor
    @pulsarlua function DoxBuilderPulsarLua
    @desc Initializes a JSON completion exporter with no HTML wrappers.
    !]]
    DoxBuilderPulsarLua = function(this, cdat, super)
        super("DoxBuilderPulsarLua", DoxBuilder.MIME.LUACOMPLETERC, "", "completions", "\n", {});
    end,


    --[[!
    @fqxn Dox.Builders.PulsarLua.Methods.build
    @pulsarlua function DoxBuilderPulsarLua.build
    @desc Builds a project-named Pulsar package ZIP using the shared documentation export interface.
    @param string sTitle Documentation project title.
    @param string sIntro Unused HTML introduction.
    @param table tData Prepared completion definitions.
    @return string sZIP Package archive bytes.
    !]]
    build = function(this, cdat, sTitle, sIntro, tData)
        return this.buildPackage(sTitle, tData);
    end,


    --[[!
    @fqxn Dox.Builders.PulsarLua.Methods.buildPackage
    @pulsarlua function DoxBuilderPulsarLua.buildPackage
    @desc Creates a project-named ZIP ready to unpack into Pulsar's packages directory. The installed Lua provider supplies completion UI and inference.
    @param string sTitle Project title used for the package name.
    @param table tData Prepared completion definitions.
    @return string sZIP ZIP bytes.
    @return string sName Generated package directory name.
    !]]
    buildPackage = function(this, cdat, sTitle, tData)
        local sName = sTitle:lower():gsub("[^%w]+", "-"):gsub("^-+", ""):gsub("-+$", "");

        if (sName == "") then
            error("Pulsar package title must contain letters or digits.", 2);
        end

        sName = "dox-"..sName;

        local tManifest = {
            name = sName,
            version = "1.0.0",
            description = "Dox autocomplete definitions for "..sTitle,
            main = "lib/main.js",
            engines = {atom = ">=1.0.0"},
            providedServices = {
                ["autocomplete-lua.options-provider"] = {
                    versions = {["1.0.0"] = "getOptionProvider"},
                },
            },
        };

        return _tPackage.build(sName, _tJSON.encode(tManifest), _tJSON.encode(tData)), sName;
    end,


    --[[!
    @fqxn Dox.Builders.PulsarLua.Methods.formatBlockContent
    @pulsarlua function DoxBuilderPulsarLua.formatBlockContent
    @desc Returns unwrapped text for compatibility with the shared builder interface.
    !]]
    formatBlockContent = function(this, cdat, sID, sDisplay, sContent)
        return sContent;
    end,


    --[[!
    @fqxn Dox.Builders.PulsarLua.Methods.formatCombinedBlockContent
    @pulsarlua function DoxBuilderPulsarLua.formatCombinedBlockContent
    @desc Returns unwrapped combined content for compatibility with the shared builder interface.
    !]]
    formatCombinedBlockContent = function(this, cdat, sDisplay, sContent)
        return sContent;
    end,


    --[[!
    @fqxn Dox.Builders.PulsarLua.Methods.refresh
    @pulsarlua function DoxBuilderPulsarLua.refresh
    @desc Includes all blocks in a nested Lua provider hierarchy, retaining argument order and documented enum fields. Explicit PulsarLua names take precedence.
    @param table tBlocks Imported Dox blocks.
    @param function fProcessBlockItem Shared formatter, unused because provider data consumes raw tags.
    @return table tData Provider options.
    !]]
    refresh = function(this, cdat, tBlocks, fProcessBlockItem)
        local tData = {global = {type = "table", fields = {}}, namedTypes = {}};
        local tEntries = {};

        for _, oBlock in ipairs(tBlocks) do
            tEntries[#tEntries + 1] = prepareBlock(oBlock);
        end

        table.sort(tEntries, function(a, b)
            return a.name < b.name;
        end);

        local tByName = {};
        local tResolving = {};
        local tResolved = {};

        for _, tEntry in ipairs(tEntries) do
            tByName[tEntry.sourceName] = tEntry;
            tByName[tEntry.name] = tEntry;
        end

        --[[!
        @fqxn Dox.Builders.PulsarLua.Functions.resolveEntry
        @desc Resolves inherited completion metadata before insertion; rejects missing targets and cycles without producing partial output.
        @param table tEntry Prepared documentation entry.
        @return table tDefinition Resolved completion metadata.
        !]]
        local function resolveEntry(tEntry)
            if (tResolved[tEntry]) then
                return tResolved[tEntry];
            end

            if (tResolving[tEntry]) then
                error("Circular Pulsar documentation inheritance: "..tEntry.sourceName, 2);
            end

            tResolving[tEntry] = true;

            if (tEntry.inherited) then
                local tParent = tByName[tEntry.inherited];

                if (not tParent) then
                    error("Missing Pulsar documentation inheritance target: "..tEntry.inherited, 2);
                end

                tEntry.definition = resolveEntry(tParent);
            end

            tResolving[tEntry] = nil;
            tResolved[tEntry] = tEntry.definition;

            return tEntry.definition;
        end

        for _, tEntry in ipairs(tEntries) do
            resolveEntry(tEntry);
        end

        for _, tEntry in ipairs(tEntries) do
            local tNode = insert(tData.global, tEntry.name, tEntry.definition);
            tData.namedTypes[tEntry.name] = tNode;
        end

        -- The provider indexes only tables. Preserve callable metadata on the
        -- owner and in its call metatable while keeping its public fields visible.
        --[[!
        @fqxn Dox.Builders.PulsarLua.Functions.normalizeCallable
        @desc Represents definitions containing both a call signature and members as provider tables. Retains constructor arguments and return metadata; the provider can resolve their fields and call results.
        @param table tNode Definition tree to normalize.
        !]]
        local function normalizeCallable(tNode)
            for _, tChild in pairs(tNode.fields or {}) do
                normalizeCallable(tChild);
            end

            if (tNode.type == "function" and next(tNode.fields or {})) then
                local tCall = {};

                for sKey, vValue in pairs(tNode) do
                    if (sKey ~= "fields") then
                        tCall[sKey] = vValue;
                    end
                end

                tNode.type = "table";
                tNode.metatable = {type = "table", fields = {__call = tCall}};
                tNode.description = (tNode.description or "").."\n\nConstructor: ("..(tNode.argsDisplay or "")..").";
            end
        end


        normalizeCallable(tData.global);

        -- Callable table return slots are read directly by this provider rather
        -- than revived as function slots. Supply a finite instance shape there.
        --[[!
        @fqxn Dox.Builders.PulsarLua.Functions.resolveCallReturns
        @desc Expands documented named table returns on callable owners into instance field shapes so the provider can infer members after a constructor call. Missing return documentation is never invented.
        @param table tNode Definition tree containing callable tables.
        !]]
        local function resolveCallReturns(tNode)
            for _, tChild in pairs(tNode.fields or {}) do
                resolveCallReturns(tChild);
            end

            if (tNode.metatable and tNode.metatable.fields.__call) then
                for nIndex, tReturn in ipairs(tNode.returnTypes or {}) do
                    local tNamed = tReturn.type == "ref" and tData.namedTypes[tReturn.name];

                    if (tNamed and tNamed.type == "table") then
                        tNode.returnTypes[nIndex] = {type = "table", fields = tNamed.fields or {}};
                    end
                end
            end
        end


        -- Unresolved custom types are explicitly unknown rather than broken references.
        --[[!
        @fqxn Dox.Builders.PulsarLua.Functions.resolveTypes
        @desc Replaces references to undocumented types with explicit unknown definitions, preserving documented references for the provider to revive.
        @param table tNode Completion definition to validate recursively.
        !]]
        local function resolveTypes(tNode)
            if (tNode.type == "ref" and not tData.namedTypes[tNode.name]) then
                tNode.type = "unknown";
                tNode.name = nil;
            end

            for _, tChild in pairs(tNode.fields or {}) do
                resolveTypes(tChild);
            end

            if (tNode.metatable) then
                resolveTypes(tNode.metatable);
            end

            for _, tArg in ipairs(tNode.argTypes or {}) do
                resolveTypes(tArg);
            end

            for _, tReturn in ipairs(tNode.returnTypes or {}) do
                resolveTypes(tReturn);
            end
        end

        resolveTypes(tData.global);
        resolveCallReturns(tData.global);

        return tData;
    end,
}, DoxBuilder, true);
