config.load_autoconfig(False)

# * Privacy and Security

c.content.cookies.accept = 'no-3rdparty'

c.content.geolocation = False
c.content.canvas_reading = False
c.content.webgl = False
c.content.hyperlink_auditing = False

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

c.editor.command = ["emacsclient",
                    "+{line}:{column}",
                    "{file}"]

c.tabs.tabs_are_windows = True
c.tabs.show = 'multiple'
c.statusbar.show = 'never'

c.window.title_format = '{audio}{private}{current_title}'

# Avoid browser being focused when sending commands
c.new_instance_open_target = 'tab-silent'
c.new_instance_open_target_window = 'last-visible'


# * Keybinds

# Run Emacs commands with :emacsclient
c.aliases["emacsclient"] = "spawn --userscript emacsclient-wrapper "

# Insert passwords
config.bind(',p', "emacsclient '(qutebrowser-pass \"{url}\")'")
config.bind(',P', "emacsclient '(qutebrowser-pass \"{url}\" :password-only)'")
config.bind(',o', "emacsclient '(qutebrowser-pass-otp \"{url}\")'")

# Open in MPV
config.bind(';m', 'hint links spawn --detach mpv --force-window yes {hint-url}')
config.bind(',m', 'spawn --detach mpv --force-window yes {url}')

# Open urls through dmenu
config.bind("o", "emacsclient '(qutebrowser-launcher)'")
config.bind("O", "emacsclient '(qutebrowser-launcher-tab)'")
config.bind("wo", "emacsclient '(qutebrowser-launcher-window)'")
config.bind("W", "emacsclient '(qutebrowser-launcher-private)'")
config.bind("go", "emacsclient '(qutebrowser-launcher \"{url:pretty}\")'")
config.bind("gO", "emacsclient '(qutebrowser-launcher-tab \"{url:pretty}\")'")

config.bind("u", "undo --window")
config.bind("gf", "view-source --edit")

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

with config.pattern('https://usn.instructure.com/*') as p:
    p.content.cookies.accept = 'all'

with config.pattern('devtools://*') as p:
    p.content.cookies.accept = 'all'

# * Darkmode
c.colors.webpage.preferred_color_scheme = 'dark'

# * Load Emacs theme
config.source("emacs_theme.py")



# Local Variables:
# eval: (qutebrowser-config-mode)
# End:
