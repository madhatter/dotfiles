-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")

-- {{{ Error handling
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
    awesome.connect_signal("debug::error", function (err)
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

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/madhatter/.config/awesome/themes/blue/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ "term", "code", "mail", "web", "irc", "media", "grfx", "vm" }, s,
			{ layouts[2], layouts[6], layouts[6], layouts[6], layouts[6], layouts[1], layouts[1], layouts[1] })
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
clockicon = wibox.widget.imagebox()
clockicon:set_image(beautiful.widget_clock)
mytextclock = awful.widget.textclock()

-- System
sysicon = wibox.widget.imagebox()
sysicon:set_image(beautiful.widget_sys)

syswidget = wibox.widget.textbox()
vicious.register( syswidget, vicious.widgets.os, "$2")

-- Uptime
uptimeicon = wibox.widget.imagebox()
uptimeicon:set_image(beautiful.widget_uptime)

uptimewidget = wibox.widget.textbox()
vicious.register( uptimewidget, vicious.widgets.uptime, "$1d $2.$3'")

uptimeicon:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () exitmenu:toggle() end )
				   ))

uptimewidget:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () exitmenu:toggle() end )
				   ))

-- Temp Icon
tempicon = wibox.widget.imagebox()
tempicon:set_image(beautiful.widget_temp)

-- Temp Widget
tempwidget = wibox.widget.textbox()
vicious.register(tempwidget, vicious.widgets.thermal, "$1°C", 9, "thermal_zone0")

tempicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -e sudo powertop", false) end)
))

-- GMail widget and tooltip
mygmail = wibox.widget.textbox()
gmail_t = awful.tooltip({ objects = { mygmail },})

mygmailimg = wibox.widget.imagebox()
mygmailimg:set_image(beautiful.widget_gmail)

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
pacicon = wibox.widget.imagebox()
pacicon:set_image(beautiful.widget_pac)
-- Pacman Widget
pacwidget = wibox.widget.textbox()
pacwidget_t = awful.tooltip({ objects = { pacwidget},})
vicious.register(pacwidget, vicious.widgets.pkg,
                function(widget,args)
                    local io = { popen = io.popen }
                    local s = io.popen("pacman -Qu --dbpath /home/madhatter/pacman")
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
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)

-- CPU Widget
cpubar = awful.widget.progressbar()
cpubar:set_width(50)
cpubar:set_height(6)
cpubar:set_vertical(false)
cpubar:set_background_color("#434343")
--cpubar:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal, beautiful.fg_normal, beautiful.bar })
--local stats_grad = { type = "linear", from = { 0, 0 }, to = { 100, 0 }, stops = { { 0, "#0000ff" }, { 0.5, "#00ff00" }, { 1, "#ff0000" }}}
local stats_grad = { type = "linear", from = { 0, 0 }, to = { 50, 0 }, stops = { { 0, beautiful.fg_normal }, { 0.5, beautiful.fg_normal }, { 1, beautiful.fg_normal }}}
cpubar:set_color(stats_grad)
vicious.register(cpubar, vicious.widgets.cpu, "$1", 3)
cpubar_with_margin = wibox.layout.margin()
cpubar_with_margin:set_widget(cpubar)
cpubar_with_margin:set_top(5)
cpubar_with_margin:set_bottom(5)

-- Cpu usage
cpuwidget = wibox.widget.textbox()
vicious.register( cpuwidget, vicious.widgets.cpu, "$2% $3%", 3)

cpuicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -e htop", false) end)
))

-- BATT Icon
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_batt)

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
--batbar:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal, beautiful.fg_normal, beautiful.bar })
batbar:set_color(stats_grad)
batbar_with_margin = wibox.layout.margin()
batbar_with_margin:set_widget(batbar)
batbar_with_margin:set_top(5)
batbar_with_margin:set_bottom(5)
vicious.register( batbar, vicious.widgets.bat, "$2", 1, "BAT0" )

batwidget = wibox.widget.textbox()
vicious.register( batwidget, vicious.widgets.bat, "$2", 1, "BAT0" )
baticon:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () powermenu:toggle() end )
				   ))

batwidget:buttons(awful.util.table.join(
					 awful.button({ }, 1, function () powermenu:toggle() end )
				   ))

