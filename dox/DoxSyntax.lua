local class = class;
local type  = type;




--[[
    @module Dox
    @name DoxLanguage
]]
return class("DoxSyntax",
{--metamethods

},
{--static public

},
{--private
    name            = "",
    commentOpen     = "",
    commentClose    = "",
    escapeCharacter = "",
    prismName       = "",
},
{--protected

},
{--public
    DoxSyntax = function(this, cdat, sName, sCommentOpen, sCommentClose, sEscapeCharacter, sPrismName)
        type.assert.string(sName,               "%S+");
        type.assert.string(sCommentOpen,        "%S+");
        type.assert.string(sCommentClose,       "[^\n]+");
        type.assert.string(sEscapeCharacter,    "%S+");
        type.assert.string(sPrismName,          "%S+");

        local pri           = cdat.pri;
        pri.name            = sName;

        pri.commentOpen     = sCommentOpen;
        pri.commentClose    = sCommentClose;
        pri.escapeCharacter = sEscapeCharacter;
        pri.prismName       = sPrismName;
    end,
    getCommentClose = function(this, cdat)
        return cdat.pri.commentClose;
    end,
    getCommentOpen = function(this, cdat)
        return cdat.pri.commentOpen;
    end,
    getEscapeCharater = function(this, cdat)
        return cdat.pri.escapeCharacter;
    end,
    getName = function(this, cdat)
        return cdat.pri.name;
    end,
    getPrismName = function(this, cdat)
        return cdat.pri.prismName;
    end,
},
nil,    --extending class
true,   --if the class is final
nil    --interface(s) (either nil, or interface(s))
);
