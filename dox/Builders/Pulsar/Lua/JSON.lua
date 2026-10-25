local error        = error;
local getmetatable = getmetatable;
local ipairs       = ipairs;
local pairs        = pairs;
local rawtype      = rawtype;
local setmetatable = setmetatable;
local string       = string;
local table        = table;
local tostring     = tostring;


local encode;
local escape;


--[[!
@fqxn Dox.Builders.PulsarLua.JSON.encode
@desc Encodes completion data as deterministic JSON. Explicit array markers preserve empty argument lists; unsupported values are rejected.
@param any vValue A scalar or acyclic completion table.
@return string sJSON Encoded JSON.
!]]
encode = function(vValue)
    local sType = rawtype(vValue);

    if (sType == "string") then
        return escape(vValue);
    elseif (sType == "boolean" or sType == "number") then
        return tostring(vValue);
    elseif (sType ~= "table") then
        error("Pulsar JSON cannot encode "..sType..".", 2);
    end

    local tParts = {};
    local tMeta  = getmetatable(vValue);

    if (tMeta and tMeta.array) then
        for _, vItem in ipairs(vValue) do
            tParts[#tParts + 1] = encode(vItem);
        end

        return "["..table.concat(tParts, ",").."]";
    end

    local tKeys = {};

    for sKey in pairs(vValue) do
        if (rawtype(sKey) ~= "string") then
            error("Pulsar JSON object keys must be strings.", 2);
        end

        tKeys[#tKeys + 1] = sKey;
    end

    table.sort(tKeys);

    for _, sKey in ipairs(tKeys) do
        tParts[#tParts + 1] = escape(sKey)..":"..encode(vValue[sKey]);
    end

    return "{"..table.concat(tParts, ",").."}";
end;


--[[!
@fqxn Dox.Builders.PulsarLua.JSON.escape
@desc Escapes quotes, backslashes and control bytes without changing Unicode text.
@param string sText Text to encode.
@return string sJSON A quoted JSON string.
!]]
escape = function(sText)
    local sEscaped = sText:gsub('[%z\1-\31\\"]', function(sCharacter)
        if (sCharacter == '"' or sCharacter == "\\") then
            return "\\"..sCharacter;
        end

        return string.format("\\u%04x", string.byte(sCharacter));
    end);

    return '"'..sEscaped..'"';
end;


return {
    --[[!
    @fqxn Dox.Builders.PulsarLua.JSON.array
    @desc Marks a numerically indexed list for JSON array output, including empty lists.
    @param table|nil tItems Optional list.
    @return table tArray Marked array.
    !]]
    array = function(tItems)
        return setmetatable(tItems or {}, {array = true});
    end,
    encode = encode,
};
