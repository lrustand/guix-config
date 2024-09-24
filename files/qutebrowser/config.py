
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

config.load_autoconfig(False)

config.set('content.cookies.accept', 'all', 'chrome-devtools://*')
config.set('content.cookies.accept', 'all', 'devtools://*')
config.set('content.cookies.accept', 'no-3rdparty')
config.set('content.cookies.accept', 'all', 'https://usn.instructure.com/*')

config.set('content.geolocation', False)
config.set('content.canvas_reading', True)
config.set('content.webgl', True)
config.set('content.hyperlink_auditing', False)

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
    'https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-other.txt',
    'https://github.com/uBlockOrigin/uAssets/raw/master/filters/annoyances-cookies.txt',
    'https://raw.githubusercontent.com/uBlockOrigin/uAssets/master/filters/quick-fixes.txt',
]

config.set('editor.command', ["emacsclient",
                              "+{line}:{column}",
                              "{file}"])

config.set('tabs.tabs_are_windows', True)
config.set('tabs.show', 'multiple')
# Avoid browser being focused when sending commands
config.set('new_instance_open_target', 'tab-silent')

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

config.bind("u", "undo --window")
