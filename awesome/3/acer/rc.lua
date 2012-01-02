-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

require("vicious")
require("vicious.contrib")
require("scratch")
require("xdg-menu")
require("revelation")
-- require("blingbling")

home = os.getenv("HOME")
-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init(home .. "/.config/awesome/themes/zenburn.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
mailview = terminal .. " -e mutt -R"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
local scount = screen.count()

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.floating,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ My widgets

-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)
-- }}}
-- {{{ Volume level
volicon = widget({ type = "imagebox" })
volicon.image = image(beautiful.widget_vol)
-- Initialize widgets
volbar    = awful.widget.progressbar()
volwidget = widget({ type = "textbox" })
-- Progressbar properties
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(12):set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)
volbar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Enable caching
-- vicious.cache(vicious.widgets.volume)
-- -- Register widgets
-- vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, "Master")
-- vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, "Master")
vicious.register(volbar, vicious.contrib.pulse, "$1", 2, "alsa_output.pci-0000_00_1b.0.analog-stereo")
---volwidget:buttons(awful.util.table.join(
volbar.widget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () awful.util.spawn("pavucontrol") end),
   awful.button({ }, 4, function () vicious.contrib.pulse.add(5,"alsa_output.pci-0000_00_1b.0.analog-stereo") end),
   awful.button({ }, 5, function () vicious.contrib.pulse.add(-5,"alsa_output.pci-0000_00_1b.0.analog-stereo") end)
))
-- -- Register buttons
-- volbar.widget:buttons(awful.util.table.join(
--    awful.button({ }, 1, function () awful.util.spawn("amixer -q set Master toggle", false) end),
--    awful.button({ }, 3, function () awful.util.spawn("urxvtc -e alsamixer", false) end),
--    awful.button({ }, 4, function () awful.util.spawn("amixer -q set Master 2dB+", false) end),
--    awful.button({ }, 5, function () awful.util.spawn("amixer -q set Master 2dB-", false) end)
-- )) -- Register assigned buttons
-- volwidget:buttons(awful.util.table.join(
--    awful.button({ }, 1, function () awful.util.spawn("amixer -q set Master toggle", false) end),
--    awful.button({ }, 3, function () awful.util.spawn("urxvtc -e alsamixer", false) end),
--    awful.button({ }, 4, function () awful.util.spawn("amixer -q set Master 2dB+", false) end),
--    awful.button({ }, 5, function () awful.util.spawn("amixer -q set Master 2dB-", false) end)
-- )) -- Register assigned buttons

-- {{{ CPU usage and temperature
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
tzswidget = widget({ type = "textbox" })
-- Graph properties
cpugraph:set_width(40):set_height(14)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_gradient_angle(0):set_gradient_colors({
   beautiful.fg_end_widget, beautiful.fg_center_widget, beautiful.fg_widget
}) -- Register widgets
vicious.register(cpugraph,  vicious.widgets.cpu,      "$1")
vicious.register(tzswidget, vicious.widgets.thermal, " $1C", 19, "thermal_zone0")
-- }}}

-- {{{ Battery state
baticon = widget({ type = "imagebox" })
baticon.image = image(beautiful.widget_bat)
-- Initialize widget
batwidget = widget({ type = "textbox" })
-- Register widget
vicious.register(batwidget, vicious.widgets.bat, "<span color='cyan'>$1</span><span color='white'>$2% ($3)</span>", 61, "BAT0") 
-- }}}

-- {{{ Memory usage
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)
-- Initialize widget
membar = awful.widget.progressbar()
-- Pogressbar properties
membar:set_vertical(true):set_ticks(true)
membar:set_height(14):set_width(8):set_ticks_size(2)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_gradient_colors({ beautiful.fg_widget,
   beautiful.fg_center_widget, beautiful.fg_end_widget
}) -- Register widget
vicious.register(membar, vicious.widgets.mem, "$1", 13)
-- }}}

-- {{{ File system usage
fsicon = widget({ type = "imagebox" })
fsicon.image = image(beautiful.widget_fs)
-- Initialize widgets
fs = {
  b = awful.widget.progressbar(), r = awful.widget.progressbar(),
  h = awful.widget.progressbar(), s = awful.widget.progressbar()
}
-- Progressbar properties
for _, w in pairs(fs) do
  w:set_vertical(true):set_ticks(true)
  w:set_height(14):set_width(5):set_ticks_size(2)
  w:set_border_color(beautiful.border_widget)
  w:set_background_color(beautiful.fg_off_widget)
  w:set_gradient_colors({ beautiful.fg_widget,
     beautiful.fg_center_widget, beautiful.fg_end_widget
  }) -- Register buttons
  w.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function () exec("rox", false) end)
  ))
