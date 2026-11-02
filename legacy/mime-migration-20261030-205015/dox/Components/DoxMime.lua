local class = class;
local error = error;
local type  = type;


return class("DoxMime",
{--METAMETHODS

},
{--STATIC PUBLIC

},
{--PRIVATE
    name         = "",
    preProcessor = null,
},
{--PROTECTED

},
{--PUBLIC
    --[[!
    @fqxn Dox.Components.DoxMime.Methods.DoxMime
    @pulsarlua function DoxMime
    @desc Creates a file-extension mapping and optional documentation preprocessor.
    @param string sName File extension, optionally starting with a dot.
    @param function|nil fPreProcessor Converts raw documentation text; nil preserves it.
    !]]
    DoxMime = function(this, cdat, sName, fPreProcessor)
        type.assert.string(sName, "%S+");
        local pri = cdat.pri;
        local sExtension = sName:gsub("^%.", ""):lower();

        -- Match file extensions without accepting empty names or embedded whitespace.
        if (sExtension == "" or sExtension:find("%s") or sExtension:find("[/\\.]")) then
            error("DoxMime requires a single non-blank file extension.", 2);
        end

        if (fPreProcessor ~= nil and type(fPreProcessor) ~= "function") then
            error("DoxMime preprocessor must be a function or nil.", 2);
        end

        pri.name = sExtension;
        pri.preProcessor = fPreProcessor or function(sInput)
            return sInput;
        end;
    end,


    --[[!
    @fqxn Dox.Components.DoxMime.Methods.getName
    @pulsarlua function DoxMime.getName
    @desc Returns the normalized lowercase file extension.
    @return string sName The extension without a leading dot.
    !]]
    getName = function(this, cdat)
        return cdat.pri.name;
    end,


    --[[!
    @fqxn Dox.Components.DoxMime.Methods.getPreProcessor
    @pulsarlua function DoxMime.getPreProcessor
    @desc Returns the documentation preprocessor.
    @return function fPreProcessor The preprocessing function.
    !]]
    getPreProcessor = function(this, cdat)
        return cdat.pri.preProcessor;
    end,


    --[[!
    @fqxn Dox.Components.DoxMime.Methods.setPreProcessor
    @pulsarlua function DoxMime.setPreProcessor
    @desc Replaces the documentation preprocessor.
    @param function fPreProcessor The new preprocessing function.
    !]]
    setPreProcessor = function(this, cdat, fPreProcessor)
        type.assert["function"](fPreProcessor);
        cdat.pri.preProcessor = fPreProcessor;
    end,
},
nil,   --extending class
false, --if the class is final
nil    --interface(s) (either nil, or interface(s))
);
