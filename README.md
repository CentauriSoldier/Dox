# Dox 0.0.9
#### A Lua Documentation Generator Script

## Setup
#### Download the **dox** folder from this repository and place it in your project.
#### Require the dox module.


```lua
require('dox.dox');
```

## How To Comment Your Code

### Take a breath...
Now, I know this is a new way to document your code, but I've made it as painless as possible. Once you read this section, you'll be ready to start documenting and you'll see how simple Dox is to use.

### Function Info Block
This is the primary element of Dox that makes it work. In fact, without at least one function info block, Dox will not process the target module since there would be no information to process.

The function info block is wrapped in a multi-line lua comment whose start tag is **--[[!** and end tag is **!]].**

#### Function Info Block Block Tags
Elements inside the function info block are designated by an "@" symbol directly followed by the desired tag and tag information.

Below is a list of currently usable tags for this block as well as their formatting and usage details. The tags are **not** case sensitive.

    Description
    Example
    Function(required)
    Module(recommended)
    Parameter
    Return
    Scope
    Usage

#### Special Tags
**Return** and **Parameter** behave a little differently than the other tags in that they accept up to three input sections delimited by a space.

##### The Parameter Tag
First is the descriptive name *(required)*, then the type input *(required)* and a description of the input value *(optional)*.

###### Example usage of a parameter tag.
```lua
@param pInputFile string The path to the file dox reads.
```
##### The Return Tag
First is the descriptive name *(required)*, then the type returned *(required)* and a description of the returned value *(optional)*.

###### Example usage of a return tag.
```lua
@ret sPath string The local path from which dox is run.
```
### Module Info Block
The module information is wrapped in a multiline lua comment whose start tag is --[[* and end tag is *]]. The content of this block is displayed at the top of the module page within and accordion menu on the left of the page.

Note: Unlike (at least one) function info block, the module info block is not required. Dox will function just fine with or without the module info block; you may omit the entire thing if you wish. Additionaly, if you do choose to use the module info block, only one of the tags (listed below) is required: the 'module' tag is required if using the module info block although you may use one, all or none of the remaining tags (or anything in between).

Like the function info block, the module info block has no tags that are sensitive to spaces and new lines. This feature makes it very easy to use html with your module info block. As you can see, you're reading text right now that has been formatted within the comment block of the dox.lua file.

Within the block are tags. These tags start and end just like html tags do, with <tagname> as the start tag and </tagname> as the end tag where tagname is the name of the tag. Below is a complete list of supported tags. The tags are not case sensitive.

    authors
    copyright
    dependencies
    description
    features
    email
    license
    moduleid(required)
    plannedfeatures
    todo
    usage
    version
    versionhistory
    website

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
@copyright Copyright © 2016 Centauri Soldier
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
