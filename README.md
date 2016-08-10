# Dox
A Lua Documentation Generator Script

##How To Comment Your Code

###Take a breath...
Now, I know this is a new way to document your code, but I've made it as painless as possible. Once you read this section, you'll be ready to start documenting and you'll see how simple Dox is to use.

###Function Info Block
This is primary element of Dox that makes it work. In fact, without at least one function info block, Dox will not process the target module since there would be no information to process.

The function info block is wrapped in a multi-line lua comment whose start tag is --[[! and end tag is !]].
Function Info Block Block Tags

Elements inside the function info block are designated by an "@" symbol directly followed by the desired tag and tag information.
Below is a list of currently usable tags for this block as well as their formatting and usage details.

    Description
    Example
    Function
    Module
    Parameters
    Return
    Scope
    Usage

###Module Info Block
The module information is wrapped in a multiline lua comment whose start tag is --[[* and end tag is *]]. The content of this block is displayed at the top of the module page within and accordion menu (the one you're using right now).

Note: Unlike (at least one) function info block, the module info block is not required. Dox will function just fine with or without the module info block; you may omit the entire thing if you wish. Additionaly, if you do choose to use the module info block, only one of the tags (listed below) are required: the 'module' tag is required if using the module info block although you may use one, all or none of the remaining tags (or anything in between).

Unlike the function info block, the module info block has no tags that are sensitive to spaces and new lines. This feature makes it very easy to use html with your module info block. As you can see, you're reading text right now that has been formatted within the comment block of the dox.lua file.

Within the block are tags. These tags start and end just like html tags do, with <tagname> as the start tag and </tagname> as the end tag where tagname is the name of the tag. Below is a complete list of supported tags.

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

The moduleid Tag

You may enter one to many items for the 'moduleid' tag. For example, if your module name is myClass then you'd enter it exactly as the class name since the 'moduleid' tag is case sensitive.; however, you can control how it's displayed at the top of the page. To include a display name, simply use a pipe (|) and type the display next like this myClass|MyClass.

If you have sub modules such as myClass.otherStuff and you'd like the module block for myClass to display on the myClass.otherStuff page, use a comma to indicate another module and simlpy add it the 'moduleid' tag like so: myClass|MyClass,myClass.otherStuff and if you'd like a differnt display name for that module too, just add it in: myClass|MyClass,myClass.otherStuff|MyClass.otherStuff. It's that easy.
Special Characters

The '@' symbol cannot be used in your text without escaping it since it is a special character that tells Dox where to start a line; however, you can escape it in your text using a backslash (\) and the '@' will be put there by Dox when processing is complete: E.g., @. Additionaly, any text inside free-format items (like authors, website, description, etc. as opposed to items like param, function, etc. that are more restricted) is treated like html including any html tags you may want to use. Of course, this means that you'll need to escape the '<' and '>' symbols in your text if you want them to be presented as-is.

Below is a complete list of special characters that need escaped to be displayed as themselves.

    @
    >
    <


##Example Usage
Dox is very easy to use. Once you've commented your code appropriately, all you need are your scripts and an empty directory where Dox can output the html files.

dox.processDir(sPathToMyLuaFiles, sPathToTheOutputDirectory);

That's it! Tada, you've got documentation!
