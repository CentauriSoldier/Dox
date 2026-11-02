local Dox       = Dox;
local DoxMime   = DoxMime;
local class     = class;
local type      = type;


return class("DoxCPlusPlus",
{--metamethods

},
{--static public

},
{--private

},
{--protected

},
{--public
    DoxCPlusPlus = function(this, cdat, super, sTitle)
        type.assert.string(sTitle, "%S+", "Dox Parser title name must not be blank.");
        local eSyntax = Dox.SYNTAX.C_PLUS_PLUS;
        local tMimeTypes = {
            DoxMime("cpp"),
            DoxMime("cxx"), -- Adding "cxx" as an example mime type
        };

        super("DoxCPlusPlus", sTitle, "!", "!", "@", eSyntax, tMimeTypes);
    end,
    --TODO ability to get sort order
},
Dox,    --extending class
true,   --if the class is final
nil     --interface(s) (either nil, an interface, or a numerically-indexed table of interfaces)
);
