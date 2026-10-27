return [[
<h1>Dox</h1>
<p>Dox turns structured source comments into browsable HTML documentation and
Pulsar autocomplete packages. Keep names, descriptions, parameters, return
values and examples beside the code they describe.</p>
<h3>Initialize and generate</h3>
<pre><code class="language-lua">local initLuaEx = require(&quot;LuaEx.load&quot;);
initLuaEx();
require(&quot;dox.init&quot;);

local document = DoxLua(&quot;My project&quot;);
document.setOutputPath(&quot;docs&quot;);
document.importFiles({&quot;MyLibrary.lua&quot;});
document.refresh();
document.export(&quot;index&quot;);
</code></pre>
<p>Place the LuaEx and dox folders on the module search path, and create the output
directory before exporting. Dox initializes immediately on import and requires
<code>LUAEX_INIT == true</code>.</p>
<p>Select <code>Dox.BUILDER.PULSAR_LUA</code> with <code>document.setBuilder</code> to export a Pulsar
package ZIP from the same comments. The <a href="#Dox">Dox API</a> covers parsers, tags,
builders, page palettes, syntax-highlighting themes and output settings.</p>


]];
