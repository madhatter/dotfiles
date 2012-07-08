------------------------------------------------
--              Awesome rc.lua                --    
--           by TheImmortalPhoenix            --
-- http://theimmortalphoenix.deviantart.com/  --
------------------------------------------------


-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
require("revelation")
-- Notification library
require("naughty")
require("vicious")

--}}}

-- {{{ Error Handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.add_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable Definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/madhatter/.config/awesome/themes/blue/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
gui_editor = "geany"
browser = "firefox"
fileman = "dolphin /home/madhatter/"
cli_fileman = terminal .. " -e ranger "
music = terminal .. " -e ncmpcpp "
chat = terminal .. " -e weechat-curses "
tasks = terminal .. " -e sudo htop "

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,             -- 1
    awful.layout.suit.tile,                 -- 2
    awful.layout.suit.tile.left,            -- 3
    awful.layout.suit.tile.bottom,          -- 4
    awful.layout.suit.tile.top,             -- 5
    awful.layout.suit.fair,                 -- 6
    awful.layout.suit.fair.horizontal,      -- 7
    awful.layout.suit.spiral,               -- 8
    awful.layout.suit.spiral.dwindle,       -- 9
    awful.layout.suit.max,                  -- 10
    --awful.layout.suit.max.fullscreen,     -- 11
    --awful.layout.suit.magnifier           -- 12
}
-- }}}

