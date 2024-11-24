
config.load_autoconfig(False)

# * Privacy and Security

config.set('content.cookies.accept', 'all', 'chrome-devtools://*')
config.set('content.cookies.accept', 'all', 'devtools://*')
config.set('content.cookies.accept', 'no-3rdparty')
config.set('content.cookies.accept', 'all', 'https://usn.instructure.com/*')

config.set('content.geolocation', False)
config.set('content.canvas_reading', True)
config.set('content.webgl', True)
config.set('content.hyperlink_auditing', False)

# * Adblocking
# Valid values:
#   - auto: Use Brave's ABP-style adblocker if available, host blocking otherwise
#   - adblock: Use Brave's ABP-style adblocker
#   - hosts: Use hosts blocking
#   - both: Use both hosts blocking and Brave's ABP-style adblocker
c.content.blocking.method = 'both'
c.content.blocking.adblock.lists = [
    'https://easylist.to/easylist/easylist.txt',
    'https://easylist.to/easylist/easyprivacy.txt',
    #'https://easylist.to/easylist/fanboy-social.txt', Already included in fanboy-annoyance.txt
    #'https://secure.fanboy.co.nz/fanboy-cookiemonster.txt', Already included in fanboy-annoyance.txt
    'https://secure.fanboy.co.nz/fanboy-annoyance.txt',
    'https://raw.githubusercontent.com/DandelionSprout/adfilt/master/NorwegianExperimentalList%20alternate%20versions/NordicFiltersABP-Inclusion.txt',
    'https://easylist-downloads.adblockplus.org/antiadblockfilters.txt',
    'https://github.com/uBlockOrigin/uAssets/raw/master/filters/privacy.txt',
    'https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances.txt',
    'https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-others.txt',
    'https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-cookies.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/quick-fixes.txt',
]

# * EXWM stuff

config.set('editor.command', ["emacsclient",
                              "+{line}:{column}",
                              "{file}"])

config.set('tabs.tabs_are_windows', True)
config.set('tabs.show', 'multiple')

config.set('window.title_format', '{audio}{private}{current_title}{title_sep}{current_url}')

# Avoid browser being focused when sending commands
config.set('new_instance_open_target', 'tab-silent')


# * Keybinds

# Insert passwords
config.bind(',p', 'spawn --userscript qute-pass')
config.bind(',P', 'spawn --userscript qute-pass --password-only')

# Open in MPV
config.bind(';m', 'hint links spawn --detach mpv --force-window yes {hint-url}')
config.bind(',m', 'spawn --detach mpv --force-window yes {url}')

# Open urls through dmenu
config.bind("o", "spawn --userscript emacsclient-wrapper '(qute-launcher)'")
config.bind("O", "spawn --userscript emacsclient-wrapper '(qute-launcher-tab)'")
config.bind("wo", "spawn --userscript emacsclient-wrapper '(qute-launcher-window)'")
config.bind("W", "spawn --userscript emacsclient-wrapper '(qute-launcher-private)'")
config.bind("go", "spawn --userscript emacsclient-wrapper '(qute-launcher nil nil \"{url:pretty}\")'")
config.bind("gO", "spawn --userscript emacsclient-wrapper '(qute-launcher-tab nil nil \"{url:pretty}\")'")

config.bind("u", "undo --window")

config.bind('<Ctrl-g>', 'mode-leave', mode='command')
config.bind('<Ctrl-g>', 'mode-leave', mode='prompt')

# * Site-specific fixes and tweaks

with config.pattern('*://lichess.org/*') as p:
    p.hints.selectors['all'] += [
        'div.lobby__app__content.lpools > div',
        '.tabs-horiz > span:not(.active)',
        '.toggle',
        'div.lobby__app__content.lreal_time tr',
        '.orientation-white.manipulable piece.white',
        '.orientation-black.manipulable piece.black',
        '.analyse piece',
        'square.move-dest',
        '.ceval .switch',
        '.mselect',
    ]

with config.pattern('*://usn.no/*') as p:
    p.hints.selectors['all'] += [
        'usn-rail-item',
        '.tools-item',
    ]

# * Darkmode
config.set('colors.webpage.preferred_color_scheme', 'dark')

# * Load Emacs theme
config.source("emacs_theme.py")

