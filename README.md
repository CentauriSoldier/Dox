![DOX](assets/dox_title.png)

## 🆆🅷🅰🆃 🅸🆂 🅳🅾🆇❓ 🔬
Dox is a lua documentation generator script.

## 🆁🅴🆂🅾🆄🆁🅲🅴🆂
- Logo: https://cooltext.com/
- Special ASCII Fonts: https://fsymbols.com/generators/carty/

## 🆅🅴🆁🆂🅸🅾🅽 ⚗

#### Alpha v0.6
<details>
<summary>See Changes</summary>

### 🇨​​​​​🇭​​​​​🇦​​​​​🇳​​​​​🇬​​​​​🇪​​​​​🇱​​​​​🇴​​​​​🇬​​​​​

**v0.6**
- Feature: TODO update this changelog
</details>

## 🅿🅻🅰🅽🅽🅴🅳 🅵🅴🅰🆃🆄🆁🅴🆂
- [ ] Add dox core function snippets to the Atom snippets file (if not already present) when writing to the Atom snippets file.
- [ ] Add dox function and module comment snippets to the Atom snippets file (if not already present) when writing to the Atom snippets file.
- [ ] Use Bootstrap for CSS.

## 🅻🅸🅲🅴🅽🆂🅴 ©

All code is placed in the public domain under [The Unlicense](https://opensource.org/licenses/unlicense "The Unlicense") *(except where otherwise noted)*.

## 🅵🅰🆀🆂
* *Can I use my own css?*
	* Currently, no. But, if there are enough requests for this feature, I'll add it in the future.
* *Is Dox cross-platform?*
	* So far, Dox is tested and working on Linux and Windows.
* *How do I use Dox?*
	* View the readme file for that info.
* *Do you plan to create autocomplete scripts for other editors/IDEs?*
	* Not at this time; however, enough interest in a specific IDE/editor may change my mind.

## 🆂🅴🆃🆄🅿
1. Download the **dox** folder from this repository and place it in your project.
2. Require the dox module.
```lua
require('dox.dox');
```

## 🅷🅾🆆 🆃🅾 🅲🅾🅼🅼🅴🅽🆃 🆈🅾🆄🆁 🅲🅾🅳🅴

## 🇫​​​​​🇺​​​​​🇳​​​​​🇨​​​​​🇹​​​​​🇮​​​​​🇴​​​​​🇳​​​​​ 🇧​​​​​🇱​​​​​🇴​​​​​🇨​​​​​🇰​​​​​
This is the primary element of Dox that makes it work. In fact, without at least one function info block, Dox will not process the target module since there would be no information to process.

The function info block is wrapped in a multi-line lua comment whose start tag is ***--[[!*** and end tag is ***!]]***.

#### Block Tags
Elements inside the function info block are designated by an ***@*** symbol directly followed by the desired tag and tag information.

Below is a list of currently usable tags *(as well as acceptable abbreviations)* for this block as well as their formatting and usage details. Following the description of each tag is an indicator of whether it is required or optional.

*Note: tags are **not** case sensitive.*

- **description** 	*(**des**, **desc**)* This informs the reader what your function does. *(**optional**)*
- **example** 		*(**ex**, **examples**)* Code to help the reader understand how it works. *(**optional**)*
- **function** 		*(**fun**, **func**)* The name of the function *(**required**)*
- **module** 		*(**mod**)* To which module this function belongs. *(**optional**)*
- **parameter** 	*(**param**)* *See description below* *(**optional**)*
- **return**		*(**ret**)* *See description below* *(**optional**)*
- **scope**			Whether global or local.
- **usage**   		How the function is intended to be used, it's features, limitations, etc.


	- #### Special Tags
	The **return** and **parameter** tags behave a little differently than the other tags in that they accept up to three input sections delimited by a space.

		- ##### The Parameter Tag
		
		First is the descriptive name *(**required**)*, then the type input *(**required**)* and a description of the input value *(**optional**)*.

			- ###### Example usage of a parameter tag.

```lua
@param pInputFile string The path to the file dox reads.
```

	- ##### The Return Tag
	First is the descriptive name *(**required**)*, then the type returned *(**required**)* and a description of the returned value *(**optional**)*.

		- ###### Example usage of a return tag.

```lua
@ret sPath string The local path from which dox is run.
```

***
# THIS SECTION IN-PROGRESS
## 🇲​​​​​🇴​​​​​🇩​​​​​🇺​​​​​🇱​​​​​🇪​​​​​ 🇧​​​​​🇱​​​​​🇴​​​​​🇨​​​​​🇰​​​​​
The module information is wrapped in a multiline lua comment whose start tag is ***--[[**** and end tag is ****]]***. The content of this block is displayed at the top of the module page within an accordion menu on the left of the page.
- Note on module block requirements:
> *Unlike (at least one) function block, the module block is **not required**. Dox will function just fine with or without the module block; you may omit the entire thing if you wish. Additionally, if you do choose to use the module block, only one of the tags (listed below) is required: the 'module' tag is required if using the module block although you may use none, one, some or all of the other tags*

Like the function block, the module block has no tags that are sensitive to spaces and new lines. This feature makes it very easy to use html within your module block. As you can see, you're reading text right now that has been formatted within the comment block of the dox.lua file.

Within the block are tags. These tags start and end just like html tags do, with <tagname> as the start tag and </tagname> as the end tag where tagname is the name of the tag. Below is a complete list of supported tags. The tags are not case sensitive.

* authors
* copyright
* dependencies
* description
* features
* email
* license
* moduleid *required tag*
* plannedfeatures
* todo
* usage
* version
* versionhistory
* website

#### The moduleid Tag

You may enter one to many items for the 'moduleid' tag. For example, if your module name is myClass then you'd enter it exactly as the class name since the 'moduleid' tag is case sensitive.; however, you can control how it's displayed at the top of the page. To include a display name, simply use a pipe (|) and type the display name next like this:
```lua
@moduleid myClass|MyClass
```
If you have sub modules such as myClass.otherStuff and you'd like the module block for myClass to display on the myClass.otherStuff page, use a comma to indicate another module and simlpy add it the 'moduleid' tag like so:
```lua
@moduleid myClass|MyClass,myClass.otherStuff
```
And if you'd like a different display name for that module too, just add it in:
```lua
@moduleid myClass|MyClass,myClass.otherStuff|MyClass.otherStuff
```    
It's that easy.

### Tag Content
Tag text can be plain text and/or html.

#### Special Characters

The '@' symbol cannot be used in your text without escaping it since it is a special character that tells Dox where to start a line; however, you can escape it in your text using a backslash (\\) and the '@' will be put there by Dox when processing is complete.

Additionaly, any text inside free-format items (like authors, website, description, etc. as opposed to items like param, function, etc. that are more restricted) is treated like html including any html tags you may want to use. Of course, this means that you'll need to escape the '<' and '>' symbols in your text if you want them to be presented as-is.

Below is a complete list of special characters that need to be escaped in order to be displayed as themselves.

    @
    >
    <

### Give Me Space!
Each tag **must** have a space after it before your text starts. Failing to provide a space will give unpredictable results.

## Example Usage

### Comment a Function or Two
```lua
--[[!
@module dox
@func import
@scope local
@desc A version of the 'require()' function that uses the local path. Used to require the other local modules the 'dox.lua' file needs.
!]]
```
### Comment Your Module(s) if You Want *(NOT REQUIRED)*
```lua
--[[*
@authors Centauri Soldier
@copyright Copyright © 2022 Centauri Soldier
@description
	<h2>Dox</h2>
	<h3>The Simple Lua Documentation Generator</h3>
	<p>Dox is a light-weight script designed to parse crafted lua comments regarding modules and functions and output them to readable, sorted and linked HTML. Dox enables you to quickly and simply create documentation for your lua code without the need to install programs or to run anything other than the Dox script. In fact, it's so simple, you can have documentation in as few as 2 lines of code.</p>
@license <p>The MIT License (MIT)<br>
<br>
Copyright (c) 2016 Centauri Soldier<br>
<br>
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:<br>
<br>
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.<br>
<br>
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
</p>
@moduleid dox|Dox,dox.base64|Dox.Base64,dox.css|Dox.CSS,dox.html|Dox.HTML,dox.theme|Dox.Theme,dox.parse|Dox.Parse,dox.util|Dox.Util
@version 0.0.7
@versionhistory
<ul>
	<li>
		<b>0.0.1</b>
		<br>
		<p>Created Dox in all its wonder...and despair.</p>
	</li>
</ul>
@website https://github.com/CentauriSoldier/Dox
*]]
```
### Generate Your Documentation
Dox is very easy to use. Once you've commented your code appropriately, all you need are your scripts and an empty directory where Dox can output the html files.

#### Note:
Dox will ***NOT*** create directories. Be sure the output directory exists or Dox will (silently) fail to output any files.

```lua
dox.processDir(sPathToMyLuaFiles, sPathToTheOutputDirectory);
```
#### That's it!
Tada, you've got documentation!

## Atom Snippets
If you're using the [Atom](https://atom.io/) text editor, you can tell dox to non-destructively generate snippets for it (snippets allow user-created auto-complete in the Atom text editor).
All you need to do (after you generate your documentation with the dox.ProcessDir() (or dox.ProcessFile()) funcion) is call the dox.atom.writeSnippets() function.

Dox will even keep separate sections for your various code projects to prevent overwriting other text in the snippets file. It does this by using section names. In addition to keeping separate sections secure from overwrite, Dox also preserves the non-dox snippet code in the file by non-destructively writing it's snippets at the end of the file thus allowing you to retain the ability to manually write snippets that have nothing to do with dox.

```lua
dox.atom.writeSnippets(sPathToMyAtomSnippetsFile, sSnippetSectionName)
```

## Credits
Nifty background image by [Vecteezy](https://www.vecteezy.com/free-vector/space)