-- Vol Icon
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
-- Vol bar Widget
volbar = awful.widget.progressbar()
volbar:set_width(50)
volbar:set_height(6)
volbar:set_vertical(false)
volbar:set_background_color("#434343")
volbar:set_border_color(nil)
--volbar:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal, beautiful.fg_normal, beautiful.bar })
local volume_grad = { type = "linear", from = { 0, 0 }, to = { 100, 0 }, stops = { { 0, beautiful.fg_normal }, { 0.5, beautiful.fg_normal }, { 1, beautiful.fg_normal }}}
volbar:set_color(volume_grad)
volbar_with_margin = wibox.layout.margin()
volbar_with_margin:set_widget(volbar)
volbar_with_margin:set_top(5)
volbar_with_margin:set_bottom(5)
vicious.register(volbar, vicious.widgets.volume,  "$1",  1, "Master")

-- Sound volume
volumewidget = wibox.widget.textbox()
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
netdownicon = wibox.widget.imagebox()
netdownicon:set_image(beautiful.widget_netdown)

netdowninfo = wibox.widget.textbox()
vicious.register(netdowninfo, vicious.widgets.net, "${eth0 down_kb}", 1)

netupicon = wibox.widget.imagebox()
netupicon:set_image(beautiful.widget_netup)

netupinfo = wibox.widget.textbox()
vicious.register(netupinfo, vicious.widgets.net, "${eth0 up_kb}", 1)

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
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
-- Initialize MEMBar widget
membar = awful.widget.progressbar()
membar:set_width(50)
membar:set_height(6)
membar:set_vertical(false)
membar:set_background_color("#434343")
membar:set_border_color(nil)
--membar:set_gradient_colors({ beautiful.fg_normal, beautiful.fg_normal, beautiful.fg_normal, beautiful.bar })
local memory_grad = { type = "linear", from = { 0, 0 }, to = { 100, 0 }, stops = { { 0, beautiful.fg_normal }, { 0.5, beautiful.fg_normal }, { 1, beautiful.fg_normal }}}
membar:set_color(memory_grad)
membar_with_margin = wibox.layout.margin()
membar_with_margin:set_widget(membar)
membar_with_margin:set_top(5)
membar_with_margin:set_bottom(5)
vicious.register(membar, vicious.widgets.mem, "$1", 1)

-- Memory usage
memwidget = wibox.widget.textbox()
vicious.register(memwidget, vicious.widgets.mem, "$2M", 1)

memicon:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.util.spawn("urxvtc -e saidar -c", false) end)
))


-- MPD Icon
mpdicon = wibox.widget.imagebox()
mpdicon:set_image(beautiful.widget_mpd)
-- Initialize MPD Widget
mpdwidget = wibox.widget.textbox()
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
rbracket = wibox.widget.textbox()
rbracket:set_text("]")
lbracket = wibox.widget.textbox()
lbracket:set_text("[")
line = wibox.widget.textbox()
line:set_text("|")

