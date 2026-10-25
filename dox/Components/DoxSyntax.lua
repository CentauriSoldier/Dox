local class = class;
local type  = type;




--[[!
@fqxn Dox.Components.DoxSyntax
@desc Defines source-language comment delimiters, documentation escaping and Prism highlighting names.
!]]
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
    --[[!
    @fqxn Dox.Components.DoxSyntax.Methods.DoxSyntax
    @pulsarlua function DoxSyntax
    @desc Creates a source-language syntax definition.
    !]]
    DoxSyntax = function(this, cdat, sName, sCommentOpen, sCommentClose, sEscapeCharacter, sPrismName)
        type.assert.string(sName,               "%S+");
        type.assert.string(sCommentOpen,        "%S+");
        type.assert.string(sCommentClose);

        -- A newline is a valid terminator for line-based source comments.
        if (sCommentClose == "") then
            error("DoxSyntax closing delimiter cannot be empty.", 2);
        end
        type.assert.string(sEscapeCharacter,    "%S+");
        type.assert.string(sPrismName,          "%S+");

        local pri           = cdat.pri;
        pri.name            = sName;

        pri.commentOpen     = sCommentOpen;
        pri.commentClose    = sCommentClose;
        pri.escapeCharacter = sEscapeCharacter;
        pri.prismName       = sPrismName;
    end,


    --[[!
    @fqxn Dox.Components.DoxSyntax.Methods.getCommentClose
    @pulsarlua function DoxSyntax.getCommentClose
    @desc Returns the closing source-comment delimiter.
    !]]
    getCommentClose = function(this, cdat)
        return cdat.pri.commentClose;
    end,


    --[[!
    @fqxn Dox.Components.DoxSyntax.Methods.getCommentOpen
    @pulsarlua function DoxSyntax.getCommentOpen
    @desc Returns the opening source-comment delimiter.
    !]]
    getCommentOpen = function(this, cdat)
        return cdat.pri.commentOpen;
    end,


    --[[!
    @fqxn Dox.Components.DoxSyntax.Methods.getEscapeCharacter
    @pulsarlua function DoxSyntax.getEscapeCharacter
    @desc Returns the documentation escape character.
    !]]
    getEscapeCharacter = function(this, cdat)
        return cdat.pri.escapeCharacter;
    end,


    --[[!
    @fqxn Dox.Components.DoxSyntax.Methods.getEscapeCharater
    @pulsarlua function DoxSyntax.getEscapeCharater
    @desc Retains the original spelling for compatibility; use getEscapeCharacter in new code.
    !]]
    getEscapeCharater = function(this, cdat)
        return cdat.pri.escapeCharacter;
    end,


    --[[!
    @fqxn Dox.Components.DoxSyntax.Methods.getName
    @pulsarlua function DoxSyntax.getName
    @desc Returns the language display name.
    !]]
    getName = function(this, cdat)
        return cdat.pri.name;
    end,


    --[[!
    @fqxn Dox.Components.DoxSyntax.Methods.getPrismName
    @pulsarlua function DoxSyntax.getPrismName
    @desc Returns the Prism syntax-highlighting language name.
    !]]
    getPrismName = function(this, cdat)
        return cdat.pri.prismName;
    end,
},
nil,    --extending class
true,   --if the class is final
nil    --interface(s) (either nil, or interface(s))
);
