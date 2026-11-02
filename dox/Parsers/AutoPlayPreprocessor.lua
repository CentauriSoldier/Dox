-- A fresh ordinary Lua callback per parser, compatible with host persistence.
return function()
    return function(sInput)
        local tEntities = {
            ["&quot;"] = '"',
            ["&apos;"] = "'",
            ["&lt;"]   = "<",
            ["&gt;"]   = ">",
            ["&amp;"]  = "&"
        };

        return (sInput:gsub("(&%a+%;)", tEntities));
    end;
end;
