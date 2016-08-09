--Note: 'dox.Theme' contains settings whereas 'dox.theme' contains functions
dox.theme = {};
dox.Theme = {
	ActiveTheme = "Plain",
	DefaultTheme = "Plain",
	Themes = {
		["Custom"] = {},		
		["Insta Hip"] = {
			Colors = {
				--[[				
					instahip
					#3b1f2b
					#db162f
					#dbdfac
					#5f758e
					#383961
				]]				
				ParagraphText = "#000",--common text
				BackgroundContent = "#db162f",
				BackgroundSurround = "#db162f",
				BackgroundOutline = "#aaa",
				LinkText = "#dce6ee",
				LinkHover = "#9fecf4",
				MenuNormal = "#373737",
				MenuNormalText = "#f0f0f0",
				MenuHighlight = "#595959",				
				ParagraphText = "#000",
				PageHeader = "#728190",
				SectionTitle = "#5f758e",
			},
			ImageCode = 'background-image: url("images/pastel.jpg");',
			ImageRepeatCode = "repeat;",			
		},
		["Plain"] = {
			Colors = {
				--[[1984
					#bfb48f
					#564e58
					#904e55
					#f2efe9
					#252627
				]]
				BackgroundContent = "#ddd",
				BackgroundSurround = "#ccc",
				BackgroundOutline = "#aaa",
				LinkText = "#8fa7b6",
				LinkHover = "#b5ddff",
				MenuNormal = "#373737",
				MenuNormalText = "#f0f0f0",
				MenuHighlight = "#595959",				
				ParagraphText = "#000",
				PageHeader = "#728190",
				SectionTitle = "#495867",
				Special_1 = "a0a0ff", --used on '#scope' atm
				Special_2 = "000077", --used on variable type
				Special_3 = "",
				Special_4 = "",
				Special_5 = "",
			},
			ImageCode = '',
			ImageRepeatCode = "",
		},
	},
};


function dox.theme.setActive(sTheme)
	
	if dox.Theme.Themes[sTheme] then	
	dox.Theme.ActiveTheme = sTheme;
	end
	
end

function dox.theme.getBGImage()
local sImage = "";
local sActiveTheme = dox.Theme.ActiveTheme;
local sDefaultTheme = dox.Theme.DefaultTheme;
local tThemes = dox.Theme.Themes;

	--try to get the color from the active theme
	if tThemes[sActiveTheme] then
		
		if tThemes[sActiveTheme].ImageCode then
		return tThemes[sActiveTheme].ImageCode
		end
		
	end	
	
		
	--if something goes wrong, try the default theme
	if tThemes[sDefaultTheme] then
		
		if tThemes[sDefaultTheme].ImageCode then
		return tThemes[sDefaultTheme].ImageCode
		end
		
	end
		
return sImage
end


--[[!
DEPRECATED - DELETE THIS AND THE RELATED TABLES INDICES 
!]]
function dox.theme.getBGImageRepeat()
local sImageRepeatCode = "";
local sActiveTheme = dox.Theme.ActiveTheme;
local sDefaultTheme = dox.Theme.DefaultTheme;
local tThemes = dox.Theme.Themes;

	--try to get the color from the active theme
	if tThemes[sActiveTheme] then
		
		if tThemes[sActiveTheme].ImageRepeatCode then
		return tThemes[sActiveTheme].ImageRepeatCode
		end
		
	end	
	
		
	--if something goes wrong, try the default theme
	if tThemes[sDefaultTheme] then
		
		if tThemes[sDefaultTheme].ImageRepeatCode then
		return tThemes[sDefaultTheme].ImageRepeatCode
		end
		
	end
		
return sImageRepeatCode
end


--[[!
@module dox.theme
@func dox.theme.getColor
@desc Gets a color of the selected type from the currently-active theme.
@param sType string The index of the color item to get.
@ret sColor returns the hex color or an error color is the index input does not exist in the theme.
!]]
function dox.theme.getColor(sApplication)
local sColor = "#ff00ff"; --error color
local sActiveTheme = dox.Theme.ActiveTheme;
local sDefaultTheme = dox.Theme.DefaultTheme;
local tThemes = dox.Theme.Themes;

	--try to get the color from the active theme
	if tThemes[sActiveTheme] then
		
		if tThemes[sActiveTheme].Colors[sApplication] then		
		return tThemes[sActiveTheme].Colors[sApplication]
		end
			
	end	
	
		
	--if something goes wrong, try the default theme
	if tThemes[sDefaultTheme] then
		
		if tThemes[sDefaultTheme].Colors[sApplication] then
		return tThemes[sDefaultTheme].Colors[sApplication]
		end
		
	end
		
return sColor
end

--[[colors
autumn
#3f2d3b
#743042
#9c1f2d
#dd800b
#fab509

wheat
#7b3800
#df9659
#efd3c4
#ddd6d6
#c7b8b2

watermelon
#262b06
#628519
#98c543
#c6e17e
#92290b

winter evening
#0f1225
#1f4b8e
#adbccd
#f1ece6
#eadbd4



winding down
#c5ebc3
#b7c8b5
#a790a5
#875c74
#54414e

instahip
#3b1f2b
#db162f
#dbdfac
#5f758e
#383961
]]