--[[!
@fqxn Dox.Builders.HTML.Data.CSS
@desc Shared documentation layout and Midnight Blue defaults. Selected page themes override palette variables at build time. Shared variables control the palette; layout rules keep navigation and content readable at desktop and narrow widths.
!]]
return [[
    :root {
        --base-font-size: 16px;
        --page: #101824;
        --surface: #182435;
        --surface-raised: #203047;
        --border: #30445f;
        --text: #e4edf7;
        --muted: #9cabc1;
        --accent: #79baff;
        --accent-soft: #223e5d;
        --navbackground: #182435;
        --navlink: #bcd9fa;
        --navlinkhover: #ffffff;
        --sectiontitle: #dcecff;
        --sectiontitlebg: #203047;
        --sectioncontent: #e4edf7;
        --breadcrumb-background: #141f2e;
        --button-background: #2b4562;
        --button-border: #4b6c90;
        --button-hover: #365c85;
        --button-text: #edf6ff;
        --header-end: #1c2435;
        --header-start: #172b44;
        --link-hover: #b9ddff;
        --selected-border: #5487b6;
        --selected-text: #ffffff;
    }

    /* Page shell and compact project identity. */
    * { box-sizing: border-box; }
    html { font-size: var(--base-font-size); }
    body {
        margin: 0;
        background: var(--page);
        color: var(--text);
        font-family: "Segoe UI", system-ui, sans-serif;
        line-height: 1.65;
    }
    a { color: var(--accent); }
    a:hover { color: var(--link-hover); }
    a:focus-visible, button:focus-visible { outline: 3px solid var(--accent); outline-offset: 3px; }
    #titlebg {
        padding: 24px 36px 22px;
        background: linear-gradient(120deg, var(--header-start), var(--header-end));
        border-bottom: 1px solid var(--border);
    }
    .dox-brand { color: var(--accent); font-weight: 800; letter-spacing: .14em; font-size: .85rem; }
    .dox-brand span { margin-left: 12px; color: var(--muted); font-size: .7rem; font-weight: 600; }
    #title { font-size: clamp(1.5rem, 3vw, 2.1rem); font-weight: 700; margin: 8px 0 0; letter-spacing: -.025em; }
    .dox-subtitle { margin: 3px 0 0; color: var(--muted); font-size: .85rem; }

    /* Breadcrumbs and selected items show the current location without relying on color alone. */
    #DOX_breadcrumb-wrapper { padding: 13px 36px; background: var(--breadcrumb-background); border-bottom: 1px solid var(--border); }
    #DOX_breadcrumb { margin: 0; display: flex; flex-wrap: wrap; gap: 8px; list-style: none; padding: 0; font-size: .9rem; }
    .breadcrumb-item + .breadcrumb-item::before { content: "/"; color: var(--muted); padding-right: 8px; float: none; }
    .breadcrumb-item.active { color: var(--text); font-weight: 700; }
    .breadcrumb a { text-decoration: none; }
    .dox-workspace { display: grid; grid-template-columns: 280px minmax(0, 1fr); min-height: calc(100vh - 185px); }
    #DOX_navmenu_wrapper { background: var(--surface); padding: 26px 18px; border-right: 1px solid var(--border); }
    #DOX_navheading { font-size: .75rem; text-transform: uppercase; letter-spacing: .1em; color: var(--muted); padding: 0 12px; margin: 0 0 14px; overflow-wrap: anywhere; }
    #DOX_navmenu { margin: 0; padding: 0; list-style: none; gap: 5px; }
    #DOX_navmenu .nav-link { display: block; color: var(--navlink); padding: 11px 14px; border: 1px solid transparent; border-radius: 8px; text-decoration: none; overflow-wrap: anywhere; }
    #DOX_navmenu .nav-link:hover { background: var(--surface-raised); color: var(--navlinkhover); border-color: var(--border); }
    #DOX_navmenu .nav-link.active { background: var(--accent-soft); border-color: var(--selected-border); color: var(--selected-text); font-weight: 700; box-shadow: inset 3px 0 var(--accent); }
    #DOX_navmenu .dox-up { color: var(--muted); font-size: .85rem; margin-bottom: 10px; }

    /* Content cards separate documentation sections while keeping examples readable. */
    #DOX_content_wrapper { padding: 28px 36px 60px; min-width: 0; }
    .dox-topic-header { margin: 0 auto 24px; max-width: 1050px; }
    #DOX_location { color: var(--muted); font-size: .8rem; margin: 0 0 4px; overflow-wrap: anywhere; }
    #DOX_topic { font-size: 1.75rem; letter-spacing: -.025em; margin: 0; overflow-wrap: anywhere; }
    #DOX_content { max-width: 1050px; margin: 0 auto; }
    #DOX_content > .container-fluid { padding: 0; }
    .custom-section { border: 1px solid var(--border); border-radius: 12px; margin-bottom: 18px; background: var(--surface); overflow: hidden; box-shadow: 0 5px 18px #0002; }
    .section-title { padding: 12px 20px; background: var(--sectiontitlebg); color: var(--sectiontitle); font-size: .85rem; font-weight: 700; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; gap: 14px; }
    .section-content { color: var(--sectioncontent); padding: 20px; overflow-wrap: anywhere; }
    .section-content > :last-child { margin-bottom: 0; }
    .dox-empty { padding: 28px; border: 1px dashed var(--border); border-radius: 12px; color: var(--muted); }
    .DOX_intro { color: var(--text); }
    .DOX_intro .p-5 { padding: 28px !important; background: var(--surface); border: 1px solid var(--border); border-radius: 12px; }
    .DOX_intro h1 { font-size: 1.6rem; }
    .DOX_intro .lead { font-size: 1rem; color: var(--muted); }
    pre { white-space: pre-wrap !important; overflow-wrap: anywhere; border-radius: 8px; font-size: .9rem; }
    .copy-to-clipboard-button { background: var(--button-background); color: var(--button-text); border: 1px solid var(--button-border); border-radius: 6px; padding: 5px 12px; cursor: pointer; font-size: .8rem; }
    .copy-to-clipboard-button:hover { background: var(--button-hover); }
    .section-content table { color: var(--text); --bs-table-bg: transparent; --bs-table-color: var(--text); --bs-table-border-color: var(--border); --bs-table-striped-color: var(--text); }

    /* Narrow screens retain both navigation and content without horizontal page overflow. */
    @media (max-width: 760px) {
        #titlebg, #DOX_breadcrumb-wrapper { padding-left: 20px; padding-right: 20px; }
        .dox-workspace { grid-template-columns: 1fr; }
        #DOX_navmenu_wrapper { border-right: 0; border-bottom: 1px solid var(--border); padding: 18px; }
        #DOX_navmenu { display: grid; grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); }
        #DOX_content_wrapper { padding: 24px 18px 40px; }
        .section-content { padding: 16px; }
    }
]];
