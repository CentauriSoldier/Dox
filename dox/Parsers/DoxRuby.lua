local Dox       = Dox;
local DoxMime   = DoxMime;
local class     = class;
local type      = type;


return class("DoxRuby",
{--metamethods

},
{--static public

},
{--private

},
{--protected

},
{--public
    DoxRuby = function(this, cdat, super, sTitle)
        type.assert.string(sTitle, "%S+", "Dox Parser title name must not be blank.");
        local eSyntax = Dox.SYNTAX.RUBY;
        local tMimeTypes = {
            DoxMime("rb"),
        };

        super("DoxRuby", sTitle, "!", "!", "@", eSyntax, tMimeTypes);
    end,
    --TODO ability to get sort order
},
Dox,    --extending class
true,   --if the class is final
nil     --interface(s) (either nil, an interface, or a numerically-indexed table of interfaces)
);