-- {{{ Tags

-- Tags With Icons
-- Define a tag table which hold all screen tags.

tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    -- tags[s] = awful.tag({ "⢷", "⣨", "⡪", "⣌", "⣪", "⡝"}, s,
    -- tags[s] = awful.tag({ "¹ term", "´ web", "² files", "© chat", "ê media", "º work" }, s,
    tags[s] = awful.tag({ "term", "web", "mail", "news", "chat", "media", "grfx", "vm" }, s,
    -- tags[s] = awful.tag({ "¹", "´", "²", "©", "ê", "º" }, s,
  		       { layouts[6], layouts[6], layouts[6],
 			  layouts[6], layouts[6], layouts[1], layouts[1], layouts[1]
 		       })
    
    -- awful.tag.seticon("/home/madhatter/.config/awesome/themes/blue/widgets/arch_10x10.png", tags[s][1])
    -- awful.tag.seticon("/home/madhatter/.config/awesome/themes/blue/widgets/cat.png", tags[s][2])
    -- awful.tag.seticon("/home/madhatter/.config/awesome/themes/blue/widgets/dish.png", tags[s][3])
    -- awful.tag.seticon("/home/madhatter/.config/awesome/themes/blue/widgets/mail.png", tags[s][4])
    -- awful.tag.seticon("/home/madhatter/.config/awesome/themes/blue/widgets/phones.png", tags[s][5])
    -- awful.tag.seticon("/home/madhatter/.config/awesome/themes/blue/widgets/pacman.png", tags[s][6])
    
end

-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myaccessories = {
   { "Archives", "ark" },
   { "Charmap", "gucharmap" },
   { "Convertall", "convertall" },
   { "Converter", "cute-converter" },
   { "Geany", "geany" },
   { "Gvim", "gvim" },
   { "Vim", editor_cmd }
}
myinternet = {
    { "Aircrack", "sudo wepcrack" },
    { "Amule", "amule" },
    { "Chat", "gajim" },
    { "Dropbox", "dropboxd" },
    { "Firefox" , browser },
    { "IRC Client" , chat },
    { "jDownloader" , "jdownloader" },
    { "Mail" , "thunderbird" },
    { "Skype" , "skype" },
    { "Streaming" , "filmlimitless" },
    { "Torrent" , "qbittorrent" },
    { "Torrent Search" , "torrent-search" },
}

mymedia = {
    { "Avidemux" , "avidemux2_gtk" },
    { "Burn Tool" , "k3b" },
    { "Mplayer" , "gnome-mplayer" },
    { "Ncmpcpp" , music },
    { "Pandora" , "pithos" },
    { "Record Desktop" , "gtk-recordMyDesktop --no-frame" },
    { "UNetBootin" , "sudo unetbootin" },
    { "Vlc" , "vlc" },
    --{ "Webcam" , "mplayer tv:// -tv driver=v4l2:width=640:height=480:device=/dev/video0 -fps 25 -vf screenshot" }
    { "Webcam" , "wxcam" }
}

mygraphics = {
    { "Blender" , "blender" },
    { "Colors" , "kcolorchooser" },
    { "Gimp" , "gimp-2.6" },
    { "Gpicview" , "gpicview" },
    { "Scanner" , "iscan" },
    { "Xournal" , "xournal" }
}

myoffice = {
    { "Formula" , "lomath" },
    { "Impress" , "loimpress" },
    { "Okular" , "okular" },
    { "Spreadsheet" , "localc" },
    { "Writer" , "lowriter" }
}

mysystem = {
    { "Appearance" , "lxappearance" },
    { "Cleaning" , "bleachbit" },
    { "HardInfo" , "hardinfo" },
    { "KDE Setting" , "systemsettings" },
    { "Powertop" , terminal .. " -e sudo powertop " },
    { "Qtconfig" , "qtconfig" },
    { "Task Manager" , tasks }
}

mysystemroot = {
    { "Appearance" , "sudo lxappearance" },
    { "Catalyst" , "sudo amdcccle" },
    { "Cleaning" , "sudo bleachbit" },
    { "Disk Utility" , "sudo palimpsest" },
    { "KDE Settings" , "sudo systemsettings" },
    { "Partitions" , "sudo /usr/sbin/gparted" },
    { "Qtconfig" , "sudo qtconfig" }
}

myfolders = {
    { "Apps" , "sudo dolphin /usr/share/applications" },
    { "Arch" , "sudo dolphin /" },
    { "Boot" , "sudo dolphin /boot" },
    { "Configs" , "dolphin /media/Winzoz/Users/madhatter/Dropbox/Linux/ArchLinux-Config" },
    { "Etc" , "sudo dolphin /etc" },
    { "Documents" , "dolphin /media/Data/Documents" },
    { "Downloads" , "dolphin /media/Data/Downloads" },
    { "Dropbox" , "dolphin /media/Winzoz/Users/madhatter/Dropbox" },
    { "Home" , "dolphin /home/madhatter" },
    { "Icons" , "sudo dolphin /usr/share/icons" },
    { "Media" , "dolphin /media" },
    { "Motion" , "dolphin /home/madhatter/.motion/files" },
    { "Music" , "dolphin /media/Data/Music" },
    { "Pictures" , "dolphin /media/Winzoz/Users/madhatter/Pictures" },
    { "Pixmaps" , "sudo dolphin /usr/share/pixmaps" },
    { "Root" , "sudo dolphin /root" },
    { "Themes" , "sudo dolphin /usr/share/themes" },
    { "Var" , "sudo dolphin /var" },
    { "Videos" , "dolphin /media/Data/Videos" }
}

mystudy = {
    { "Calculator" , "qalculate-gtk" },
    { "Chemistry" , "gelemental" },
    { "Circuits" , "sudo ktechlab" },
    { "Esse3" , "firefox https://poliba.esse3.cineca.it/Home.do;jsessionid=39B376CBEAB698B9BD68256B07C36505.jvm_poliba_esse3web05" };
    { "Fataing" , "firefox http://www.fataing.poliba.it/login.php" },
    { "Graphs" , "kmplot" },
    { "Lectures" , "dolphin /media/Data/University" },
    { "Notes" , "dolphin /media/Winzoz/Users/madhatter/Dropbox/Università" }
}

mygames = {
   { "Blocks" , "gnotski" },
   { "Bovo" , "bovo" },
   { "Brainy" , "gbrainy" },
   { "Breakout" , "kbreakout" },
   { "Chess" , "pychess" },
   { "Four In Line" , "kfourinline" },
   { "Granatier" , "granatier" },
   { "Katomic" , "katomic" },
   { "Kmahjongg" , "kmahjongg" },
   { "Mahjongg" , "mahjongg" },
   { "Mines" , "kmines" },
   { "Puzzles" , "palapeli" },
   { "Reversi" , "kreversi" },
   { "Sudoku" , "ksudoku" },
   { "Sudoku 2" , "gnome-sudoku" },
   { "Tetravex" , "gnotravex" },
   { "Tetris" , "kblocks" },
   { "Tetris 2" , "quadrapassel" },
   { "Urban Terror" , "urbanterror" }
}

myexit = {
   { "Hibernate" , "sudo pm-hibernate" },
   { "Shutdown" , "sudo halt" },
   { "Reboot" , "sudo reboot" },
   { "Quit" , awesome.quit }
}
mymainmenu = awful.menu({ items = { 
	     		  	{ "File Manager", fileman },
	     		  	{ "Terminal", terminal },
				    { "Firefox" , browser },
                    { " ", nil, nil}, -- separator
				    { "Folders" , myfolders },
                    { " ", nil, nil}, -- separator
				    { "Accessories" , myaccessories },
				    { "Games" , mygames },
				    { "Graphics" , mygraphics },
				    { "Internet" , myinternet },
				    { "Multimedia" , mymedia },
				    { "Office" , myoffice },
				    { "System" , mysystem },
				    { "System Root" , mysystemroot },
				    { "University" , mystudy },
                    { " ", nil, nil}, -- separator
				    { "Search" , "sudo kfind" },
				    { "Exit", myexit },
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox

-- Weather widget
-- weatherwidget = widget({ type = "textbox" })
-- weather_t = awful.tooltip({ objects = { weatherwidget },})

-- vicious.register(weatherwidget, vicious.widgets.weather,
--                 function (widget, args)
--                     weather_t:set_text("City: " .. args["{city}"] .."\nWind: " .. args["{windmph}"] .. " mp/h " .. args["{wind}"] .. "\nSky: " .. args["{sky}"] .. "\nHumidity: " .. args["{humid}"] .. "%")
--                     return args["{tempf}"] .. "F"
--                 end, 1, "ITXX0158")
                --'1800': check every 30 minutes.
                --'CYUL': the Montreal ICAO code.


-- Create a textclock widget
clockicon = widget({ type = "imagebox"})
clockicon.image = image(beautiful.widget_clock)
mytextclock = awful.widget.textclock({ align = "right" })
-- Calendar widget to attach to the textclock
require('calendar2')
calendar2.addCalendarToWidget(mytextclock)

-- System
sysicon = widget({ type = "imagebox" })
sysicon.image = image(beautiful.widget_sys)
sysicon.align = "middle"

syswidget = widget({ type = "textbox" })
vicious.register( syswidget, vicious.widgets.os, "$2")

awful.widget.layout.margins[sysicon] = { top = 0 }

-- Uptime

exitmenu = awful.menu({items = {
			     { "Hibernate" , function () awful.util.spawn("sudo pm-hibernate", false) end },
			     { "Shutdown" , function () awful.util.spawn("sudo halt", false) end },
			     { "Restart" , awesome.restart },
			     { "Reboot" , function () awful.util.spawn("sudo reboot", false) end },
			     { "Quit" , awesome.quit }
			  }
		       })

uptimeicon = widget({ type = "imagebox" })
uptimeicon.image = image(beautiful.widget_uptime)

uptimewidget = widget({ type = "textbox" })
vicious.register( uptimewidget, vicious.widgets.uptime, "$2.$3'")

uptimeicon:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () exitmenu:toggle() end )
				   ))

uptimewidget:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () exitmenu:toggle() end )
				   ))

-- Temp Icon
tempicon = widget({ type = "imagebox" })
tempicon.image = image(beautiful.widget_temp)
-- Temp Widget
tempwidget = widget({ type = "textbox" })
vicious.register(tempwidget, vicious.widgets.thermal, "$1°C", 9, "thermal_zone0")

tempicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -e sudo powertop", false) end)
))


-- gmail widget and tooltip
mygmail = widget({ type = "textbox" })
gmail_t = awful.tooltip({ objects = { mygmail },})

mygmailimg = widget({ type = "imagebox" })
mygmailimg.image = image(beautiful.widget_gmail)

vicious.register(mygmail, vicious.widgets.gmail,
                function (widget, args)
                    gmail_t:set_text(args["{subject}"])
                    gmail_t:add_to_object(mygmailimg)
                    return args["{count}"]
                 end, 120) 
                 --the '120' here means check every 2 minutes.

mygmailimg:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("thunderbird", false) end)
))

