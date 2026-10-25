local DoxBlockTag   = DoxBlockTag;


--[[!
    @fqxn Dox.Statics.BlockTags
    @desc This is a list of all built-in <a href="#Dox.Components.DoxBlockTag">BlockTags</a>.
    <br>While subclasses (parsers) <i>may</i> provide their own additional BlockTags, the ones listed below are always guaranteed to be available.<br><br>
    Wrapper availability depends on the selected builder and is not a property of the tag.<br>
    <table class="table table-striped table-bordered table-responsive">
        <thead class="thead-dark">
            <tr>
                <th scope="col">Display</th>
                <th scope="col">Aliases</th>
                <th scope="col">Required</th>
                <th scope="col">Multiple Allowed</th>
                <th scope="col">Combined</th>
                <th scope="col"># Columns</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>FQXN</td>
                <td>fqxn</td>
                <td>yes</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Description</td>
                <td>des, desc, description</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Bug(s)</td>
                <td>bug</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>1</td>
            </tr>
            <tr>
                <td>TODO</td>
                <td>todo</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Scope</td>
                <td>scope</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Visibility</td>
                <td>vis, visi, visibility</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Note</td>
                <td>note</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Summary</td>
                <td>summary</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Parameter(s)</td>
                <td>parameter, param, par</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>3</td>
            </tr>
            <tr>
                <td>Field(s)</td>
                <td>field</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>3</td>
            </tr>
            <tr>
                <td>Field(s) - Private</td>
                <td>privatefield, prifield, prifi</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>3</td>
            </tr>
            <tr>
                <td>Field(s) - Protected</td>
                <td>protectedfield, profield, profi</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>3</td>
            </tr>
            <tr>
                <td>Field(s) - Public</td>
                <td>publicfield, pubfield, pubfi</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>3</td>
            </tr>
            <tr>
                <td>Field(s) - Static Private</td>
                <td>staticprivatefield, staprifield, staprifi</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>3</td>
            </tr>
            <tr>
                <td>Field(s) - Static Public</td>
                <td>staticpublicfield, stapubfield, stapubfi</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>3</td>
            </tr>
            <tr>
                <td>Property</td>
                <td>prop, property</td>
                <td>no</td>
                <td>yes</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Throws</td>
                <td>throws</td>
                <td>no</td>
                <td>yes</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Return(s)</td>
                <td>return, ret</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>3</td>
            </tr>
            <tr>
                <td>Example</td>
                <td>ex, example</td>
                <td>no</td>
                <td>yes</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Code</td>
                <td>code</td>
                <td>no</td>
                <td>yes</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Requires</td>
                <td>requires</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Uses</td>
                <td>uses</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Features</td>
                <td>features</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Parent</td>
                <td>parent</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Inheritdoc</td>
                <td>inheritdoc</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Interface</td>
                <td>interface</td>
                <td>no</td>
                <td>yes</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Security</td>
                <td>security</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Performance</td>
                <td>performance</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Planned Features</td>
                <td>planned</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Issue(s)</td>
                <td>issue</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Since</td>
                <td>since</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Deprecated</td>
                <td>deprecated</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Changelog</td>
                <td>changelog, versionhistory</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Version</td>
                <td>version, ver</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>See</td>
                <td>see</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Author(s)</td>
                <td>author</td>
                <td>no</td>
                <td>yes</td>
                <td>yes</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Email</td>
                <td>email</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>License</td>
                <td>license</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Website</td>
                <td>www, web, website</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>GitHub</td>
                <td>github</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Facebook</td>
                <td>fb, facebook</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>X (Twitter)</td>
                <td>x, twitter</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
            <tr>
                <td>Copyright</td>
                <td>copy, copyright</td>
                <td>no</td>
                <td>no</td>
                <td>no</td>
                <td>1</td>
            </tr>
        </tbody>
    </table>
!]]
local _bRequired            = true;
local _bMultipleAllowed     = true;
local _bCombined            = true;
local _bIsUtil              = true;

