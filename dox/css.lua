dox.css = {};
local theme = dox.theme;


--[[!
@module dox.css
@func getParserCSS
@desc Concatenates the Parser strings from the 'dox.Types' table. This is used in 'dox.css.update()'.
@scope local
!]]
local function getParserCSS()
local sRet = "";

	for sType, tType in pairs(dox.Types) do
		
		if dox.Types[sType].Parser and dox.Types[sType].ParserCSS then
		sRet = sRet.."\n\n"..dox.Types[sType].ParserCSS;
		end

	end

return sRet
end

local nMenuPadding = 15;
local nPagePadding = 5;
local sPagePadding = nPagePadding.."px";
local sTopSectionHeight = "40px";
local sFooterHeight = "30px";
local nMenuWidth = 230;
local sMenuWidth = nMenuWidth.."px"
local sContentStart = (nPagePadding + nMenuPadding + nMenuWidth).."px";
local sContentBorder = 'border-radius: 0px 0px 20px 20px;\n\t-moz-border-radius: 0px 0px 20px 20px;\n\t-webkit-border-radius: 0px 0px 20px 20px;\n'
--CSS [this OR dox.PageVars.CSSPathAndVersion must be blank]

--[[!
@module dox
@func dox.css.update
@description This informs the css of theme changes that may have occurred.
!]]
function dox.css.update()
	dox.PageVars.CSS = [[
	/* original page css courtesy of http://www.dynamicdrive.com/style/layouts/item/css_liquid_layout_21_fixed_fluid/ */

	html{
		position: absolute; top: 0px; left: 0px;
		width: 100%;
		min-height: 100%;
	}

	body{
		position: relative;
		left: 0px;
		]]..theme.getBGImage()..[[
		]]..theme.getBGImageRepeat()..[[
		width: 100%
		height: 100%;
		margin:0;
		padding:0;
		line-height: 1.5em;
		background: ]]..theme.getColor("BackgroundSurround")..[[
		
	}


	a {
	  transition: color .4s;
	  color: ]]..theme.getColor("LinkText")..[[;
	}

	a:link, a:visited { color: ]]..theme.getColor("LinkText")..[[; }
	a:hover   { color: ]]..theme.getColor("LinkHover")..[[; }
	a:active  {
	  transition: color .3s;
	  color: ]]..theme.getColor("LinkText")..[[;
	}

	.link { text-decoration: none; }
		
		]]..getParserCSS()..[[

	b{
		font-size: 130%;
	}

	em{
		color: ]]..theme.getColor("SectionTitle")..[[;
	}

	#maincontainer{
		display: inline-block;
		position: relative;
		top: 0;
		width: 100%; /*Width of main container*/
		min-height: 100%;
		margin: 0 auto; /*Center container on page*/
		background: #FFF;
	}

	p{
		font-size: 100%;
		color: ]]..theme.getColor("ParagraphText")..[[;
	}			
		
	#topsection{
		position: fixed;
		top: ]]..sPagePadding..[[;
		left: ]]..sContentStart..[[;
		width: calc(100% - ]]..sContentStart..[[ - ]]..sPagePadding..[[);
		background: ]]..theme.getColor("BackgroundContent")..[[;
		height: ]]..sTopSectionHeight..[[; /*Height of top section*/
		border-radius: 20px 20px 0px 0px;
		-moz-border-radius: 20px 20px 0px 0px;
		-webkit-border-radius: 20px 20px 0px 0px;
		border: 0px solid #000000;				
	}

	#topsection h1{
		margin: 0;
		padding-top: ]]..sPagePadding..[[;
		color: ]]..theme.getColor("PageHeader")..[[;
		font-size:xx-large;
		text-align:center;
	}

	#contentwrapper{
		display: inline-block;
		position: fixed;
		left: 0;
		top: calc(]]..sTopSectionHeight..[[ + ]]..sPagePadding..[[); /*Height of top section*/
		margin-left: ]]..sContentStart..[[;
		width: calc(100% - ]]..sContentStart..[[ - ]]..(nPagePadding * 6)..[[px + 1px);
		height: calc(100vh - ]]..sTopSectionHeight..[[ - ]]..sFooterHeight..[[ - ]]..(nPagePadding * 8)..[[px);
		]]..sContentBorder..[[
	}

	#contentcolumn{
		position: relative;
		background: ]]..theme.getColor("BackgroundContent")..[[;				
		width: 100%;
		height: 100%;
		overflow: hidden;
		padding: 12px;
		]]..sContentBorder..[[
	}

	#modulecontentwrapper{
		display: inline-block;
		position: fixed;
		left: 0;
		top: 0;
		margin-left: 0;
		width: 100%;
		height: 100%;
		]]..sContentBorder..[[
	}

	#modulecontentcolumn{
		position: relative;
		background: ]]..theme.getColor("BackgroundContent")..[[;				
		width: 100%;
		height: 100%;
		overflow: auto;
		padding: 0px;
		]]..sContentBorder..[[
	}	

	/* The frame that loads the module pages */
	#module{
		margin: 0px;
		padding: 0px;
		height: 98%;
		width: 100%;
		border-radius: 20px 20px 0px 20px;
		-moz-border-radius: 20px 20px 0px 20px;
		-webkit-border-radius: 20px 20px 0px 20px;
		border: none;
	}

	#footer{
		position: fixed;
		clear: left;
		width: 100%;
		height: ]]..sFooterHeight..[[;
		color: ]]..theme.getColor("ParagraphText")..[[;
		background: ]]..theme.getColor("BackgroundSurround")..[[;
		text-align: center;
		padding: 4px 0;				
		bottom: 0px;				
	}

	#footer a{
		color: ]]..theme.getColor("SectionTitle")..[[;
	}
	
	/* MOVE TO THE MODULE SECTION
	.innertubecontent{		
		
	}
	*/
	
	.innertubemenu{
		height: 100%;
		margin: 10px; /*Margins for inner DIV inside the side bar (to provide padding)*/				
		margin-top: 0;				
	}

	#welcome{
	Background-color: ]]..theme.getColor("BackgroundContent")..[[;
	background-image: url("data:image/png;base64,]]..dox.base64.getData("keepcalm")..[[");
	background-repeat: no-repeat;
	background-attachment: fixed;
	background-position: center;
	padding: 0;
	margin: 0;
	width: 100%;
	height: 100%;
	}

	hr.moduleitemBACKUP{
		height: 12px;
		border: 0;
		box-shadow: inset 0 12px 12px -12px rgba(0, 0, 0, 0.5);
		color: ]]..theme.getColor("MenuNormal")..[[;
	}

	hr.moduleitem{
		border: 0;
		height: 55px;
		background-image: url("data:image/png;base64,]]..dox.base64.getData("pacman")..[[");
		background-repeat: no-repeat;
		background-position: center;
	}

	/*HEADER MENU SECTION*/

	ul.headermenu {
		margin:0;
		list-style-type: none;	
	}

	a.headermenu {
		margin:0;
		list-style-type: none;	
	}

	/*NAV MENU SECTION*/

	div.navmenu{
		position: fixed;				
		top: ]]..sPagePadding..[[; /* top section height*/
		left: ]]..sPagePadding..[[;
		padding: 2px;
		max-height: calc(96vh - ]]..sFooterHeight..[[); /*subtract the padding, top section and footer*/
		overflow-y: auto;
		overflow-x: hidden;
		width: ]]..sMenuWidth..[[;
		border-radius: 20px 20px 0px 20px;
		-moz-border-radius: 20px 20px 0px 20px;
		-webkit-border-radius: 20px 20px 0px 20px;
		border: 2px solid ]]..theme.getColor("BackgroundOutline")..[[;
		-webkit-box-shadow: 7px 10px 5px 0px rgba(0,0,0,0.5);
		-moz-box-shadow: 7px 10px 5px 0px rgba(0,0,0,0.5);
		box-shadow: 7px 10px 5px 0px rgba(0,0,0,0.5);
	}

	.menu {
	  margin: 0 auto;
	  padding: 0;
	  width: 100%;
	}

	.menu li { list-style: none; }

	.menu li a {
	  display: table;
	  margin-top: 1px;
	  padding: 14px 10px;
	  width: 100%;
	  background: ]]..theme.getColor("BackgroundSurround")..[[;
	  text-decoration: none;
	  text-align: left;
	  vertical-align: middle;
	  color: ]]..theme.getColor("SectionTitle")..[[;
	  overflow: hidden;
	  -webkit-transition-property: background;
	  -webkit-transition-duration: 0.4s;
	  -webkit-transition-timing-function: ease-out;
	  transition-property: background;
	  transition-duration: 0.4s;
	  transition-timing-function: ease-out;
	}

	.menu > li:first-child a { margin-top: 0; }

	.menu li a:hover {
	  background: ]]..theme.getColor("BackgroundContent")..[[;
	  -webkit-transition-property: background;
	  -webkit-transition-duration: 0.2s;
	  -webkit-transition-timing-function: ease-out;
	  transition-property: background;
	  transition-duration: 0.2s;
	  transition-timing-function: ease-out;
	}

	.menu li ul {
	  max-height: calc(50vh - 90px - ]]..sFooterHeight..[[); /*similar to the div settings*/;
	  overflow-y: auto;
	  overflow-x: hidden;
	  margin: 0;
	  padding: 0;
	}

	.menu li li a {
	  display: block;
	  margin-top: 0;
	  padding: 0 10px;
	  height: 0;
	  background: ]]..theme.getColor("MenuNormal")..[[;
	  color: ]]..theme.getColor("MenuNormalText")..[[;
	  -webkit-transition-property: all;
	  -webkit-transition-duration: 0.5s;
	  -webkit-transition-timing-function: ease-out;
	  transition-property: all;
	  transition-duration: 0.5s;
	  transition-timing-function: ease-out;
	}

	.menu > li:hover li a {
	  display: table;
	  margin-top: 1px;
	  padding: 10px;
	  width: 100%;
	  height: 1em;
	  -webkit-transition-property: all;
	  -webkit-transition-duration: 0.3s;
	  -webkit-transition-timing-function: ease-out;
	  transition-property: all;
	  transition-duration: 0.3s;
	  transition-timing-function: ease-out;
	}

	.menu > li:hover li a:hover {
	  background: ]]..theme.getColor("MenuHighlight")..[[;
	  -webkit-transition-property: background;
	  -webkit-transition-duration: 0.2s;
	  -webkit-transition-timing-function: ease-out;
	  transition-property: background;
	  transition-duration: 0.2s;
	  transition-timing-function: ease-out;
	}

	/*MODULE INFO SECTION*/

	#miversion{
		font-size: 60%;
		vertical-align: super;
	}

	#midisplayname{
		font-size; 120%;
	}

	#miauthors{
		font-style: italic;
		font-size; 30%;				
	}
		
	/* horizontal menu */

	p.mip{

	}
	
	/* MODULE SECTION = MODULE SECTION = MODULE SECTION = MODULE SECTION*/
	
	/* Allows for color alternating between functions for ease of reading.*/
	.innertubecontentalt, .innertubecontent{		
		margin: 10px; /*Margins for inner DIV inside each column (to provide padding)*/
		margin-top: 0;
		padding: 10px 10px 10px 12px;
		-webkit-box-shadow: 0px 11px 8px -4px rgba(0,0,0,0.49);
		-moz-box-shadow: 0px 11px 8px -4px rgba(0,0,0,0.49);
		box-shadow: 0px 11px 8px -4px rgba(0,0,0,0.49);
		border-radius: 20px 20px 0px 20px;
		-moz-border-radius: 20px 20px 0px 20px;
		-webkit-border-radius: 20px 20px 0px 20px;
		border-top: 2px groove;
		border-right: 2px groove;
		border-bottom: 2px groove;
		border-left: 2px solid ]]..theme.getColor("MenuNormal")..[[;
	}
	
	.innertubecontentalt{
		background-color: rgba(0, 0, 0, 0.1);
		border-left: 2px solid ]]..theme.getColor("MenuHighlight")..[[;
	}
	
	/* The paramters of the function */
	p.parameter{
		font-size: 108%;
	}
	
	code{
	
	}
	
	/*The name of the function*/
	h2.functionname{
		display: inline;
		font-size: 160%;
	}
	
	/* Titles such as Description, Parameters, etc. */
	h3.blocklineheader{
		font-size: 125%;
	}
	
	.scope{
		font-style: italic;
		margin: 0px 0px 0px 3px;
		vertical-align: super;
		color: ]]..theme.getColor("Special_1")..[[;
		font-size: 115%;
	}
	
	p.blockdesc{
		color: ]]..theme.getColor("ParagraphText")..[[;
		font-size: 120%;
		padding: 6px;
		max-width: 97%;
		/*-webkit-box-shadow: 7px 7px 3px 0px rgba(0,0,0,0.46);
		-moz-box-shadow: 7px 7px 3px 0px rgba(0,0,0,0.46);
		box-shadow: 7px 7px 3px 0px rgba(0,0,0,0.46);
		border-radius: 10px 10px 0px 10px;
		-moz-border-radius: 10px 10px 0px 1px;
		-webkit-border-radius: 10px 10px 0px 10px;
		border: 4px solid ]]..theme.getColor("BackgroundOutline")..[[;*/
	}
	
	/* Original accorian menu courtesy of http://accordionslider.com/ each tab costs 35px (with this layout) and the base object's size is 700 */



	.accordion > ul > li,
	.accordion-title,
	.accordion-content,
	.accordion-separator {
		float: left;
	}

	.accordion > ul > li {
		background-color: ]]..theme.getColor("BackgroundSurround")..[[;
		margin-right: -700px;
		margin-bottom: -0px;
	}

	.accordion-select:checked ~ .accordion-separator {
		margin-right: 700px;
		margin-bottom: 0px;
	}

	.accordion-title,
	.accordion-select  {
		background-color: ]]..theme.getColor("BackgroundSurround")..[[;
		color: ]]..theme.getColor("SectionTitle")..[[;
		width: 35px;
		height: 310px;
		font-size: 15px;
	}

	.accordion-title span {
		margin-bottom: 18px; 
		margin-left: 20px;
	}

	.accordion-select:hover ~ .accordion-title,
	.accordion-select:checked ~ .accordion-title {
		background-color: ]]..theme.getColor("MenuNormal")..[[;
		color: ]]..theme.getColor("MenuNormalText")..[[;
	}

	.accordion-title span  {	
		transform: rotate(-90deg);
		-o-transform: rotate(-90deg);
		-moz-transform: rotate(-90deg);
		-webkit-transform: rotate(-90deg);
		-ms-writing-mode: lr-bt;
		filter: progid:DXImageTransform.Microsoft.BasicImage(rotation=3);
		margin-left: 0px;
		line-height: 35px;
	}

	.accordion-content {
		background-color: ]]..theme.getColor("BackgroundContent")..[[;
		color: ]]..theme.getColor("ParagraphText")..[[;
		height: 254px;
		width: 644px;
		padding: 28px;
	}

	.accordion-title,
	.accordion-select:checked ~ .accordion-content {
		margin-right: 0px;
		margin-bottom: 0px;
	}

	/* Do not change following properties, they aren't 
	generated automatically and are common for each slider. */
	.accordion {
		overflow: hidden;
	}

	.accordion > ul {
		margin: 0;
		padding: 0;
		list-style: none;
		width: 101%;
	}

	.accordion > ul > li,
	.accordion-title {
		position: relative;
	}

	.accordion-select {
		cursor: pointer;
		position: absolute;
		opacity: 0;
		top: 0;
		left: 0;
		margin: 0;
		z-index: 1;
	}

	.accordion-title span {
		display: block;
		position: absolute;
		bottom: 0px;
		width: 100%;
		white-space: nowrap;
	}

	.accordion-content {
		position: relative;
		overflow: auto;
	}

	.accordion-separator {
		transition: margin 0.3s ease 0.1s;
		-o-transition: margin 0.3s ease 0.1s;
		-moz-transition: margin 0.3s ease 0.1s;
		-webkit-transition: margin 0.3s ease 0.1s;
	}
	]]
end