-- Pacman Icon
pacicon = widget({type = "imagebox" })
pacicon.image = image(beautiful.widget_pac)
-- Pacman Widget
pacwidget = widget({type = "textbox"})
pacwidget_t = awful.tooltip({ objects = { pacwidget},})
vicious.register(pacwidget, vicious.widgets.pkg,
                function(widget,args)
                    local io = { popen = io.popen }
                    local s = io.popen("yaourt -Qu")
                    local str = ''
                    for line in s:lines() do
                        str = str .. line .. "\n"
                    end
                    pacwidget_t:set_text(str)
                    s:close()
                    return " " .. args[1]
                end, 10, "Arch")
                --'1800' means check every 30 minutes

pacicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -e yaourt -Syua", false) end)
))

-- CPU Icon
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
-- CPU Widget
cpubar = awful.widget.progressbar()
cpubar:set_width(50)
cpubar:set_height(6)
cpubar:set_vertical(false)
cpubar:set_background_color("#434343")
cpubar:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal, beautiful.fg_normal, beautiful.bar })
vicious.register(cpubar, vicious.widgets.cpu, "$1", 3)
awful.widget.layout.margins[cpubar.widget] = { top = 5 }

-- Cpu usage
cpuwidget = widget({ type = "textbox" })
vicious.register( cpuwidget, vicious.widgets.cpu, "$2% $3% $4% $5%", 3)

cpuicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -e htop", false) end)
))

-- BATT Icon
baticon = widget ({type = "imagebox" })
baticon.image = image(beautiful.widget_batt)

-- Battery usage
powermenu = awful.menu({items = {
			     { "Auto" , function () awful.util.spawn("sudo cpufreq-set -r -g ondemand", false) end },
			     { "Ondemand" , function () awful.util.spawn("sudo cpufreq-set -r -g ondemand", false) end },
			     { "Powersave" , function () awful.util.spawn("sudo cpufreq-set -r -g powersave", false) end },
			     { "Performance" , function () awful.util.spawn("sudo cpufreq-set -r -g performance", false) end }
			  }
		       })

-- Initialize BATT widget progressbar
batbar = awful.widget.progressbar()
batbar:set_width(50)
batbar:set_height(6)
batbar:set_vertical(false)
batbar:set_background_color("#434343")
batbar:set_border_color(nil)
batbar:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal, beautiful.fg_normal, beautiful.bar })
awful.widget.layout.margins[batbar.widget] = { top = 5 }
vicious.register( batbar, vicious.widgets.bat, "$2", 1, "BAT0" )

batwidget = widget({ type = "textbox" })
vicious.register( batwidget, vicious.widgets.bat, "$2", 1, "BAT0" )
baticon:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () powermenu:toggle() end )
				   ))

batwidget:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () powermenu:toggle() end )
				   ))

-- Vol Icon
volicon = widget ({type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
-- Vol bar Widget
volbar = awful.widget.progressbar()
volbar:set_width(50)
volbar:set_height(6)
volbar:set_vertical(false)
volbar:set_background_color("#434343")
volbar:set_border_color(nil)
volbar:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal, beautiful.fg_normal, beautiful.bar })
awful.widget.layout.margins[volbar.widget] = { top = 5 }
vicious.register(volbar, vicious.widgets.volume,  "$1",  1, "Master")


-- Sound volume
volumewidget = widget ({ type = "textbox" })
vicious.register( volumewidget, vicious.widgets.volume, "$1", 1, "Master" )

volicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("amixer -q sset Master toggle", false) end),
    awful.button({ }, 3, function () awful.util.spawn("urxvtc -e alsamixer", true) end),
    awful.button({ }, 4, function () awful.util.spawn("amixer -q sset Master 1dB+", false) end),
    awful.button({ }, 5, function () awful.util.spawn("amixer -q sset Master 1dB-", false) end)
))

volumewidget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("amixer -q sset Master toggle", false) end),
    awful.button({ }, 3, function () awful.util.spawn("urxvtc -e alsamixer", true) end),
    awful.button({ }, 4, function () awful.util.spawn("amixer -q sset Master 1dB+", false) end),
    awful.button({ }, 5, function () awful.util.spawn("amixer -q sset Master 1dB-", false) end)
))
-- Net Widget

netdownicon = widget ({ type = "imagebox" })
netdownicon.image = image(beautiful.widget_netdown)
netdownicon.align = "middle"

netdowninfo = widget({ type = "textbox" })
vicious.register(netdowninfo, vicious.widgets.net, "${eth0 down_kb}", 1)

-- netdowninfo:buttons(awful.util.table.join(
--     awful.button({ }, 1, function () awful.util.spawn("sudo netcfg home-wireless-wpa", false) end),
--     awful.button({ }, 3, function () awful.util.spawn("sudo netcfg down home-wireless-wpa", false) end)
-- ))


