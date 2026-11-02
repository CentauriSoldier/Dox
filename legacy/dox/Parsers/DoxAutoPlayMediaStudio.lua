local Dox       = Dox;
local DoxMime   = DoxMime;
local class     = class;
local type      = type;


return class("DoxAutoPlayMediaStudio",
{--metamethods

},
{--static public

},
{--private
    unescapeHTMLEntities = function(this, cdat, sInput)
    local tEntities = {
        ["&quot;"] = '"',
        ["&apos;"] = "'",
        ["&lt;"]   = "<",
        ["&gt;"]   = ">",
        ["&amp;"]  = "&"
    };

    return (sInput:gsub("(&%a+%;)", tEntities));
end
},
{--protected

},
{--public
    DoxAutoPlayMediaStudio = function(this, cdat, super, sTitle)
        type.assert.string(sTitle, "%S+", "Dox documentation title name must not be blank.");
        local eSyntax = Dox.SYNTAX.LUA;
        local tMimeTypes = {
            DoxMime("lua"),
            DoxMime("autoplay", cdat.pri.unescapeHTMLEntities),
        };
        super("DoxAutoPlayMediaStudio", sTitle, "!", "!", "@", eSyntax, tMimeTypes);
    end,
    --TODO ability to get sort order
},
Dox,    --extending class
true,   --if the class is final
nil     --interface(s) (either nil, an interface or a numerically-indexed table of interfaces)
);