return {
    -- Instances can customize section ordering with Dox.setBlockTagOrder.

    DoxBlockTag(    {"fqxn"},                                                   "FQXN",
                    _bRequired,     -_bMultipleAllowed),
    DoxBlockTag(    {"des", "desc", "description"},                             "Description",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"bug"},                                                    "Bug(s)",
                    -_bRequired,   _bMultipleAllowed,      _bCombined),
    DoxBlockTag(    {"todo"},                                                   "TODO",
                    -_bRequired,   _bMultipleAllowed,      _bCombined),
    DoxBlockTag(    {"scope"},                                                  "Scope",
                    -_bRequired,    -_bMultipleAllowed,   -_bCombined,      -_bIsUtil,  0),

    DoxBlockTag(    {"vis", "visi", "visibility"},                              "Visibility",
                    -_bRequired,    -_bMultipleAllowed),

    DoxBlockTag(    {"note"},                                                   "Note",
                    -_bRequired,    -_bMultipleAllowed),

    DoxBlockTag(    {"summary"},                                                "Summary",
                    -_bRequired,    -_bMultipleAllowed),

    DoxBlockTag(    {"parameter", "param", "par"},                              "Parameter(s)",
                    -_bRequired,    _bMultipleAllowed,      _bCombined,     -_bIsUtil,  2),
    DoxBlockTag(    {"field"},                                                  "Field(s)",
                    -_bRequired,    _bMultipleAllowed,      _bCombined,     -_bIsUtil,  2),
    DoxBlockTag(    {"privatefield", "prifield", "prifi"},                      "Field(s) - Private",
                    -_bRequired,    _bMultipleAllowed,      _bCombined,     -_bIsUtil,  2),
    DoxBlockTag(    {"protectedfield", "profield", "profi"},                    "Field(s) - Protected",
                    -_bRequired,    _bMultipleAllowed,      _bCombined,     -_bIsUtil,  2),
    DoxBlockTag(    {"publicfield", "pubfield", "pubfi"},                       "Field(s) - Public",
                    -_bRequired,    _bMultipleAllowed,      _bCombined,     -_bIsUtil,  2),
    DoxBlockTag(    {"staticprivatefield", "staprifield", "staprifi"},          "Field(s) - Static Private",
                    -_bRequired,    _bMultipleAllowed,      _bCombined,     -_bIsUtil,  2),
    --DoxBlockTag(    {"staticprotectedfield", "staprofield", "staprofi"},        "Field(s) - Static Protected",
    --                -_bRequired,    _bMultipleAllowed,      _bCombined,     -_bIsUtil,  2,
    --                {"<strong><em>", "</em></strong>"}, {"<em>", "</em>"}),
    DoxBlockTag(    {"staticpublicfield", "stapubfield", "stapubfi"},           "Field(s) - Static Public",
                    -_bRequired,    _bMultipleAllowed,      _bCombined,     -_bIsUtil,  2),
    DoxBlockTag(    {"prop", "property"},                                       "Property",
                    -_bRequired,    _bMultipleAllowed),
    DoxBlockTag(    {"throws"},                                                 "Throws",
                    -_bRequired,    _bMultipleAllowed),
    DoxBlockTag(    {"return", "ret"},                                          "Return(s)",
                    -_bRequired,    _bMultipleAllowed,     _bCombined,      -_bIsUtil,  2),
    DoxBlockTag(    {"ex", "example"},                                          "Example",
                    -_bRequired,    _bMultipleAllowed,      -_bCombined,    -_bIsUtil,  0),
    DoxBlockTag(    {"code"},                                                   "Code",
                    -_bRequired,    _bMultipleAllowed,      -_bCombined,    -_bIsUtil,  0),
    DoxBlockTag(    {"requires"},                                               "Requires",
                    -_bRequired,    _bMultipleAllowed,      _bCombined),
    DoxBlockTag(    {"uses"},                                                   "Uses",
                    -_bRequired,    _bMultipleAllowed,      _bCombined),
    DoxBlockTag(    {"features"},                                               "Features",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"parent"},                                                 "Parent",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"inheritdoc"},                                             "Inheritdoc",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"interface"},                                              "Interface",
                    -_bRequired,    _bMultipleAllowed),
    DoxBlockTag(    {"security"},                                               "Security",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"performance"},                                            "Performance",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"planned"},                                                "Planned Features",
                    -_bRequired,    -_bMultipleAllowed,    _bCombined),
    DoxBlockTag(    {"issue"},                                                  "Issue(s)",
                    -_bRequired,   _bMultipleAllowed,      _bCombined),
    DoxBlockTag(    {"since"},                                                  "Since",
                    -_bRequired,   -_bMultipleAllowed),
    DoxBlockTag(    {"deprecated"},                                             "Deprecated",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"changelog", "versionhistory"},                            "Changelog",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"version", "ver"},                                         "Version",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"see"},                                                    "See",
                    -_bRequired,    _bMultipleAllowed,      _bCombined),
    DoxBlockTag(    {"author"},                                                 "Author(s)",
                    -_bRequired,    _bMultipleAllowed,      _bCombined),
    DoxBlockTag(    {"email"},                                                  "Email",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"license"},                                                "License",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"www", "web", "website"},                                  "Website",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"github"},                                                 "GitHub",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"fb", "facebook"},                                         "Facebook",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"x", "twitter"},                                           "X (Twitter)",
                    -_bRequired,    -_bMultipleAllowed),
    DoxBlockTag(    {"copy", "copyright"},                                      "Copyright",
                    -_bRequired,    -_bMultipleAllowed),
};