netupicon = widget ({ type = "imagebox" })
netupicon.image = image(beautiful.widget_netup)
netupicon.align = "middle"

netupinfo = widget({ type = "textbox" })
vicious.register(netupinfo, vicious.widgets.net, "${eth0 up_kb}", 1)

-- netupinfo:buttons(awful.util.table.join(
--     awful.button({ }, 1, function () awful.util.spawn("sudo netcfg home-ethernet", false) end),
--     awful.button({ }, 3, function () awful.util.spawn("sudo netcfg down home-ethernet", false) end)
-- ))

netmenu = awful.menu({items = {
			     { "Change ip" , function () awful.util.spawn("sh ./.scripts/restartwifi", false) end },
			     { "Connect Lan" , function () awful.util.spawn("urxvtc -hold -e sudo netcfg home-ethernet", false) end },
			     { "Connect Wifi" , function () awful.util.spawn("urxvtc -hold -e sudo netcfg home-wireless-wpa", false) end },
			     { "Disconnect Lan" , function () awful.util.spawn("urxvtc -hold -e sudo netcfg down home-ethernet", false) end },
			     { "Disconnect Wifi" , function () awful.util.spawn("urxvtc -hold -e sudo netcfg down home-wireless-wpa", false) end }
			  }
		       })

netdownicon:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () netmenu:toggle() end )
				   ))
netdowninfo:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () netmenu:toggle() end )
				   ))
netupicon:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () netmenu:toggle() end )
				   ))
netupinfo:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () netmenu:toggle() end )
				   ))
-- MEM icon
memicon = widget ({type = "imagebox" })
memicon.image = image(beautiful.widget_mem)
-- Initialize MEMBar widget
membar = awful.widget.progressbar()
membar:set_width(50)
membar:set_height(6)
membar:set_vertical(false)
membar:set_background_color("#434343")
membar:set_border_color(nil)
membar:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal, beautiful.fg_normal, beautiful.bar })
awful.widget.layout.margins[membar.widget] = { top = 5 }
vicious.register(membar, vicious.widgets.mem, "$1", 1)

-- Memory usage
memwidget = widget({ type = "textbox" })
vicious.register(memwidget, vicious.widgets.mem, "$2M", 1)

memicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -e saidar -c", false) end)
))

-- MPD Icon
mpdicon = widget({ type = "imagebox" })
mpdicon.image = image(beautiful.widget_mpd)
-- Initialize MPD Widget
mpdwidget = widget({ type = "textbox" })
vicious.register(mpdwidget, vicious.widgets.mpd,
    function (widget, args)
        if args["{state}"] == "Stop" then 
            return "Stopped"
        elseif args["{state}"] == "Pause" then
            return "Paused"
        else 
            return args["{Title}"]..' - '.. args["{Artist}"]
        end
    end, 0.5)

mpdicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -e ncmpcpp", false) end)
))

-- Spacers
rbracket = widget({type = "textbox" })
rbracket.text = "]"
lbracket = widget({type = "textbox" })
lbracket.text = "["
line = widget({type = "textbox" })
line.text = "|"

-- Space
space = widget({ type = "textbox" })
space.text = " "

-- MPD controls
music_play = awful.widget.launcher({
    image = beautiful.widget_play,
    command = "ncmpcpp toggle && echo -e 'vicious.force({ mpdwidget, })' | awesome-client"
  })

  music_pause = awful.widget.launcher({
    image = beautiful.widget_pause,
    command = "ncmpcpp toggle && echo -e 'vicious.force({ mpdwidget, })' | awesome-client"
  })
  music_pause.visible = false

  music_stop = awful.widget.launcher({
    image = beautiful.widget_stop,
    command = "ncmpcpp stop && echo -e 'vicious.force({ mpdwidget, })' | awesome-client"
  })

  music_prev = awful.widget.launcher({
    image = beautiful.widget_prev,
    command = "ncmpcpp prev && echo -e 'vicious.force({ mpdwidget, })' | awesome-client"
  })

  music_next = awful.widget.launcher({
    image = beautiful.widget_next,
    command = "ncmpcpp next && echo -e 'vicious.force({ mpdwidget, })' | awesome-client"
  })

-- Pianobar Icon
-- pandoraicon = widget({ type = "imagebox" })
-- pandoraicon.image = image(beautiful.widget_pandora)

