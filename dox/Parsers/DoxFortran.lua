local Dox       = Dox;
local DoxMime   = DoxMime;
local class     = class;
local type      = type;


return class("DoxFortran",
{--metamethods

},
{--static public

},
{--private

},
{--protected

},
{--public
    DoxFortran = function(this, cdat, super, sTitle)
        type.assert.string(sTitle, "%S+", "Dox Parser title name must not be blank.");
        local eSyntax = Dox.SYNTAX.FORTRAN;
        local tMimeTypes = {
            DoxMime("f90"), -- Assuming "f90" as an example mime type
        };

        super("DoxFortran", sTitle, "!", "!", "@", eSyntax, tMimeTypes);
    end,
    --TODO ability to get sort order
},
Dox,    --extending class
true,   --if the class is final
nil     --interface(s) (either nil, an interface or a numerically-indexed table of interfaces)
);
