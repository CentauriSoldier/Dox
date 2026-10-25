--[[!
@fqxn Dox.Builders.HTML.Data.JS
@des The core Javascript code that is used when creating the final HTML document.
!]]
return [[
const userData = {
    "ModuleA": {
        "value": "Some value for ModuleA",
        "subtable": {
            "Functions": {
                "value": "Some value for Functions in ModuleA",
                "subtable": {
                    "FunctionA1": {
                        "value": "Details about FunctionA1.",
                        "subtable": null
                    },
                    "FunctionA2": {
                        "value": "Details about FunctionA2.",
                        "subtable": null
                    },
                    "FunctionA3": {
                        "value": "Details about FunctionA3.",
                        "subtable": null
                    }
                }
            },
            "Enums": {
                "value": "Some value for Enums in ModuleA",
                "subtable": {
                    "EnumA1": {
                        "value": "Details about EnumA1.",
                        "subtable": null
                    },
                    "EnumA2": {
                        "value": "Details about EnumA2.",
                        "subtable": null
                    }
                }
            },
            "Constants": {
                "value": "Some value for Constants in ModuleA",
                "subtable": {
                    "ConstantA1": {
                        "value": "Details about ConstantA1.",
                        "subtable": null
                    }
                }
            }
        }
    },
    "ModuleB": {
        "value": "Some value for ModuleA",
        "subtable": {
            "Functions": {
                "value": "Some value for Functions in ModuleA",
                "subtable": {
                    "FunctionA1": {
                        "value": "Details about FunctionA1.",
                        "subtable": null
                    },
                    "FunctionA2": {
                        "value": "Details about FunctionA2.",
                        "subtable": null
                    },
                    "FunctionA3": {
                        "value": "Details about FunctionA3.",
                        "subtable": null
                    }
                }
            },
            "Enums": {
                "value": "Some value for Enums in ModuleA",
                "subtable": {
                    "EnumA1": {
                        "value": "Details about EnumA1.",
                        "subtable": null
                    },
                    "EnumA2": {
                        "value": "Details about EnumA2.",
                        "subtable": null
                    }
                }
            },
            "Constants": {
                "value": "Some value for Constants in ModuleA",
                "subtable": {
                    "ConstantA1": {
                        "value": "Details about ConstantA1.",
                        "subtable": null
                    }
                }
            }
        }
    }
};
//—©_END_DOX_TESTDATA_©—
const doxData = {
    "Modules": {
        "value": `
        <div class="DOX_intro container">
            <div class="row">
                <div class="col-lg-12">
                    <div class="p-5 text-center rounded">
                        <h1 class="DOX_intro">Welcome to Dox: The Lua-based Documentation System!</h1>
                        <p class="DOX_intro lead">With Dox, you can effortlessly organize and navigate through your project's documentation, making it easier for your team and users to find the information they need.</p>
                        <p class="DOX_intro lead">Explore its features to see how Dox can streamline your documentation process and enhance collaboration:</p>
                        <ul class="list-unstyled">
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Simple to Use</li>
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Easy Sidebar Navigation</li>
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Breadcrumb Navigation</li>
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Dynamic Content Updates</li>
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Customizable Styling</li>
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Responsive Design for Any Device</li>
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Document Any Language <em>(Even A Custom One)</em></li>
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Uses <a href="https://prismjs.com/" target="_blank">Prism</a> For Beautiful Code Examples</li>
                            <li><i class="DOX_intro fas fa-angle-double-right"></i> Free Forever, Public Domain Code</li>
                        </ul>
                        <br>
                        <strong>Download LuaEx <em>(containing Dox)</em></strong>
                        <br>
                        <a class="DOX_intro" href="https://github.com/CentauriSoldier/LuaEx" target="_blank">https://github.com/CentauriSoldier/LuaEx</a>
                    </div>
                </div>
            </div>
        </div>
        `,
        "subtable": userData
    }
};
//—©_END_DOX_DEFAULT_INTRO_©—

class Dox {
    constructor() {
        if (Dox.instance) {
            return Dox.instance;
        }

        Dox.instance = this;
        this.data = doxData;
        this.activeFQXN = "Modules";
        this.restoreLocation();

        // Only local fragment links belong to the documentation navigator.
        document.body.addEventListener('click', (event) => {
            const anchor = event.target.closest('a[href]');
            if (!anchor || !anchor.getAttribute('href').startsWith('#')) {
                return;
            }

            const fragment = anchor.getAttribute('href').slice(1);
            if (!fragment) {
                event.preventDefault();
                return;
            }

            const path = this.pathFromFragment(fragment);
            if (this.fqxnIsValid(path)) {
                event.preventDefault();
                this.setActiveFQXN(path);
                this.updatePage();
            }
        });

        // History traversal renders the stored location without adding another entry.
        window.addEventListener('popstate', () => {
            this.restoreLocation();
            this.updatePage(false);
        });
        window.addEventListener('hashchange', () => {
            this.restoreLocation();
            this.updatePage(false);
        });
    }


    byID(id) {
        return document.getElementById(id);
    }


    static copyToClipboard(button) {
        const code = button.closest('.custom-section').querySelector('pre code, pre');
        if (!code) {
            return;
        }

        const textarea = document.createElement('textarea');
        textarea.value = code.textContent;
        document.body.appendChild(textarea);
        textarea.select();
        const copied = document.execCommand('copy');
        textarea.remove();
        button.textContent = copied ? 'Copied' : 'Copy failed';
        window.setTimeout(() => { button.textContent = 'Copy'; }, 1500);
    }


    fqxnIsValid(path) {
        return this.getDataByFQDN(path) !== null;
    }


    getActiveFQXN() {
        return this.activeFQXN;
    }


    getDataByFQDN(path) {
        let current = this.data;
        let node = null;

        for (const part of path.split('.')) {
            if (!current || !Object.prototype.hasOwnProperty.call(current, part)) {
                return null;
            }

            node = current[part];
            current = node.subtable;
        }

        return node;
    }


    makeLink(path, label) {
        const anchor = document.createElement('a');
        anchor.href = '#' + path.replace(/^Modules\.?/, '');
        anchor.textContent = label.split('%20').join(' ');
        anchor.addEventListener('click', (event) => {
            event.preventDefault();
            event.stopPropagation();
            this.setActiveFQXN(path);
            this.updatePage();
        });

        return anchor;
    }


    pathFromFragment(fragment) {
        let decoded;
        try {
            decoded = decodeURIComponent(fragment);
        } catch (_) {
            return '';
        }

        return 'Modules.' + decoded.replace(/^Modules\.?/, '').split(' ').join('%20');
    }


    restoreLocation() {
        const path = window.location.hash ? this.pathFromFragment(window.location.hash.slice(1)) : 'Modules';
        this.activeFQXN = this.fqxnIsValid(path) ? path : 'Modules';
    }


    setActiveFQXN(path) {
        if (!this.fqxnIsValid(path)) {
            return false;
        }

        this.activeFQXN = path;
        return true;
    }


    updateBreadcrumb() {
        const breadcrumb = this.byID('DOX_breadcrumb');
        breadcrumb.replaceChildren();
        const parts = this.activeFQXN.split('.');

        parts.forEach((part, index) => {
            const item = document.createElement('li');
            item.className = 'breadcrumb-item';
            const label = index === 0 ? 'Overview' : part;
            if (index === parts.length - 1) {
                item.textContent = label.split('%20').join(' ');
                item.classList.add('active');
                item.setAttribute('aria-current', 'page');
            } else {
                item.appendChild(this.makeLink(parts.slice(0, index + 1).join('.'), label));
            }
            breadcrumb.appendChild(item);
        });
    }


    updateContent() {
        const node = this.getDataByFQDN(this.activeFQXN);
        const content = this.byID('DOX_content');
        content.innerHTML = node.value || '<div class="dox-empty">Choose a topic from the navigation to explore its documentation.</div>';
        this.byID('DOX_topic').textContent = this.activeFQXN === 'Modules' ? 'Documentation overview' : this.activeFQXN.split('.').slice(-1)[0].split('%20').join(' ');
        this.byID('DOX_location').textContent = this.activeFQXN.replace(/^Modules\.?/, '').split('%20').join(' ') || 'Explore the project reference';
    }


    updateNavMenu() {
        const menu = this.byID('DOX_navmenu');
        menu.replaceChildren();
        const active = this.getDataByFQDN(this.activeFQXN);
        const parentPath = this.activeFQXN.split('.').slice(0, -1).join('.');
        const groupPath = active.subtable ? this.activeFQXN : parentPath;
        const group = this.getDataByFQDN(groupPath);
        const upPath = groupPath.split('.').slice(0, -1).join('.');

        this.byID('DOX_navheading').textContent = groupPath === 'Modules' ? 'Project reference' : groupPath.split('.').slice(-1)[0].split('%20').join(' ');
        if (upPath) {
            const item = document.createElement('li');
            const anchor = this.makeLink(upPath, '← Back to parent');
            anchor.className = 'nav-link dox-up';
            item.appendChild(anchor);
            menu.appendChild(item);
        }

        Object.keys(group.subtable || {}).sort().forEach((key) => {
            const path = groupPath + '.' + key;
            const item = document.createElement('li');
            item.className = 'nav-item';
            const anchor = this.makeLink(path, key);
            anchor.className = 'nav-link';
            if (path === this.activeFQXN) {
                anchor.classList.add('active');
                anchor.setAttribute('aria-current', 'page');
            }
            item.appendChild(anchor);
            menu.appendChild(item);
        });
    }


    updatePage(recordHistory = true) {
        this.updateNavMenu();
        this.updateBreadcrumb();
        this.updateContent();
        Prism.highlightAll();

        if (recordHistory) {
            const hash = this.activeFQXN === 'Modules' ? '' : '#' + this.activeFQXN.slice(8);
            if (window.location.hash !== hash) {
                history.pushState({ activeFQXN: this.activeFQXN }, '', window.location.pathname + window.location.search + hash);
            }
        }
    }
}
]];