-- pandoraicon:buttons(awful.util.table.join(
--     awful.button({ }, 1, function () awful.util.spawn("urxvtc -e tmux -c pianobar", false) end),
--     awful.button({ }, 2, function () awful.util.spawn("urxvtc -e tmux attach", false) end)
-- ))

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mystatusbar = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 2, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:kill() end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the upper wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = 0, height = 16 })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            space,
            mytaglist[s],
            space,
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        space,
        mytextclock,
        clockicon,
        space,
        space,
        syswidget,
        -- space,
        -- sysicon,
        space,
        space,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
     mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 16 })

     mybottomwibox[s].widgets = {
     {
        space, lbracket, volicon, space, volbar, space, volumewidget, space, rbracket, space, space, lbracket, baticon, space, batbar, space, batwidget, space, rbracket, space, space, lbracket, memicon, space, membar, space, memwidget, space, rbracket, space, space, lbracket, cpuicon, space, cpubar, space, cpuwidget, space, rbracket,
        layout = awful.widget.layout.horizontal.leftright
     },
        space, rbracket, uptimewidget, space, uptimeicon, lbracket, space, space, rbracket, space, tempwidget, space, tempicon, lbracket, space, space, rbracket, space, netupinfo, netupicon, space, netdowninfo, netdownicon, lbracket, space, space, rbracket, space, pacwidget, pacicon, lbracket, space, space, rbracket, space, mygmail, space, mygmailimg, lbracket, space, space, rbracket, space, music_next, music_play, music_pause, music_stop, music_prev, space, mpdwidget, space, mpdicon, space, lbracket,
        layout = awful.widget.layout.horizontal.rightleft
	}
end

