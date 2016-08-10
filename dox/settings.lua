--the 'iterateChar()', 'tab()' and all other util functions are available here.

--DO NOT ALTER THESE OR THE OUTPUT WILL NOT WORK CORRECTLY
dox.CriticalFolders = {
	"dox",
	"modules",	
};
--_THIS MAY NEED  TO BE DELETED SINCE WE"RE NOW ALLOWING HTML
dox.EscapeChars = {
	[1] = { --& must come first in the sequence to prevent unwelcome, interative replacement
		Old = "&",
		New = "&amp;",			
	},
	[2] = {
		Old = "\\>",
		New = "&gt;",
	},
	[3] = {
		Old = "\\<",
		New = "&lt;",
	},
};

--the 'IGNORE' text is removed at the end of this file.
dox.Markers = {
	Block = {
		Start = "--IGNORE[[!",
		End = "IGNORE!]]",
	},
	Module = {
		Start = "--[[IGNORE*",
		End = "*IGNORE]]",
	},	
	Line = {
		Start = "<",
		End = ">",
	},
};

-- the module info id/name delimiters
dox.ModuleDelimiter = ",";
dox.ModuleInfoNameDelimiter = "|";

dox.ModuleItems = {
	authors = {
		Display = "",
		IsListItem = false,			
	},
	copyright = {
		Display = "Copyright",
		IsListItem = true,			
	},
	displayname = { --not input by user using this tag. The text for this is found in the moduleid tag.
		Display = "",
		IsListItem = false,			
	},
	dependencies = {
		Display = "Dependencies",
		IsListItem = true,			
	},
	description = {
		Display = "Description",
		IsListItem = true,			
	},		
	features = {
		Display = "Features",
		IsListItem = true,			
	},
	email = {
		Display = "Email",
		IsListItem = true,
	},
	license = {
		Display = "License",
		IsListItem = true,
	},		
	moduleid = { --IGNORED
		Display = "IGNORED",
		IsListItem = false, --IGNORED
	},
	plannedfeatures = {
		Display = "Planned Features",
		IsListItem = true,
	},
	todo = {
		Display = "Todo",
		IsListItem = true,
	},
	usage = {
		Display = "Usage",
		IsListItem = true,
	},
	version = {
		Display = "Current Version",
		IsListItem = false,
	},
	versionhistory = {
		Display = "Version History",
		IsListItem = true,
	},
	website = {
		Display = "Website",
		IsListItem = false,
	},		
};

--this is where all the html-ready blocks of code wait to be processed
dox.Modules = {};

dox.PageVars = {
	Author = "Centauri Soldier https://github.com/CentauriSoldier",
	Body = "",
	CSS = "",--must be blank if 'CSSPathAndVersion' is not
	CSSPathAndVersion = "",--must be blank if 'CSS' is not
	Description = "Lua Module Viewer",
	Title = "Dox Lua Code Viewer",
};

dox.SpecialChars = {
	[1] = { --this is always the line character for blocks of any type(function, module, etc.).
		Intended = "@",	
		Escaped = "\\@",
		Temp = " __!!DOXAT!!__ ",
	},
	[2] = {
		Intended = "&lt;",	
		Escaped = "\\<",
		Temp = " __!!DOXLT!!__ ",
	},
	[3] = {
		Intended = "&gt;",	
		Escaped = "\\>",
		Temp = " __!!DOXGT!!__ ",
	},
};

--[[TODO ADD THIS TO THE USAGE POTION OF THE MODULE INFO SECTION UNDER 'Customization'.
How To Add A Type.
1. Add here and set table variables to those desired.
2. add the value to the 'tRet' table in the 'dox.parse.processBlock()' function in the 'parse.lua' file.
3. Edit the 'dox.html.buildModule()' function in the 'html.dox' file to include the new Type
Note: if no default value is set and there is no value given by the end-user (for a specific function), it will be a blank string
]]

dox.Types = {
	Description = {			
		Variations = {
			"description",
			"desc",
		},
	},
	Example = {
		Variations = {
			"examples",
			"example",
		},
	},
	File = {
		Variations = {
			"file",			
		},
	},
	Function = {
		--MustHaveChars = true, Assumed to be true by 'RequiredType == true'
		RequiredType = true,
		Variations = {
			"function",
			"func",
		},
	},	
	Module = {			
		DefaultValue = "Unknown",
		MustHaveChars = true,
		Variations = {
			"module",
			"mod",
		},
	},
	Parameters = {
		AllowMultiple = true,			
		Parser = {
			[1] = { --variable name example
				StartTag = '<span class="parameterinput">',
				EndTag = "</span>",
			},
			[2] = { --variable type
				StartTag = '<span class="parametertype">',
				EndTag = "</span>",
			},
			[3] = { --description/notes
				StartTag = '<span class="parameterdesc">',
				EndTag = "</span>",
			},
		},
		ParserCSS = '\t\t\t.parameterinput{\n\t\t\t\tfont-weight: bold;\n\t\t\t\tfont-size: 90%;\n\t\t\t}\n\n\t\t\t\t.parametertype{\n\t\t\tfont-style: italic;\n\t\t\t\tfont-size: 90%;\n\t\t\t}\n\n\t\t\t.parameterdesc{\n\t\t\t\tfont-size: 90%;\n\t\t\t}\n\n';
		ParserSeparator = " | ",
		Variations = {
			"parameter",
			"param",
		},			
	},
	Return = {
		AllowMultiple = true,			
		Parser = {
			[1] = { --variable name example
				StartTag = '<span id="returnvariable">',
				EndTag = "</span>",
			},
			[2] = { --variable type
				StartTag = '<span id="returntype">',
				EndTag = "</span>",
			},
			[3] = { --description/notes
				StartTag = '<span id="returndesc">',
				EndTag = "</span>",
			},
		},
		ParserCSS = '\t\t\t.returnvariable{\n\t\t\t}';
		ParserSeparator = " | ",
		Variations = {
			"return",
			"ret",
		},
	},
	Scope = {
		AllowedValues = { -- if using this table, the 'DefaultValue' attribute must also be present (although ,the inverse is NOT true)
			"global",
			"local",
		},
		DefaultValue = "global", --this method of forcing values cannot currently be used in conjunction with the 'Parser' attribute, it only works with single items at the moment.
		Variations = {
			"scope",
		},
	},
	Usage = {
		Variations = {
			"usage",
			"use",
		},
	},
};

dox.Version = "0.0.7";

--this has to be done to prevent the script from incorrectly looking at the marker code above
for sIndex, tItem in pairs(dox.Markers) do
	
	for sSubIndex, vItem in pairs(tItem) do
		
		--global markers
		if tItem.Start and tItem.End then
		dox.Markers[sIndex][sSubIndex] = dox.Markers[sIndex][sSubIndex]:gsub("IGNORE", "");		
		end
		
	end
	
end