local Dox       = Dox;
local DoxMime   = DoxMime;
local class     = class;
local type      = type;


return class("DoxHTML",
{--metamethods

},
{--static public

},
{--private
--TODO probably needs a preprocessor
},
{--protected

},
{--public
    DoxHTML = function(this, cdat, super, sTitle)
        type.assert.string(sTitle, "%S+", "Dox Parser title name must not be blank.");
        local eSyntax = Dox.SYNTAX.HTML;
        local tMimeTypes = {
            DoxMime("html"),
            DoxMime("htm"), -- Adding "htm" as an example mime type
        };

        super("DoxHTML", sTitle, "!", "!", "@", eSyntax, tMimeTypes);
    end,
    --TODO ability to get sort order
},
Dox,    --extending class
true,   --if the class is final
nil     --interface(s) (either nil, an interface or a numerically-indexed table of interfaces)
);