-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
	awful.key({ modkey,           }, "+", function () awful.util.spawn("amixer -q sset Master 5%+ " ) end),
	awful.key({ modkey,           }, "-", function () awful.util.spawn("amixer -q sset Master 5%- " ) end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     maximized_vertical = false,
                     maximized_horizontal = false,
                     buttons = clientbuttons,
	                 size_hints_honor = false
                    }
   },
    { rule = { class = "Vlc" },
      properties = { tag = tags[1][6], switchtotag = true } },
    
    { rule = { class = "Gimp" },
      properties = { tag = tags[1][7] } },

    { rule = { instance = "Blender" },
      properties = { tag = tags[1][6] } },
    
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },

    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2], switchtotag = true } },
    
    { rule = { class = "Firefox", instance = "Download" },
      properties = { tag = tags[1][2], floating = true } },

    { rule = { class = "Qbittorrent" },
      properties = { tag = tags[1][2], switchtotag = true } },
    
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][4], switchtotag = true } },
    
    { rule = { class = "Skype" },
      properties = { tag = tags[1][4], floating = true, switchtotag = true } },

    { rule = { class = "Gajim" },
      properties = { tag = tags[1][4], floating = true, switchtotag = true } },

    { rule = { class = "Gpicview" },
      properties = { tag = tags[1][7], switchtotag = true } },
    
    { rule = { class = "Qalculate-gtk" },
      properties = { tag = tags[1][6], switchtotag = true } },
    
    { rule = { class = "Convertall.py" },
      properties = { tag = tags[1][6], switchtotag = true } },
    
    { rule = { class = "QtConverter.pyw" },
      properties = { tag = tags[1][6], switchtotag = true } },
    
    { rule = { class = "Kmplot" },
      properties = { tag = tags[1][6], switchtotag = true } },
    
    { rule = { class = "Gelemental" },
      properties = { tag = tags[1][6], switchtotag = true } },
    
    { rule = { class = "Ktechlab" },
      properties = { tag = tags[1][6] } },
    
    { rule = { class = "Gucharmap" },
      properties = { tag = tags[1][3], switchtotag = true } },
    
    { rule = { class = "Thunar" },
      properties = { tag = tags[1][3], switchtotag = true } },
    
    { rule = { class = "Dolphin" },
      properties = { tag = tags[1][3], switchtotag = true } },
    
    { rule = { class = "Dolphin", name = "Moving*" },
      properties = { tag = tags[1][3], floating = true } },
    
    { rule = { class = "Dolphin", name = "Copying*" },
      properties = { tag = tags[1][3], floating = true } },
    
    { rule = { class = "Dolphin", name = "File Already Exists" },
      properties = { tag = tags[1][3], floating = true } },

    { rule = { class = "Dolphin", name = "Progress Dialog" },
      properties = { tag = tags[1][3], floating = true } },
    
    { rule = { class = "Geany" },
      properties = { tag = tags[1][3], switchtotag = true } },
    
    { rule = { class = "Gvim" },
      properties = { tag = tags[1][1], switchtotag = true } },
    
    { rule = { class = "Kcolorchooser" },
      properties = { tag = tags[1][6], switchtotag = true } },
    
    { rule = { class = "Xournal" },
      properties = { tag = tags[1][3] } },
    
    { rule = { class = "Okular" },
      properties = { tag = tags[1][3], switchtotag = true } },
    
    { rule = { class = "GWepCrackGui" },
      properties = { tag = tags[1][2], floating = true } },
    
    { rule = { class = "Amule" },
      properties = { tag = tags[1][2] } },
    
    { rule = { class = "Zenity", name = "filmlimitless" },
      properties = { tag = tags[1][5] } },
    
    { rule = { class = "Torrent-search" },
      properties = { tag = tags[1][2], switchtotag = true } },
    
    { rule = { class = "K3b" },
      properties = { tag = tags[1][5], switchtotag = true } },
    
    { rule = { class = "Avidemux2_gtk" },
      properties = { tag = tags[1][5] } },
    
    { rule = { class = "Gnome-mplayer" },
      properties = { tag = tags[1][5], switchtotag = true } },
    
    { rule = { class = "MPlayer" },
      properties = { tag = tags[1][5], switchtotag = true } },
    
    { rule = { class = "Pithos" },
      properties = { tag = tags[1][5], switchtotag = true } },
    
    { rule = { class = "Gtk-recordMyDesktop" },
      properties = { tag = tags[1][5], switchtotag = true } },
    
    { rule = { class = "Unetbootin.elf" },
      properties = { tag = tags[1][5], switchtotag = true } },
    
    { rule = { class = "Wxcam" },
      properties = { tag = tags[1][5], switchtotag = true } },

    { rule = { class = "Bleachbit" },
      properties = { tag = tags[1][3], switchtotag = true } },
    
    { rule = { class = "Amdcccle" },
      properties = { tag = tags[1][6] } },
    
    { rule = { class = "Palimpsest" },
      properties = { tag = tags[1][3], switchtotag = true } },

    { rule = { class = "Hardinfo" },
      properties = { tag = tags[1][3] } },
    
    { rule = { class = "Gpartedbin" },
      properties = { tag = tags[1][3], switchtotag = true } },

    -- { rule = { class = "Lxappearance" },
    --   properties = { tag = tags[1][6] } },
}

-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    --awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- menu.add_signal("focus", function(c)
--                              c.border_color = beautiful.border_focus
--                              c.opacity = 1
--                           end)
-- menu.add_signal("unfocus", function(c)
--                                c.border_color = beautiful.border_normal
--                                c.opacity = 1
--                             end)

-- }}}

-- {{{ Functions to help launch run commands in a terminal using ":" keyword 
function check_for_terminal (command)
   if command:sub(1,1) == ":" then
      command = terminal .. ' -e "' .. command:sub(2) .. '"'
   end
   awful.util.spawn(command)
end
   
function clean_for_completion (command, cur_pos, ncomp, shell)
   local term = false
   if command:sub(1,1) == ":" then
      term = true
      command = command:sub(2)
      cur_pos = cur_pos - 1
   end
   command, cur_pos =  awful.completion.shell(command, cur_pos,ncomp,shell)
   if term == true then
      command = ':' .. command
      cur_pos = cur_pos + 1
   end
   return command, cur_pos
end
-- }}}

-- {{{ Autostart

function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
 end

  run_once("xsetroot -cursor_name Adwaita")
  run_once("compton -cCGfF -o 0.38 -O 200 -I 200 -t 0.02 -l 0.02 -r 3.2 -D2")
  run_once("devilspie")
  run_once("urxvtd -q -f -o")
  -- run_once("wicd-client")
  run_once("sudo netcfg home-wireless-wpa")
  run_once("klipper")
  run_once("dropboxd")

-- }}}

-- {{{ Disable startup-notification globally
local oldspawn = awful.util.spawn
awful.util.spawn = function (s)
  oldspawn(s, false)
end

-- }}}