end -- Enable caching
vicious.cache(vicious.widgets.fs)
-- Register widgets
-- vicious.register(fs.b, vicious.widgets.fs, "${/boot used_p}", 599)
vicious.register(fs.r, vicious.widgets.fs, "${/ used_p}",     599)
-- vicious.register(fs.h, vicious.widgets.fs, "${/home used_p}", 599)
-- vicious.register(fs.s, vicious.widgets.fs, "${/mnt/storage used_p}", 599)
-- }}}


-- vicious network-widget

-- netwidget = widget({ type = "textbox" })

-- vicious.register(netwidget, vicious.widget.wifi, '<span color="cyan">wlan</span> ${ssid} ${link}', 5, "wlan0")
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
    names  = { "term", "coding", "web", "mail", "im", "vms", "media", 8, 9 },
    layout = {
        awful.layout.suit.tile.bottom, layouts[1], awful.layout.suit.max, awful.layout.suit.floating, awful.layout.suit.floating,
        awful.layout.suit.floating, awful.layout.suit.floating, awful.layout.suit.floating, awful.layout.suit.floating
    }
}
for s = 1, scount do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal },
                                    { "xdg", xdgmenu}
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- {{{ Date and time
mytextclock = awful.widget.textclock({ align = "right" })
dateicon = widget({ type = "imagebox" })
dateicon.image = image(beautiful.widget_date)

-- Create a systray
mysystray = widget({ type = "systray" })

-- Create a wibox for each screen and add it
mywibox = {}
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

for s = 1, scount do
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

    -- Create the wibox
    mywibox[s] = awful.wibox({      screen = s,
        fg = beautiful.fg_normal, height = 12,
        bg = beautiful.bg_normal, position = "top",
        border_color = beautiful.border_focus,
        border_width = beautiful.border_width
    })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mytaglist[s],
            mylayoutbox[s],
            separator,
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        s == 1 and mysystray or nil,
        separator, mytextclock, dateicon,
        separator, volwidget,  volbar.widget, volicon,
        separator, fs.r.widget, fsicon,
        separator, membar.widget, memicon,
        separator, batwidget, baticon,
        separator, tzswidget, cpugraph.widget, cpuicon,
        separator, mytasklist[s],
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
    awful.key({ modkey            }, "s", function () scratch.pad.toggle() end),
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
    -- awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey, "Shift"   }, "q", function () awful.util.spawn('xfce4-session-logout') end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Volume control
    -- awful.key({ }, "XF86AudioMute", function () awful.util.spawn("amixer -q set Master toggle", false) end),
    -- awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("amixer -q set Master 2dB-", false) end),
    -- awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("amixer -q set Master 2dB+", false) end),
    -- awful.key({ }, "XF86AudioMute", function () awful.util.spawn("pvol.py -m", false) end),
    -- awful.key({ }, "XF86AudioLowerVolume", function () awful.util.spawn("pvol.py -c -2", false) end),
    -- awful.key({ }, "XF86AudioRaiseVolume", function () awful.util.spawn("pvol.py -c 2", false) end),
    -- awful.key({ }, "XF86Sleep", function () awful.util.spawn("sudo /usr/sbin/s2both") end),
    awful.key({ }, "XF86Sleep", function () awful.util.spawn("dbus-send --system --print-reply --dest=\"org.freedesktop.UPower\" /org/freedesktop/UPower org.freedesktop.UPower.Hibernate") end),
    awful.key({ modkey,  }, "F10", function () awful.util.spawn("cmus-remote --pause", false) end),
    awful.key({ modkey,  }, "F12", function () awful.util.spawn("Equal") end),
    awful.key({ modkey,  }, "F9", function () scratch.drop("urxvtc", "bottom") end),

    -- awful.key({ modkey,  }, "e", function () awful.util.spawn("urxvtc -e mc") end),
    awful.key({modkey}, "e", function()
	    revelation({class="URxvt"})
    end),
    awful.key({ modkey,  }, "Print", function () awful.util.spawn_with_shell("sleep 0.1; scrot -s") end),
    -- awful.key({ modkey,           }, "m", function() awful.util.spawn(mailview) end),
    -- awful.key({ }, "XF86AudioLowerVolume",function()
    --         vicious.contrib.pulse.add(-5,"alsa_output.pci-0000_00_1b.0.analog-stereo")
    --         osd.notify("Vol:",pulsevolume("alsa_output.pci-0000_00_1b.0.analog-stereo"))
    -- end),
    -- awful.key({ }, "XF86AudioRaiseVolume",function()
    --         vicious.contrib.pulse.add(5,"alsa_output.pci-0000_00_1b.0.analog-stereo")
    --         osd.notify("Vol:",pulsevolume("alsa_output.pci-0000_00_1b.0.analog-stereo"))
    -- end),


    -- Prompt
    -- awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),
    awful.key({modkey }, "r", function()
            awful.util.spawn_with_shell( "exe=`lsx /usr/bin ~/bin /opt/bin | dmenu -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#955'` && exec $exe")
    end),
    -- Run or raise applications with dmenu
    -- awful.key({ modkey }, "r",
    -- function ()
    --     local f_reader = io.popen( "lsx /usr/bin ~/bin /opt/bin | dmenu -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#955'")
    --     local command = assert(f_reader:read('*a'))
    --     f_reader:close()
    --     if command == "" then return end

    --     -- Check throught the clients if the class match the command
    --     local lower_command=string.lower(command)
    --     for k, c in pairs(client.get()) do
    --         local class=string.lower(c.class)
    --         if string.match(class, lower_command) then
    --             for i, v in ipairs(c:tags()) do
    --                 awful.tag.viewonly(v)
    --                 c:raise()
    --                 c.minimized = false
    --                 return
    --             end
    --         end
    --     end
    --     awful.util.spawn(command)
    -- end),

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
    awful.key({ modkey            }, "d", function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
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
for s = 1, scount do
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
                     buttons = clientbuttons } },
    { rule_any = { class = { "Pcmanfm", "Nautilus" } },
      properties = { floating = true },
      callback = awful.placement.centered },
    { rule_any = { class = { "Xmessage",  "Gxmessage", "Hamster-time-tracker" } },
      properties = { floating = true },
      callback = awful.placement.centered },
    { rule_any = { class = { "Zathura", "Epdfview", "Remmina", "Bottlechooser.rb"} },
      properties = { floating = true } },
    -- media
    { rule_any = { class = { "Smplayer", "MPlayer", "Deadbeef", "gtkpod", "gpodder" } },
      properties = { switchtotag = true, floating = true },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][7], c) end},
    { rule_any = { class = { "Dxtime", "Zim", "pinentry", "gimp", "Synapse", "TogglDesktop" } },
      properties = { floating = true } },
    { rule_any = { class = { "Gvim", "Anjuta", "Emacs" } },
      properties = { tag = tags[1][2], switchtotag = true } },
    { rule_any = { class = { "Firefox", "Iron", "Opera", "luakit", "Uzbl-core" } },
      properties = { switchtotag = true },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][3], c) end},
    { rule = { class = "Firefox" },
      except = { instance = "Navigator" },
      properties = { floating = true } },
    -- { rule = { class = "Firefox", instance = "Navigator" },
    --   properties = { maximize_vertical = true, maximized_horizontal = true } },
    -- { rule = { class = "Iron" },
    --   properties = { maximize_vertical = true, maximized_horizontal = true } },
      -- thunderbird
    -- { rule = { class = "URxvt" },
    --   properties = { tag = tags[1][1], switchtotag = true } },
    { rule = { class = "Thunderbird" },
      properties = { tag = tags[1][4] } },
    { rule = { class = "Calibre" },
      properties = { tag = tags[1][4] } },
    { rule_any = { class = { "Skype", "Pidgin" } },
      properties = { switchtotag = true },
      callback = function(c) awful.client.movetotag(tags[mouse.screen][5], c) end},
    { rule = { class = "Pidgin", role = "buddy_list" },
      properties = { floating = true } },
    { rule = { class = "Skype"},
      except = { name = "Chat" },
      properties = { floating = true } },
    { rule_any = { class = { "Vmware", "VirtualBox" } },
      properties = { tag = tags[1][6] } },
    -- { rule = { class = "[~] % qemu-system-x86_64" },
    { rule = { class = "qemu-system-x86_64" },
      properties = { tag = tags[1][6] } },
      -- office
    { rule_any = { class = { "libreoffice-startcenter",  "libreoffice-impress" }, name = { "PowerPoint % [~]" }  },
      properties = { tag = tags[1][8] } },
    -- this is flash
    { rule = { class = "Exe" },
      properties = { tag = tags[1][3] },
      callback = balala },
    -- { rule = { class = "Exe" },
    --   properties = { maximize_vertical = false, tag = tags[1][5], fullscreen = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    -- c:add_signal("mouse::enter", function(c)
    --     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    --         and awful.client.focus.filter(c) then
    --         client.focus = c
    --     end
    -- end)

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
-- }}}
