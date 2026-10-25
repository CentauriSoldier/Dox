--[[!
@fqxn Dox.Builders.HTML.Themes
@desc Twenty page palettes applied after the shared CSS. Midnight Blue preserves the original design; Zenburn and Synthwave Protocol use Studio's palettes. These palettes do not alter Prism code themes.
@field table Each keyed entry contains a display name and CSS variable overrides. Keys match Dox.THEME enum values.
!]]
return {
    ["alucard"] = {
        name = "Alucard",
        css  = [[
        :root {
            --accent: #a3144d;
            --accent-soft: #f0d6d2;
            --border: #cbc8bc;
            --breadcrumb-background: #f5f1e2;
            --button-background: #ece8da;
            --button-border: #a3144d;
            --button-hover: #f3ddd6;
            --button-text: #1f1f1f;
            --header-end: #FFFBEB;
            --header-start: #f5f1e2;
            --link-hover: #a3144d;
            --muted: #6c664b;
            --navbackground: #f5f1e2;
            --navlink: #a3144d;
            --navlinkhover: #1f1f1f;
            --page: #FFFBEB;
            --sectioncontent: #1f1f1f;
            --sectiontitle: #1f1f1f;
            --sectiontitlebg: #ece8da;
            --selected-border: #a3144d;
            --selected-text: #1f1f1f;
            --surface: #f5f1e2;
            --surface-raised: #ece8da;
            --text: #1f1f1f;
        }
        ]],
    },

    ["catppuccin_frappe"] = {
        name = "Catppuccin Frappe",
        css  = [[
        :root {
            --accent: #ca9ee6;
            --accent-soft: #494560;
            --border: #52586e;
            --breadcrumb-background: #373b4e;
            --button-background: #3d4155;
            --button-border: #ca9ee6;
            --button-hover: #44425b;
            --button-text: #c6d0f5;
            --header-end: #303446;
            --header-start: #373b4e;
            --link-hover: #ca9ee6;
            --muted: #9ea5c1;
            --navbackground: #373b4e;
            --navlink: #ca9ee6;
            --navlinkhover: #c6d0f5;
            --page: #303446;
            --sectioncontent: #c6d0f5;
            --sectiontitle: #c6d0f5;
            --sectiontitlebg: #3d4155;
            --selected-border: #ca9ee6;
            --selected-text: #c6d0f5;
            --surface: #373b4e;
            --surface-raised: #3d4155;
            --text: #c6d0f5;
        }
        ]],
    },

    ["catppuccin_latte"] = {
        name = "Catppuccin Latte",
        css  = [[
        :root {
            --accent: #8738ed;
            --accent-soft: #ded3f4;
            --border: #caccd5;
            --breadcrumb-background: #e8eaef;
            --button-background: #e1e3e9;
            --button-border: #8738ed;
            --button-hover: #e1d9f4;
            --button-text: #4c4f69;
            --header-end: #EFF1F5;
            --header-start: #e8eaef;
            --link-hover: #8738ed;
            --muted: #666879;
            --navbackground: #e8eaef;
            --navlink: #8738ed;
            --navlinkhover: #4c4f69;
            --page: #EFF1F5;
            --sectioncontent: #4c4f69;
            --sectiontitle: #4c4f69;
            --sectiontitlebg: #e1e3e9;
            --selected-border: #8738ed;
            --selected-text: #4c4f69;
            --surface: #e8eaef;
            --surface-raised: #e1e3e9;
            --text: #4c4f69;
        }
        ]],
    },

    ["catppuccin_macchiato"] = {
        name = "Catppuccin Macchiato",
        css  = [[
        :root {
            --accent: #c6a0f6;
            --accent-soft: #3e3a58;
            --border: #4a4f65;
            --breadcrumb-background: #2b2f42;
            --button-background: #32364a;
            --button-border: #c6a0f6;
            --button-hover: #393752;
            --button-text: #cad3f5;
            --header-end: #24273A;
            --header-start: #2b2f42;
            --link-hover: #c6a0f6;
            --muted: #939ab7;
            --navbackground: #2b2f42;
            --navlink: #c6a0f6;
            --navlinkhover: #cad3f5;
            --page: #24273A;
            --sectioncontent: #cad3f5;
            --sectiontitle: #cad3f5;
            --sectiontitlebg: #32364a;
            --selected-border: #c6a0f6;
            --selected-text: #cad3f5;
            --surface: #2b2f42;
            --surface-raised: #32364a;
            --text: #cad3f5;
        }
        ]],
    },

    ["catppuccin_mocha"] = {
        name = "Catppuccin Mocha",
        css  = [[
        :root {
            --accent: #cba6f7;
            --accent-soft: #3a344e;
            --border: #46485c;
            --breadcrumb-background: #262637;
            --button-background: #2d2e3f;
            --button-border: #cba6f7;
            --button-hover: #343048;
            --button-text: #cdd6f4;
            --header-end: #1E1E2E;
            --header-start: #262637;
            --link-hover: #cba6f7;
            --muted: #9399b2;
            --navbackground: #262637;
            --navlink: #cba6f7;
            --navlinkhover: #cdd6f4;
            --page: #1E1E2E;
            --sectioncontent: #cdd6f4;
            --sectiontitle: #cdd6f4;
            --sectiontitlebg: #2d2e3f;
            --selected-border: #cba6f7;
            --selected-text: #cdd6f4;
            --surface: #262637;
            --surface-raised: #2d2e3f;
            --text: #cdd6f4;
        }
        ]],
    },

    ["dracula"] = {
        name = "Dracula",
        css  = [[
        :root {
            --accent: #ff79c6;
            --accent-soft: #4a374d;
            --border: #585961;
            --breadcrumb-background: #31333e;
            --button-background: #3a3c46;
            --button-border: #ff79c6;
            --button-hover: #443449;
            --button-text: #f8f8f2;
            --header-end: #282A36;
            --header-start: #31333e;
            --link-hover: #ff79c6;
            --muted: #909bbe;
            --navbackground: #31333e;
            --navlink: #ff79c6;
            --navlinkhover: #f8f8f2;
            --page: #282A36;
            --sectioncontent: #f8f8f2;
            --sectiontitle: #f8f8f2;
            --sectiontitlebg: #3a3c46;
            --selected-border: #ff79c6;
            --selected-text: #f8f8f2;
            --surface: #31333e;
            --surface-raised: #3a3c46;
            --text: #f8f8f2;
        }
        ]],
    },

    ["gruvbox_dark"] = {
        name = "Gruvbox Dark",
        css  = [[
        :root {
            --accent: #fc6857;
            --accent-soft: #4a3230;
            --border: #555148;
            --breadcrumb-background: #31302e;
            --button-background: #393734;
            --button-border: #fc6857;
            --button-hover: #44302e;
            --button-text: #ebdbb2;
            --header-end: #282828;
            --header-start: #31302e;
            --link-hover: #fc6857;
            --muted: #a29689;
            --navbackground: #31302e;
            --navlink: #fc6857;
            --navlinkhover: #ebdbb2;
            --page: #282828;
            --sectioncontent: #ebdbb2;
            --sectiontitle: #ebdbb2;
            --sectiontitlebg: #393734;
            --selected-border: #fc6857;
            --selected-text: #ebdbb2;
            --surface: #31302e;
            --surface-raised: #393734;
            --text: #ebdbb2;
        }
        ]],
    },

    ["gruvbox_light"] = {
        name = "Gruvbox Light",
        css  = [[
        :root {
            --accent: #9d0006;
            --accent-soft: #eccaa8;
            --border: #cfc6a6;
            --breadcrumb-background: #f2e9c0;
            --button-background: #ebe1bb;
            --button-border: #9d0006;
            --button-hover: #efd2ae;
            --button-text: #3c3836;
            --header-end: #FBF1C7;
            --header-start: #f2e9c0;
            --link-hover: #9d0006;
            --muted: #72665a;
            --navbackground: #f2e9c0;
            --navlink: #9d0006;
            --navlinkhover: #3c3836;
            --page: #FBF1C7;
            --sectioncontent: #3c3836;
            --sectiontitle: #3c3836;
            --sectiontitlebg: #ebe1bb;
            --selected-border: #9d0006;
            --selected-text: #3c3836;
            --surface: #f2e9c0;
            --surface-raised: #ebe1bb;
            --text: #3c3836;
        }
        ]],
    },

    ["midnight_blue"] = {
        name = "Midnight Blue",
        css  = [[
        :root {
            --accent: #79baff;
            --accent-soft: #223e5d;
            --border: #30445f;
            --breadcrumb-background: #141f2e;
            --button-background: #2b4562;
            --button-border: #4b6c90;
            --button-hover: #365c85;
            --button-text: #edf6ff;
            --header-end: #1c2435;
            --header-start: #172b44;
            --link-hover: #b9ddff;
            --muted: #9cabc1;
            --navbackground: #182435;
            --navlink: #bcd9fa;
            --navlinkhover: #ffffff;
            --page: #101824;
            --sectioncontent: #e4edf7;
            --sectiontitle: #dcecff;
            --sectiontitlebg: #203047;
            --selected-border: #5487b6;
            --selected-text: #ffffff;
            --surface: #182435;
            --surface-raised: #203047;
            --text: #e4edf7;
        }
        ]],
    },

    ["nord"] = {
        name = "Nord",
        css  = [[
        :root {
            --accent: #8ba9c6;
            --accent-soft: #3d4755;
            --border: #555b67;
            --breadcrumb-background: #363c48;
            --button-background: #3c424e;
            --button-border: #8ba9c6;
            --button-hover: #3a4351;
            --button-text: #d8dee9;
            --header-end: #2E3440;
            --header-start: #363c48;
            --link-hover: #8ba9c6;
            --muted: #8ba9c6;
            --navbackground: #363c48;
            --navlink: #8ba9c6;
            --navlinkhover: #d8dee9;
            --page: #2E3440;
            --sectioncontent: #d8dee9;
            --sectiontitle: #d8dee9;
            --sectiontitlebg: #3c424e;
            --selected-border: #8ba9c6;
            --selected-text: #d8dee9;
            --surface: #363c48;
            --surface-raised: #3c424e;
            --text: #d8dee9;
        }
        ]],
    },

    ["rose_pine"] = {
        name = "Rose Pine",
        css  = [[
        :root {
            --accent: #c4a7e7;
            --accent-soft: #342e43;
            --border: #474554;
            --breadcrumb-background: #22202d;
            --button-background: #2a2836;
            --button-border: #c4a7e7;
            --button-hover: #2f2a3d;
            --button-text: #e0def4;
            --header-end: #191724;
            --header-start: #22202d;
            --link-hover: #c4a7e7;
            --muted: #908caa;
            --navbackground: #22202d;
            --navlink: #c4a7e7;
            --navlinkhover: #e0def4;
            --page: #191724;
            --sectioncontent: #e0def4;
            --sectiontitle: #e0def4;
            --sectiontitlebg: #2a2836;
            --selected-border: #c4a7e7;
            --selected-text: #e0def4;
            --surface: #22202d;
            --surface-raised: #2a2836;
            --text: #e0def4;
        }
        ]],
    },

    ["rose_pine_dawn"] = {
        name = "Rose Pine Dawn",
        css  = [[
        :root {
            --accent: #76648b;
            --accent-soft: #e5dddd;
            --border: #d1cbcd;
            --breadcrumb-background: #f2ece7;
            --button-background: #ebe5e1;
            --button-border: #76648b;
            --button-hover: #e9e1e0;
            --button-text: #464261;
            --header-end: #FAF4ED;
            --header-start: #f2ece7;
            --link-hover: #76648b;
            --muted: #6c6883;
            --navbackground: #f2ece7;
            --navlink: #76648b;
            --navlinkhover: #464261;
            --page: #FAF4ED;
            --sectioncontent: #464261;
            --sectiontitle: #464261;
            --sectiontitlebg: #ebe5e1;
            --selected-border: #76648b;
            --selected-text: #464261;
            --surface: #f2ece7;
            --surface-raised: #ebe5e1;
            --text: #464261;
        }
        ]],
    },

    ["rose_pine_moon"] = {
        name = "Rose Pine Moon",
        css  = [[
        :root {
            --accent: #c4a7e7;
            --accent-soft: #3d3652;
            --border: #4e4c62;
            --breadcrumb-background: #2c2a3f;
            --button-background: #333146;
            --button-border: #c4a7e7;
            --button-hover: #38324d;
            --button-text: #e0def4;
            --header-end: #232136;
            --header-start: #2c2a3f;
            --link-hover: #c4a7e7;
            --muted: #9491ad;
            --navbackground: #2c2a3f;
            --navlink: #c4a7e7;
            --navlinkhover: #e0def4;
            --page: #232136;
            --sectioncontent: #e0def4;
            --sectiontitle: #e0def4;
            --sectiontitlebg: #333146;
            --selected-border: #c4a7e7;
            --selected-text: #e0def4;
            --surface: #2c2a3f;
            --surface-raised: #333146;
            --text: #e0def4;
        }
        ]],
    },

    ["solarized_dark"] = {
        name = "Solarized Dark",
        css  = [[
        :root {
            --accent: #879b05;
            --accent-soft: #163d2e;
            --border: #1e434c;
            --breadcrumb-background: #06303a;
            --button-background: #0b343e;
            --button-border: #879b05;
            --button-hover: #123a30;
            --button-text: #89999b;
            --header-end: #002B36;
            --header-start: #06303a;
            --link-hover: #879b05;
            --muted: #84959c;
            --navbackground: #06303a;
            --navlink: #879b05;
            --navlinkhover: #849597;
            --page: #002B36;
            --sectioncontent: #849597;
            --sectiontitle: #89999b;
            --sectiontitlebg: #0b343e;
            --selected-border: #879b05;
            --selected-text: #92a1a2;
            --surface: #06303a;
            --surface-raised: #0b343e;
            --text: #849597;
        }
        ]],
    },

    ["solarized_light"] = {
        name = "Solarized Light",
        css  = [[
        :root {
            --accent: #657400;
            --accent-soft: #e5e1bf;
            --border: #d8d7ca;
            --breadcrumb-background: #f6f0df;
            --button-background: #f0ecdb;
            --button-border: #657400;
            --button-hover: #e9e5c5;
            --button-text: #5a6e75;
            --header-end: #FDF6E3;
            --header-start: #f6f0df;
            --link-hover: #657400;
            --muted: #626f70;
            --navbackground: #f6f0df;
            --navlink: #657400;
            --navlinkhover: #5c7077;
            --page: #FDF6E3;
            --sectioncontent: #5c7077;
            --sectiontitle: #5a6e75;
            --sectiontitlebg: #f0ecdb;
            --selected-border: #657400;
            --selected-text: #54666c;
            --surface: #f6f0df;
            --surface-raised: #f0ecdb;
            --text: #5c7077;
        }
        ]],
    },

    ["synthwave_protocol"] = {
        name = "Synthwave Protocol",
        css  = [[
        :root {
            --accent: #00b7ff;
            --accent-soft: #092244;
            --border: #383450;
            --breadcrumb-background: #140f29;
            --button-background: #1c1732;
            --button-border: #00b7ff;
            --button-hover: #0a1d3d;
            --button-text: #d0d0f0;
            --header-end: #0B0620;
            --header-start: #140f29;
            --link-hover: #00b7ff;
            --muted: #67819f;
            --navbackground: #140f29;
            --navlink: #00b7ff;
            --navlinkhover: #d0d0f0;
            --page: #0B0620;
            --sectioncontent: #d0d0f0;
            --sectiontitle: #d0d0f0;
            --sectiontitlebg: #1c1732;
            --selected-border: #00b7ff;
            --selected-text: #d0d0f0;
            --surface: #140f29;
            --surface-raised: #1c1732;
            --text: #d0d0f0;
        }
        ]],
    },

    ["tokyo_night"] = {
        name = "Tokyo Night",
        css  = [[
        :root {
            --accent: #bb9af7;
            --accent-soft: #342f47;
            --border: #404356;
            --breadcrumb-background: #21232f;
            --button-background: #282a38;
            --button-border: #bb9af7;
            --button-hover: #2f2c41;
            --button-text: #c0caf5;
            --header-end: #1A1B26;
            --header-start: #21232f;
            --link-hover: #bb9af7;
            --muted: #8289ac;
            --navbackground: #21232f;
            --navlink: #bb9af7;
            --navlinkhover: #c0caf5;
            --page: #1A1B26;
            --sectioncontent: #c0caf5;
            --sectiontitle: #c0caf5;
            --sectiontitlebg: #282a38;
            --selected-border: #bb9af7;
            --selected-text: #c0caf5;
            --surface: #21232f;
            --surface-raised: #282a38;
            --text: #c0caf5;
        }
        ]],
    },

    ["tokyo_night_moon"] = {
        name = "Tokyo Night Moon",
        css  = [[
        :root {
            --accent: #c099ff;
            --accent-soft: #3b3756;
            --border: #484c62;
            --breadcrumb-background: #292c3f;
            --button-background: #303346;
            --button-border: #c099ff;
            --button-hover: #373350;
            --button-text: #c8d3f5;
            --header-end: #222436;
            --header-start: #292c3f;
            --link-hover: #c099ff;
            --muted: #8a92bc;
            --navbackground: #292c3f;
            --navlink: #c099ff;
            --navlinkhover: #c8d3f5;
            --page: #222436;
            --sectioncontent: #c8d3f5;
            --sectiontitle: #c8d3f5;
            --sectiontitlebg: #303346;
            --selected-border: #c099ff;
            --selected-text: #c8d3f5;
            --surface: #292c3f;
            --surface-raised: #303346;
            --text: #c8d3f5;
        }
        ]],
    },

    ["tokyo_night_storm"] = {
        name = "Tokyo Night Storm",
        css  = [[
        :root {
            --accent: #bb9af7;
            --accent-soft: #3c3a59;
            --border: #484d66;
            --breadcrumb-background: #2b2f43;
            --button-background: #31364b;
            --button-border: #bb9af7;
            --button-hover: #383753;
            --button-text: #c0caf5;
            --header-end: #24283B;
            --header-start: #2b2f43;
            --link-hover: #bb9af7;
            --muted: #9096b6;
            --navbackground: #2b2f43;
            --navlink: #bb9af7;
            --navlinkhover: #c0caf5;
            --page: #24283B;
            --sectioncontent: #c0caf5;
            --sectiontitle: #c0caf5;
            --sectiontitlebg: #31364b;
            --selected-border: #bb9af7;
            --selected-text: #c0caf5;
            --surface: #2b2f43;
            --surface-raised: #31364b;
            --text: #c0caf5;
        }
        ]],
    },

    ["zenburn"] = {
        name = "Zenburn",
        css  = [[
        :root {
            --accent: #f0dfaf;
            --accent-soft: #5b5951;
            --border: #63635f;
            --breadcrumb-background: #464645;
            --button-background: #4c4c4b;
            --button-border: #f0dfaf;
            --button-hover: #56544e;
            --button-text: #dcdccc;
            --header-end: #3F3F3F;
            --header-start: #464645;
            --link-hover: #f0dfaf;
            --muted: #a3baa3;
            --navbackground: #464645;
            --navlink: #f0dfaf;
            --navlinkhover: #dcdccc;
            --page: #3F3F3F;
            --sectioncontent: #dcdccc;
            --sectiontitle: #dcdccc;
            --sectiontitlebg: #4c4c4b;
            --selected-border: #f0dfaf;
            --selected-text: #dcdccc;
            --surface: #464645;
            --surface-raised: #4c4c4b;
            --text: #dcdccc;
        }
        ]],
    },
};