-- Space
space = wibox.widget.textbox()
space:set_text(" ")



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
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
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
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

	-- The upper wibox layout
    -- Create the upper wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s, border_width = 0, height = 16 })

    -- Widgets that are aligned to the left
    local upper_left_layout = wibox.layout.fixed.horizontal()
    upper_left_layout:add(mylauncher)
    upper_left_layout:add(mytaglist[s])
    upper_left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local upper_right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then upper_right_layout:add(wibox.widget.systray()) end
	upper_right_layout:add(space)
	upper_right_layout:add(sysicon)
	upper_right_layout:add(syswidget)
	upper_right_layout:add(space)
	upper_right_layout:add(clockicon)
    upper_right_layout:add(mytextclock)
    upper_right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local upper_layout = wibox.layout.align.horizontal()
    upper_layout:set_left(upper_left_layout)
    upper_layout:set_middle(mytasklist[s])
    upper_layout:set_right(upper_right_layout)

    mywibox[s]:set_widget(upper_layout)

	-- The bottom wibox layout
	mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 16 })

    -- Widgets that are aligned to the left
    local bottom_left_layout = wibox.layout.fixed.horizontal()
	bottom_left_layout:add(lbracket)
	bottom_left_layout:add(volicon)
	bottom_left_layout:add(space)
	bottom_left_layout:add(volbar_with_margin)
	bottom_left_layout:add(space)
	bottom_left_layout:add(space)
	bottom_left_layout:add(volumewidget)
	bottom_left_layout:add(space)
	bottom_left_layout:add(rbracket)
	bottom_left_layout:add(space)
	bottom_left_layout:add(lbracket)
	bottom_left_layout:add(baticon)
	bottom_left_layout:add(space)
	bottom_left_layout:add(batbar_with_margin)
	bottom_left_layout:add(space)
	bottom_left_layout:add(space)
	bottom_left_layout:add(batwidget)
	bottom_left_layout:add(space)
	bottom_left_layout:add(rbracket)
	bottom_left_layout:add(space)
	bottom_left_layout:add(lbracket)
	bottom_left_layout:add(cpuicon)
	bottom_left_layout:add(space)
	bottom_left_layout:add(cpubar_with_margin)
	bottom_left_layout:add(space)
	bottom_left_layout:add(space)
	bottom_left_layout:add(cpuwidget)
	bottom_left_layout:add(space)
	bottom_left_layout:add(rbracket)
	bottom_left_layout:add(space)
	bottom_left_layout:add(lbracket)
	bottom_left_layout:add(memicon)
	bottom_left_layout:add(space)
	bottom_left_layout:add(membar_with_margin)
	bottom_left_layout:add(space)
	bottom_left_layout:add(space)
	bottom_left_layout:add(memwidget)
	bottom_left_layout:add(space)
	bottom_left_layout:add(rbracket)
	
    -- Widgets that are aligned to the right
    local bottom_right_layout = wibox.layout.fixed.horizontal()
	bottom_right_layout:add(space)
	bottom_right_layout:add(lbracket)
	bottom_right_layout:add(space)
	bottom_right_layout:add(mpdicon)
	bottom_right_layout:add(space)
	bottom_right_layout:add(mpdwidget)
	bottom_right_layout:add(space)
	bottom_right_layout:add(rbracket)
	bottom_right_layout:add(space)
	bottom_right_layout:add(lbracket)
	bottom_right_layout:add(netupicon)
	bottom_right_layout:add(netupinfo)
	bottom_right_layout:add(space)
	bottom_right_layout:add(netdownicon)
	bottom_right_layout:add(netdowninfo)
	bottom_right_layout:add(space)
	bottom_right_layout:add(rbracket)
	bottom_right_layout:add(space)
	bottom_right_layout:add(lbracket)
	bottom_right_layout:add(space)
	bottom_right_layout:add(mygmailimg)
	bottom_right_layout:add(space)
	bottom_right_layout:add(mygmail)
	bottom_right_layout:add(space)
	bottom_right_layout:add(rbracket)
	bottom_right_layout:add(space)
	bottom_right_layout:add(lbracket)
	bottom_right_layout:add(space)
	bottom_right_layout:add(pacicon)
	bottom_right_layout:add(space)
	bottom_right_layout:add(pacwidget)
	bottom_right_layout:add(space)
	bottom_right_layout:add(rbracket)
	bottom_right_layout:add(space)
	bottom_right_layout:add(lbracket)
	bottom_right_layout:add(space)
	bottom_right_layout:add(uptimeicon)
	bottom_right_layout:add(space)
	bottom_right_layout:add(uptimewidget)
	bottom_right_layout:add(space)
	bottom_right_layout:add(rbracket)

    -- Now bring it all together (with the tasklist in the middle)
    local bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(bottom_left_layout)
    --bottom_layout:set_middle(mytasklist[s])
    bottom_layout:set_right(bottom_right_layout)

    mybottomwibox[s]:set_widget(bottom_layout)
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
    awful.key({ modkey,           }, "a", function () awful.util.spawn("slimlock " ) end),
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

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
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
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
   keynumber = math.min(9, math.max(#tags[s], keynumber))
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
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Vlc" },
      properties = { tag = tags[6], switchtotag = true } },
    { rule = { class = "Gimp" },
      properties = { tag = tags[7] } },
    { rule = { instance = "plugin-container" },
      properties = { floating = true } },
    { rule = { class = "Google Chrome" },
      properties = { tag = tags[4], switchtotag = true } },
    { rule = { class = "Skype" },
      properties = { tag = tags[5], floating = true, switchtotag = true } },
    { rule = { class = "Gpicview" },
      properties = { tag = tags[7], switchtotag = true } },
    { rule = { class = "Qalculate-gtk" },
      properties = { tag = tags[6], switchtotag = true } },
    { rule = { class = "Thunar" },
      properties = { tag = tags[3], switchtotag = true } },
    { rule = { class = "Gnome-mplayer" },
      properties = { tag = tags[6], switchtotag = true, floating = true } },
    { rule = { class = "MPlayer" },
      properties = { tag = tags[6], switchtotag = true, floating = true } }
	-- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
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

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
