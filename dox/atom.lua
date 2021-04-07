dox.atom = {};

--[[!
@module dox.atom
@func dox.atom.writeSnippets
@scope global
@desc Writes Atom snippets to the snippets file provided based on the lua files which were processed for documentation.
@param pAtomSnippetsFile string The full path to the atom snippets file. If it does not exist, it will be created.
@param sSnippetSection string The section name for the snippets. Having sections allows for mutiple calls to write to the same file without overwrites.
!]]
--TODO account for json or cson. Right now, only cson is supported.
--TODO check for auto-file creation. If this doesn't happen, make it happen.
function dox.atom.writeSnippets(pAtomSnippetsFile, sSnippetSection)

	--try to process atom snippets
	if (type(pAtomSnippetsFile) == "string" and
		type(sSnippetSection) == "string" 	and
		sSnippetSection:gsub("%s", '') ~= "") then
		--snippet section names are NOT case sensitive
		local sSection = sSnippetSection:upper();

		--open the snippets file
		local hSnippets 	= io.open(pAtomSnippetsFile, "r");

		--process the snippets if the file exists
		if (hSnippets) then
			local tModules = dox.Modules;
			--this has the process order for the modules
			local tMeta = getmetatable(tModules);

			--read the snippets file
			local sSnippetsFile 	= hSnippets:read("*all");
			--declare and preconfigure required variables
			local sPreAppend		= sSnippetsFile;
			local sAppend			= ""; --this is the actual snippet code
			local sPostAppend		= "";
			local sSectionOpenTag 	= dox.Markers.Snippet.Start..sSection;
			local sSectionCloseTag 	= dox.Markers.Snippet.End..sSection;
			local sSourceLuaPrefix	= "'.source.lua':";

			for sLine in hSnippets:lines() do

				--TODO get the number of indentations that the code blocks should use based on the source:lua line's indentations
				if (sLine:gsub('%s', '') == "'.source.lua':") then
					sSourceLuaPrefix = "";
				end

			end

			--look for the section
			local nSectionOpenTagStart, nSectionOpenTagEnd	= sSnippetsFile:find(sSectionOpenTag, 1, true);

			--if the section already exists, prepair to overwrite it
			if (nSectionOpenTagStart 	~= nil and nSectionOpenTagEnd 	~= nil) then
				local nSectionCloseTagStart, nSectionCloseTagEnd = sSnippetsFile:find(sSectionCloseTag, nSectionOpenTagEnd + 1, true);

				if (nSectionCloseTagStart 	~= nil and nSectionCloseTagEnd 	~= nil) then
					sPreAppend 	= sSnippetsFile:sub(1, nSectionOpenTagStart - 1);
					sPostAppend = sSnippetsFile:sub(nSectionCloseTagEnd + 1);
				end

			end

			--close the file for reading
			hSnippets:close();

			for nIndex, sModule in pairs(tMeta.ProcessOrder) do
				local tModule = tModules[sModule];

				for _, nBlockID in pairs(tModule.ProcessOrder) do
					local tBlock 				= tModule.Blocks[nBlockID];
					local sSnippet 				= "\n    '"..tBlock.Function.."':";
					local sParameters 			= "";
					local sParamterDescriptions = "";

					--get the function's parameters (if present)
					local nMaxParameters = #tBlock.Parameters;

					for nParamIndex, sLine in pairs(tBlock.Parameters) do

						if sLine:gsub("%s", ' ') ~= "" then
							local sComma = ", ";

							--add this paramter (in its entirety) to the descriptions section
							sParamterDescriptions = sParamterDescriptions.."\n        arg# "..tostring(nParamIndex)..": "..sLine;

							--remove the comma if not needed
							if (nParamIndex == 1) then
								sComma = "";
							end

							--TODO redo all these to use ANY space character(%s) rather than only a specific space character
							local nTypeStart, nTypeEnd = sLine:find(" ", 1, true);

							if (nTypeStart ~= nil and nTypeEnd ~= nil) then
								sParameters = sParameters..sComma..sLine:sub(1, nTypeStart - 1);
							end

						end

					end

					--note if the scope is local
					local sScope = "";

					if (tBlock.Scope:lower() == "local") then
						sScope = "\nlocal";
					end

					--get the return value (if any)
					local sReturn = "";
					local sReturnType = "nil";

					for nIndex, sReturnValue in pairs(tBlock.Return) do

						if (sReturnValue:gsub("%s", '') ~= "") then
							local nReturnTypeStart, _ = sReturnValue:find(" ", 1, true);

							if (nReturnTypeStart) then
								local nReturnTypeEnd, _ = sReturnValue:find(" ", nReturnTypeStart + 1, true);

								if (nReturnTypeEnd) then
									local sType = sReturnValue:sub(nReturnTypeStart + 1, nReturnTypeEnd - 1);
									sReturn = "\n        Returns: <"..sType.."> "..sReturnValue:sub(nReturnTypeEnd + 1);
									sReturnType = sType;
								end

							end

						end

					end

					--check for an example
					local sExample = "";
					if (tBlock.Example:gsub("%s", '') ~= "") then
						sExample = "\n        "..tBlock.Example;
					end

					--concat the snippet string
					sSnippet 		= sSnippet.."\n        'description': '''"..sScope..tBlock.Description..sParamterDescriptions..sExample..sReturn.."'''";
					sSnippet 		= sSnippet.."\n        'prefix': '"..tBlock.Function.."'";
					sSnippet 		= sSnippet.."\n        'body': '''"..tBlock.Function.."("..sParameters..");'''";
					sSnippet 		= sSnippet.."\n        'leftLabelHTML': '<span style=\"color:#0f0\">f</span>'";
					sSnippet 		= sSnippet.."\n        'rightLabelHTML': '<span style=\"color:#ff0\">"..sReturnType.."</span>'";

					--TODO add the 'More' tag for linking to dox-generated documentation

					--TODO complete the other desired sections
					--[[
					File 		= getDefaultValue("Example"),
					Module 		= getDefaultValue("Module"),
					Usage 		= getDefaultValue("Usage"),
					]]

					sAppend = sAppend..sSnippet;
				end

			end

			--TODO this is appending cumulative new lines...check for a new line before adding one afger the sPreAppend; also check for multiplt end-file new lines
			--assemble the full file text
			local sFileText = sPreAppend.."\n"..sSectionOpenTag.."\n"..sSourceLuaPrefix..sAppend.."\n"..sSectionCloseTag.."\n"..sPostAppend;

			--open the file for writing
			local hSnippets 	= io.open(pAtomSnippetsFile, "w");

			if (hSnippets) then
				hSnippets:write(sFileText);
				hSnippets:close();

			end

		end

	end

		--[[

	'Protean.Destroy':
        'description': '''Marks a Protean object for garabge collection (setting it to nil).'''
        'prefix': 'Protean.Destroy'
        'body': '''Protean.Destroy();'''
        'leftLabelHTML': '<span style="color:#f30">function(constant)</span>'
        'rightLabelHTML': '<span style="color:#ff0">nil</span>'

	]]

end