## * Solarized Dark Colortheme
## base16-qutebrowser (https://github.com/theova/base16-qutebrowser)
## Scheme name: Solarized Dark
## Scheme author: Ethan Schoonover (modified by aramisgithub)
## Template author: theova
## Commentary: Tinted Theming: (https://github.com/tinted-theming)
#
#base00 = "#002b36"
#base01 = "#073642"
#base02 = "#586e75"
#base03 = "#657b83"
#base04 = "#839496"
#base05 = "#93a1a1"
#base06 = "#eee8d5"
#base07 = "#fdf6e3"
#base08 = "#dc322f"
#base09 = "#cb4b16"
#base0A = "#b58900"
#base0B = "#859900"
#base0C = "#2aa198"
#base0D = "#268bd2"
#base0E = "#6c71c4"
#base0F = "#d33682"
#
## set qutebrowser colors
#
## Text color of the completion widget. May be a single color to use for
## all columns or a list of three colors, one for each column.
#c.colors.completion.fg = base05
#
## Background color of the completion widget for odd rows.
#c.colors.completion.odd.bg = base01
#
## Background color of the completion widget for even rows.
#c.colors.completion.even.bg = base00
#
## Foreground color of completion widget category headers.
#c.colors.completion.category.fg = base0A
#
## Background color of the completion widget category headers.
#c.colors.completion.category.bg = base00
#
## Top border color of the completion widget category headers.
#c.colors.completion.category.border.top = base00
#
## Bottom border color of the completion widget category headers.
#c.colors.completion.category.border.bottom = base00
#
## Foreground color of the selected completion item.
#c.colors.completion.item.selected.fg = base05
#
## Background color of the selected completion item.
#c.colors.completion.item.selected.bg = base02
#
## Top border color of the selected completion item.
#c.colors.completion.item.selected.border.top = base02
#
## Bottom border color of the selected completion item.
#c.colors.completion.item.selected.border.bottom = base02
#
## Foreground color of the matched text in the selected completion item.
#c.colors.completion.item.selected.match.fg = base0B
#
## Foreground color of the matched text in the completion.
#c.colors.completion.match.fg = base0B
#
## Color of the scrollbar handle in the completion view.
#c.colors.completion.scrollbar.fg = base05
#
## Color of the scrollbar in the completion view.
#c.colors.completion.scrollbar.bg = base00
#
## Background color of disabled items in the context menu.
#c.colors.contextmenu.disabled.bg = base01
#
## Foreground color of disabled items in the context menu.
#c.colors.contextmenu.disabled.fg = base04
#
## Background color of the context menu. If set to null, the Qt default is used.
#c.colors.contextmenu.menu.bg = base00
#
## Foreground color of the context menu. If set to null, the Qt default is used.
#c.colors.contextmenu.menu.fg =  base05
#
## Background color of the context menu’s selected item. If set to null, the Qt default is used.
#c.colors.contextmenu.selected.bg = base02
#
##Foreground color of the context menu’s selected item. If set to null, the Qt default is used.
#c.colors.contextmenu.selected.fg = base05
#
## Background color for the download bar.
#c.colors.downloads.bar.bg = base00
#
## Color gradient start for download text.
#c.colors.downloads.start.fg = base00
#
## Color gradient start for download backgrounds.
#c.colors.downloads.start.bg = base0D
#
## Color gradient end for download text.
#c.colors.downloads.stop.fg = base00
#
## Color gradient stop for download backgrounds.
#c.colors.downloads.stop.bg = base0C
#
## Foreground color for downloads with errors.
#c.colors.downloads.error.fg = base08
#
## Font color for hints.
#c.colors.hints.fg = base00
#
## Background color for hints. Note that you can use a `rgba(...)` value
## for transparency.
#c.colors.hints.bg = base0A
#
## Font color for the matched part of hints.
#c.colors.hints.match.fg = base05
#
## Text color for the keyhint widget.
#c.colors.keyhint.fg = base05
#
## Highlight color for keys to complete the current keychain.
#c.colors.keyhint.suffix.fg = base05
#
## Background color of the keyhint widget.
#c.colors.keyhint.bg = base00
#
## Foreground color of an error message.
#c.colors.messages.error.fg = base00
#
## Background color of an error message.
#c.colors.messages.error.bg = base08
#
## Border color of an error message.
#c.colors.messages.error.border = base08
#
## Foreground color of a warning message.
#c.colors.messages.warning.fg = base00
#
## Background color of a warning message.
#c.colors.messages.warning.bg = base0E
#
## Border color of a warning message.
#c.colors.messages.warning.border = base0E
#
## Foreground color of an info message.
#c.colors.messages.info.fg = base05
#
## Background color of an info message.
#c.colors.messages.info.bg = base00
#
## Border color of an info message.
#c.colors.messages.info.border = base00
#
## Foreground color for prompts.
#c.colors.prompts.fg = base05
#
## Border used around UI elements in prompts.
#c.colors.prompts.border = base00
#
## Background color for prompts.
#c.colors.prompts.bg = base00
#
## Background color for the selected item in filename prompts.
#c.colors.prompts.selected.bg = base02
#
## Foreground color for the selected item in filename prompts.
#c.colors.prompts.selected.fg = base05
#
## Foreground color of the statusbar.
#c.colors.statusbar.normal.fg = base0B
#
## Background color of the statusbar.
#c.colors.statusbar.normal.bg = base00
#
## Foreground color of the statusbar in insert mode.
#c.colors.statusbar.insert.fg = base00
#
## Background color of the statusbar in insert mode.
#c.colors.statusbar.insert.bg = base0D
#
## Foreground color of the statusbar in passthrough mode.
#c.colors.statusbar.passthrough.fg = base00
#
## Background color of the statusbar in passthrough mode.
#c.colors.statusbar.passthrough.bg = base0C
#
## Foreground color of the statusbar in private browsing mode.
#c.colors.statusbar.private.fg = base00
#
## Background color of the statusbar in private browsing mode.
#c.colors.statusbar.private.bg = base01
#
## Foreground color of the statusbar in command mode.
#c.colors.statusbar.command.fg = base05
#
## Background color of the statusbar in command mode.
#c.colors.statusbar.command.bg = base00
#
## Foreground color of the statusbar in private browsing + command mode.
#c.colors.statusbar.command.private.fg = base05
#
## Background color of the statusbar in private browsing + command mode.
#c.colors.statusbar.command.private.bg = base00
#
## Foreground color of the statusbar in caret mode.
#c.colors.statusbar.caret.fg = base00
#
## Background color of the statusbar in caret mode.
#c.colors.statusbar.caret.bg = base0E
#
## Foreground color of the statusbar in caret mode with a selection.
#c.colors.statusbar.caret.selection.fg = base00
#
## Background color of the statusbar in caret mode with a selection.
#c.colors.statusbar.caret.selection.bg = base0D
#
## Background color of the progress bar.
#c.colors.statusbar.progress.bg = base0D
#
## Default foreground color of the URL in the statusbar.
#c.colors.statusbar.url.fg = base05
#
## Foreground color of the URL in the statusbar on error.
#c.colors.statusbar.url.error.fg = base08
#
## Foreground color of the URL in the statusbar for hovered links.
#c.colors.statusbar.url.hover.fg = base05
#
## Foreground color of the URL in the statusbar on successful load
## (http).
#c.colors.statusbar.url.success.http.fg = base0C
#
## Foreground color of the URL in the statusbar on successful load
## (https).
#c.colors.statusbar.url.success.https.fg = base0B
#
## Foreground color of the URL in the statusbar when there's a warning.
#c.colors.statusbar.url.warn.fg = base0E
#
## Background color of the tab bar.
#c.colors.tabs.bar.bg = base00
#
## Color gradient start for the tab indicator.
#c.colors.tabs.indicator.start = base0D
#
## Color gradient end for the tab indicator.
#c.colors.tabs.indicator.stop = base0C
#
## Color for the tab indicator on errors.
#c.colors.tabs.indicator.error = base08
#
## Foreground color of unselected odd tabs.
#c.colors.tabs.odd.fg = base05
#
## Background color of unselected odd tabs.
#c.colors.tabs.odd.bg = base01
#
## Foreground color of unselected even tabs.
#c.colors.tabs.even.fg = base05
#
## Background color of unselected even tabs.
#c.colors.tabs.even.bg = base00
#
## Background color of pinned unselected even tabs.
#c.colors.tabs.pinned.even.bg = base0C
#
## Foreground color of pinned unselected even tabs.
#c.colors.tabs.pinned.even.fg = base07
#
## Background color of pinned unselected odd tabs.
#c.colors.tabs.pinned.odd.bg = base0B
#
## Foreground color of pinned unselected odd tabs.
#c.colors.tabs.pinned.odd.fg = base07
#
## Background color of pinned selected even tabs.
#c.colors.tabs.pinned.selected.even.bg = base02
#
## Foreground color of pinned selected even tabs.
#c.colors.tabs.pinned.selected.even.fg = base05
#
## Background color of pinned selected odd tabs.
#c.colors.tabs.pinned.selected.odd.bg = base02
#
## Foreground color of pinned selected odd tabs.
#c.colors.tabs.pinned.selected.odd.fg = base05
#
## Foreground color of selected odd tabs.
#c.colors.tabs.selected.odd.fg = base05
#
## Background color of selected odd tabs.
#c.colors.tabs.selected.odd.bg = base02
#
## Foreground color of selected even tabs.
#c.colors.tabs.selected.even.fg = base05
#
## Background color of selected even tabs.
#c.colors.tabs.selected.even.bg = base02
#
## Background color for webpages if unset (or empty to use the theme's
## color).
## c.colors.webpage.bg = base00
