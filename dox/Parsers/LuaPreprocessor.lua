-- A fresh ordinary Lua callback per parser, compatible with host persistence.
return function()
    return function(docString)
        -- Define a table to hold the escaped Lua special items and their unescaped counterparts
        local escapeMap = {
            ["\\%["] = "[",
            ["\\%]"] = "]",
            --["\\%("] = "(",
            --["\\%)"] = ")",
            --["\\%."] = ".",
            --["\\%%"] = "%",
            --["\\%+"] = "+",
            --["\\%-"] = "-",
            --["\\%*"] = "*",
            --["\\%?"] = "?",
            --["\\%^"] = "^",
            --["\\%$"] = "$",
            --["\\%("] = "(",
            --["\\%)"] = ")",
            --["\\%{"] = "{",
            --["\\%}"] = "}",
            --["\\%|"] = "|",
            --["\\%_"] = "_",
            --["\\%/"] = "/",
            --["\\%\\"] = "\\"
        }

        -- Iterate over the escapeMap and replace escaped items in the docString
        for escaped, unescaped in pairs(escapeMap) do
            docString = docString:gsub(escaped, unescaped)
        end

        return docString
    end;
end;
