local ipairs  = ipairs;
local string  = string;
local table   = table;


local crc32;


--[[!
@fqxn Dox.Builders.PulsarLua.Package.crc32
@desc Calculates the ZIP checksum for stored file bytes. Uses Lua 5.3 or later integer bit operations.
@param string sBytes File content.
@return number nCRC Unsigned CRC-32.
!]]
crc32 = function(sBytes)
    local nCRC = 0xffffffff;

    for nIndex = 1, #sBytes do
        nCRC = nCRC ~ string.byte(sBytes, nIndex);

        for nBit = 1, 8 do
            if ((nCRC & 1) ~= 0) then
                nCRC = (nCRC >> 1) ~ 0xedb88320;
            else
                nCRC = nCRC >> 1;
            end
        end
    end

    return (~nCRC) & 0xffffffff;
end;


return {
    --[[!
    @fqxn Dox.Builders.PulsarLua.Package.build
    @desc Creates a dependency-free stored ZIP containing a project-named Pulsar package. It does not install or modify editor packages.
    @param string sName Filesafe package directory name.
    @param string sManifest Package manifest JSON.
    @param string sData Completion data JSON.
    @return string sArchive Binary ZIP bytes.
    !]]
    build = function(sName, sManifest, sData)
        local sMain = [[
'use strict';
const data = require('./completions.json');

// Pulsar's Lua provider performs parsing, type inference and display.
// Revive a separate data graph for each options utility so providers do not share mutable state.
module.exports = {
  getOptionProvider() {
    const instances = new WeakMap();
    return {
      priority: 200,
      async getOptions(request, getPreviousOptions, utils, cache = {}) {
        let options = instances.get(utils);
        if (!options) {
          options = utils.reviveOptions(JSON.parse(JSON.stringify(data)));
          instances.set(utils, options);
        }
        const previous = await getPreviousOptions();
        const result = utils.mergeOptionsCached(previous, options, cache);
                const visited = new WeakSet();

                // The provider clones call signatures through the metatable but
                // reads call results directly from their owner during inference.
                const restoreCalls = node => {
                    if (!node || typeof node !== 'object' || visited.has(node)) return;
                    visited.add(node);

                    const call = node.metatable?.fields?.__call;
                    if (call) node.returnTypes = call.returnTypes;

                    for (const child of Object.values(node.fields || {})) {
                        restoreCalls(child);
                    }
                };

                restoreCalls(result.options.global);
                return result;
      },
      dispose() {}
    };
  }
};
]];
        local sReadme = "# "..sName.."\n\nGenerated from Dox comments.\n\n"..
            "Install: unpack this archive into your Pulsar packages directory, preserving the package folder, then reload Pulsar. "..
            "Enable autocomplete-lua or autocomplete-luaex; this package supplies their documented options-provider service.\n\n"..
            "Includes documented names, descriptions, arguments, returns and fields. Types not documented remain unknown; no source code is executed to infer them.\n";
        local tFiles = {
            {"README.md", sReadme},
            {"completions.json", sData},
            {"lib/main.js", sMain:gsub("'./completions.json'", "'../completions.json'")},
            {"package.json", sManifest},
        };
        local tCentral = {};
        local tLocal   = {};
        local nOffset  = 0;

        for _, tFile in ipairs(tFiles) do
            local sPath = sName.."/"..tFile[1];
            local sData = tFile[2];
            local nCRC  = crc32(sData);
            local sHeader = string.pack("<I4I2I2I2I2I2I4I4I4I2I2", 0x04034b50, 20, 2048, 0, 0, 33, nCRC, #sData, #sData, #sPath, 0);

            tLocal[#tLocal + 1] = sHeader..sPath..sData;
            tCentral[#tCentral + 1] = string.pack("<I4I2I2I2I2I2I2I4I4I4I2I2I2I2I2I4I4", 0x02014b50, 20, 20, 2048, 0, 0, 33, nCRC, #sData, #sData, #sPath, 0, 0, 0, 0, 0, nOffset)..sPath;
            nOffset = nOffset + #sHeader + #sPath + #sData;
        end

        local sCentral = table.concat(tCentral);
        local sEnd = string.pack("<I4I2I2I2I2I4I4I2", 0x06054b50, 0, 0, #tFiles, #tFiles, #sCentral, nOffset, 0);

        return table.concat(tLocal)..sCentral..sEnd;
    end,
};
