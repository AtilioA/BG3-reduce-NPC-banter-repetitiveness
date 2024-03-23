[size=5][b]Overview[/b][/size]
[b]Reduce NPC Banter Repetitiveness is a mod designed to reduce the frequency of repetitive NPC dialogue by introducing cooldowns to them.[/b]
It supports configurable options via a JSON file but also works out of the box and in multiplayer.

The mod offers a range of customizable features to control how in-game banter is handled in relation to the player's active character. Users can adjust the minimum distance for the mod to kick in, set the maximum occurrences of banter, and fine-tune the intervals between each occurrence, including the option for using random intervals and interval scaling based on distance. Additionally, there are specific options for vendor interactions and conditions under which the mod resets its timers.
See the settings breakdown in the Configuration section below for more details.

[line][b][size=5][b]
Installation[/b][/size][/b]
[list=1]
[*]Download the .zip file and install using BG3MM.

[/list][b][size=4]Requirements
[/size][/b][size=2][url=https://www.nexusmods.com/baldursgate3/mods/141]Mod Fixer[/url]﻿
[url=https://github.com/Norbyte/bg3se]BG3 Script Extender[/url] [size=2](you can easily install it with BG3MM through its [i]Tools[/i] tab or by pressing CTRL+SHIFT+ALT+T while its window is focused)
[line]
[/size][/size][size=5][b]Configuration[/b][/size][size=2][size=2]
When you load a save with the mod for the first time, it will automatically create an auto_send_food_to_camp_config.json file with default options.

You can easily navigate to it on Windows by pressing WIN+R and entering
[code]explorer %LocalAppData%\Larian Studios\Baldur's Gate 3\Script Extender\AutoSendFoodToCamp
[/code]
Open the JSON file with any text editor, even regular Notepad will work. Here's what each option inside does (order doesn't matter):

[size=2][size=2][font=Courier New]"GENERAL"[/font]: General settings for the mod.[font=Courier New]
   ﻿"enabled"[/font]: Set to [font=Courier New]true[/font] to activate the mod or [font=Courier New]false[/font] to disable it without uninstalling. [/size][/size]Enabled by default.

[font=Courier New]"FEATURES"[/font]: Controls various mod features.
[font=Courier New]   "min_distance"[/font]: Set to 24 meters to handle banter within this distance to your active character by the mod. [size=2]24 meters by default.[/size]
[font=Courier New]   "max_occurrences"[/font]: Set to -1 for banter to still repeat indefinitely but with different intervals from vanilla, 0 to disable repeating banter entirely. [size=2]-1 by default.[/size]
[font=Courier New]   "interval_options"[/font]:
    [font=Courier New]   - "first_silence_step"[/font]: Set to 5 seconds to postpone the first time a banter is repeated. [size=2]5 seconds by default.[/size]
    [font=Courier New]   - "min_interval_bonus"[/font]: Set to 5 seconds to add to the interval between banter occurrences. [size=2]5 seconds by default.[/size]
    [font=Courier New]   - "max_interval_bonus"[/font]: Set to 300 seconds. [size=2]300 seconds by default, -1 for indefinite increase.[/size]
    [font=Courier New]   - "random_intervals"[/font]: Set to true to randomize intervals. [size=2]True by default.[/size]
    [font=Courier New]   - "distance_factor_scaling"[/font]:
        [font=Courier New]       - "enabled"[/font]: Set to true. [size=2]Enabled by default.[/size]
        [font=Courier New]       - "min_distance"[/font]: Set to 1 meter. [size=2]1 meter by default.[/size]
        [font=Courier New]       - "max_distance"[/font]: Set to 20 meters. [size=2]20 meters by default.[/size]
        [font=Courier New]       - "min_penalty_factor"[/font]: Set to 2.0. [size=2]2.0 by default.[/size]
        [font=Courier New]       - "max_penalty_factor"[/font]: Set to 1.0. [size=2]1.0 by default.[/size]
[font=Courier New]   "vendor_options"[/font]:
    [font=Courier New]   - "enabled"[/font]: Set to true. [size=2]Enabled by default.[/size]
    [font=Courier New]   - "max_occurrences"[/font]: Set to -1 for unlimited. [size=2]-1 by default.[/size]
    [font=Courier New]   - "min_interval_bonus"[/font]: Set to 0 seconds. [size=2]0 seconds by default.[/size]
    [font=Courier New]   - "max_interval_bonus"[/font]: Set to 0 seconds, -1 for unlimited. [size=2]0 seconds by default.[/size]
[font=Courier New]   "reset_conditions"[/font]:
    [font=Courier New]   - "cleanup_on_timer"[/font]: Set to 1800 seconds to reset intervals. [size=2]1800 seconds (30 minutes) by default, -1 for never cleanup based on time.[/size]

[font=Courier New]"DEBUG"[/font]:
[font=Courier New]   "level"[/font]: Set the debug level. 0 for no debug, 1 for basic debug, and 2 for verbose debug. [size=2]0 by default.[/size]

[font=Courier New]"GENERAL"[/font]:
[font=Courier New]   "enabled"[/font]: Set to true to toggle the mod on/off. [size=2]Enabled by default.[/size]

[size=2][size=2][size=2][size=2][size=2][size=2]After making changes, load a save to reflect your changes.[/size][/size][/size][/size][/size][/size]
[/size][/size][line][size=4][b]
[/b][/size][size=5][b]Compatibility[/b][/size]
- This mod should be compatible with most game versions and other mods, as it mostly just listens to game events and does not edit existing game data.
   - Most mods that handle [i]Automated Dialogue[/i] should still be compatible, e.g. [url=https://www.nexusmods.com/baldursgate3/mods/5447?tab=posts&BH=1]More Reactive Companions[/url].

[line][size=4][b]
Special Thanks[/b][/size]
Thanks to FocusBG3 (we'll miss you, dude) for some helper functions and to Norbyte, for the Script Extender.

[size=4][b]Source Code
[/b][/size]The source code is available on [url=https://github.com/AtilioA/BG3-auto-send-food-to-camp]GitHub[/url] or by unpacking the .pak file. Endorse on Nexus and give it a star on GitHub if you liked it!
[line][center][center][b][size=4]
My mods[/size][/b][size=2]
[url=https://www.nexusmods.com/baldursgate3/mods/6995]Waypoint Inside Emerald Grove[/url] - 'adds' a waypoint inside Emerald Grove
[b][size=4][url=https://www.nexusmods.com/baldursgate3/mods/7035][size=4][size=2]Auto Send Read Books To Camp[/size][/size][/url]﻿[size=4][size=2] [/size][/size][/size][/b][size=4][size=4][size=2]- [/size][/size][/size][size=2]send read books to camp chest automatically[/size]
[url=https://www.nexusmods.com/baldursgate3/mods/6880]Auto Use Soap[/url]﻿ - automatically use soap after combat/entering camp
[url=https://www.nexusmods.com/baldursgate3/mods/6540]Send Wares To Trader[/url]﻿[b] [/b]- automatically send all party members' wares to a character that initiates a trade[b]
[/b][b][url=https://www.nexusmods.com/baldursgate3/mods/6313]Preemptively Label Containers[/url]﻿[/b] - automatically tag nearby containers with 'Empty' or their item count[b]
[/b][url=https://www.nexusmods.com/baldursgate3/mods/5899]Smart Autosaving[/url] - create conditional autosaves at set intervals
[url=https://www.nexusmods.com/baldursgate3/mods/6086]Auto Send Food To Camp[/url] - send food to camp chest automatically
[url=https://www.nexusmods.com/baldursgate3/mods/6188]Auto Lockpicking[/url] - initiate lockpicking automatically
[size=2]
[/size][url=https://ko-fi.com/volitio][img]https://raw.githubusercontent.com/doodlum/nexusmods-widgets/main/Ko-fi_40px_60fps.png[/img][/url][/size][/center][/center][center][center][size=2]﻿[/size][img]https://staticdelivery.nexusmods.com/mods/3474/images/7294/7294-1709239800-2107686729.png[/img][/center][/center]
