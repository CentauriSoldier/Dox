return [[
<h1>Dox</h1>
<h2>Version 2.1</h2>
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

<details>
<summary>View changelog</summary>
<h1>Dox changelog</h1>
<h2>v2.1</h2>
<h3>Added</h3>
<ul>
<li>Standalone, immediate initialization through <code>require(&quot;dox.init&quot;)</code>.</li>
<li>Versioned documentation introduction and generated HTML API reference for GitHub Pages.</li>
<li>A current repository guide to writing comments and generating HTML and Pulsar packages.</li>
</ul>
<h3>Changed</h3>
<ul>
<li>Dox modules reside under the lowercase <code>dox</code> namespace, with the initializer inside that folder.</li>
<li>Core, HTML-builder and Pulsar-builder imports use the standalone module paths.</li>
<li>Initialization requires <code>LUAEX_INIT == true</code>; LuaEx no longer loads Dox automatically.</li>
<li>The README preserves its existing title image and describes the current API.</li>
</ul>
<h3>Removed</h3>
<ul>
<li>Obsolete README notices that described the standalone repository as archived or moved into LuaEx.</li>
</ul>

</details>
]];
