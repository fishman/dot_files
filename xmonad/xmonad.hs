-- ~/.xmonad/xmonad.hs
-- Imports {{{
import XMonad

import XMonad.Config.Xfce
-- Prompt
import XMonad.Prompt
import XMonad.Prompt.RunOrRaise (runOrRaisePrompt)
import XMonad.Prompt.AppendFile (appendFilePrompt)
-- Hooks
import XMonad.Operations

import System.IO
import System.Exit

import XMonad.Util.Run
import XMonad.Util.NamedScratchpad
import XMonad.Util.Scratchpad (scratchpadSpawnAction, scratchpadManageHook, scratchpadFilterOutWorkspace)

import XMonad.Actions.CycleWS
import XMonad.Actions.WindowGo (title, raiseMaybe, runOrRaise)
-- move windows without mouse
import XMonad.Actions.FloatKeys

import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.ICCCMFocus

import XMonad.Layout.NoBorders (smartBorders, noBorders)
import XMonad.Layout.PerWorkspace (onWorkspace, onWorkspaces)
import XMonad.Layout.Reflect (reflectHoriz)
import XMonad.Layout.IM
import XMonad.Layout.Tabbed
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.LayoutHints
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Grid

import Data.Ratio ((%))
import Data.Monoid (mappend)
-- import Data.List (isInfixOf)

import qualified XMonad.StackSet as W
import qualified Data.Map as M

--}}}

-- Config {{{
-- Define Terminal
myTerminal      = "urxvtc"
-- Define modMask
modMask' :: KeyMask
modMask' = mod4Mask
-- Define workspaces
myWorkspaces    = ["1:main","2:web","3:vim","4:chat","5:music", "6:gimp", "7:IDE"]
-- Dzen/Conky
myXmonadBar = "dzen2 -e '' -x '1440' -y '0' -h '24' -w '640' -ta 'l'"
myStatusBar = "conky -c /home/hatori/.xmonad/.conky_dzen | dzen2 -e '' -x '640' -w '590' -h '24' -ta 'r' -y '0'"
myBitmapsDir = "/home/hatori/.xmonad/dzen2"
--}}}
-- Main {{{

main = do
    dzenLeftBar <- spawnPipe myXmonadBar
    dzenRightBar <- spawnPipe myStatusBar
    xmonad $ withUrgencyHook NoUrgencyHook
        $ defaultConfig
      { terminal            = myTerminal
      , startupHook         = ewmhDesktopsStartup >> setWMName "LG3D"
      , workspaces          = myWorkspaces
      , keys                = keys'
      , modMask             = modMask'
      , handleEventHook     = ewmhDesktopsEventHook `mappend` fullscreenEventHook
      , layoutHook          = smartBorders $ layoutHook'
      , manageHook          = namedScratchpadManageHook myScratchpads <+> manageHook'
      , logHook             = takeTopFocus >> myLogHook dzenLeftBar >> fadeInactiveLogHook 0xdddddddd
      , normalBorderColor   = colorNormalBorder
      , focusedBorderColor  = colorFocusedBorder
      , borderWidth         = 1
}
--}}}


-- Hooks {{{
-- ManageHook {{{
manageHook' :: ManageHook
manageHook' =  scratchpadManageHook (W.RationalRect 0.25 0 0.5 0.35) <+>
            (composeAll . concat $
    [ [resource     =? r            --> doIgnore            |   r   <- myIgnores] -- ignore desktop
    , [className    =? c            --> doShift  "1:main"   |   c   <- myDev    ] -- move dev to main
    , [className    =? c            --> doShift  "2:web"    |   c   <- myWebs   ] -- move webs to main
    , [className    =? c            --> doShift  "3:vim"    |   c   <- myVim    ] -- move webs to main
    , [className    =? c            --> doShift	 "4:chat"   |   c   <- myChat   ] -- move chat to chat
    , [className    =? c            --> doShift  "5:music"  |   c   <- myMusic  ] -- move music to music
    , [resource     =? r            --> doShift  "5:music"  |   r   <- plusRes  ]
    , [className    =? c            --> doShift  "6:gimp"   |   c   <- myGimp   ] -- move img to div
    , [resource     =? r            --> doShift  "6:gimp"   |   r   <- gimpRes  ]
    , [className    =? c            --> doShift  "7:IDE"    |   c   <- myIDEs   ] -- move eclipse to IDE
    , [className    =? c            --> doCenterFloat       |   c   <- myFloats ] -- float my floats
    , [name         =? n            --> doCenterFloat       |   n   <- myNames  ] -- float my names
    , [  composeOne [ isFullscreen -?> doFullFloat ]                            ]
    , [isDialog                     --> doCenterFloat                           ]
    ])

    where

        role      = stringProperty "WM_WINDOW_ROLE"
        name      = stringProperty "WM_NAME"

        -- classnames
        myFloats  = ["Smplayer","MPlayer","VirtualBox","Xmessage","XFontSel","Downloads","Nm-connection-editor", "VmWare", "Gxmessage"]
        myWebs    = ["Firefox","Google-chrome","Chromium", "Chromium-browser"]
        myMovie   = ["Boxee","Trine"]
        myMusic	  = ["Rhythmbox","Spotify"]
        myChat	  = ["Pidgin","Buddy List", "Skype"]
        myGimp	  = ["Gimp", "Inkscape"]
        gimpRes	  = ["Photoshop.exe"]
        plusRes	  = ["plus.google.com"]
        myDev	  = ["gnome-terminal"]
        myIDEs    = ["Eclipse", "PencilMainWindow", "Vmware", "VirtualBox", "jetbrains-idea-ce"]
        myVim	  = ["Gvim"]

        -- resources
        myIgnores = ["desktop","desktop_window","notify-osd","xfce4-notifyd", "stalonetray","panel"]

        -- names
        myNames   = ["bashrun","Google Chrome Options","Chromium Options"]

-- a trick for fullscreen but stil allow focusing of other WSs
myDoFullFloat :: ManageHook
myDoFullFloat = doF W.focusDown <+> doFullFloat
-- }}}
layoutHook'  =  onWorkspaces ["1:main","5:music"] customLayout $
                onWorkspaces ["2:web"] webLayout $
                onWorkspaces ["6:gimp"] gimpLayout $
                onWorkspaces ["4:chat"] imLayout $
                customLayout2

--Bar
myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ defaultPP
    {
        ppCurrent           =   dzenColor colorActive "#1B1D1E" . pad
      , ppVisible           =   dzenColor "white" "#1B1D1E" . pad
      , ppHidden            =   dzenColor "white" "#1B1D1E" . pad
      , ppHiddenNoWindows   =   dzenColor "#7b7b7b" "#1B1D1E" . pad
      , ppUrgent            =   dzenColor "#ff0000" "#1B1D1E" . pad
      , ppWsSep             =   " "
      , ppSep               =   "  |  "
      , ppLayout            =   dzenColor colorActive "#1B1D1E" .
                                (\x -> case x of
                                    "ResizableTall"             ->      "^i(" ++ myBitmapsDir ++ "/tall.xbm)"
                                    "Mirror ResizableTall"      ->      "^i(" ++ myBitmapsDir ++ "/mtall.xbm)"
                                    "Full"                      ->      "^i(" ++ myBitmapsDir ++ "/full.xbm)"
                                    "Simple Float"              ->      "~"
                                    _                           ->      x
                                )
      , ppTitle             =   (" " ++) . dzenColor "white" "#1B1D1E" . dzenEscape
      , ppSort              =   fmap (.scratchpadFilterOutWorkspace) $ ppSort defaultPP
      , ppOutput            =   hPutStrLn h
    }

-- Layout
tiled     = ResizableTall 1 (2/100) (1/2) []
reflectTiled = (reflectHoriz tiled)
{- tabLayout = (tabbed shrinkText myTheme) -}
full      = noBorders Full

customLayout = avoidStruts $ tiled ||| Mirror tiled ||| Full ||| simpleFloat
  where
    tiled   = ResizableTall 1 (2/100) (1/2) []

customLayout2 = avoidStruts $ Full ||| tiled ||| Mirror tiled ||| simpleFloat
  where
    tiled   = ResizableTall 1 (2/100) (1/2) []

gimpLayout  = avoidStruts $ withIM (0.15) (Role "gimp-toolbox") $
              reflectHoriz $
              withIM (0.15) (Role "gimp-dock") tiled

{- imLayout    = avoidStruts $ withIM (1%5) (And (ClassName "Pidgin") (Role "buddy_list")) Grid  -}
imLayout = avoidStruts $ withIM ratio pidginRoster $ reflectHoriz $ withIM skypeRatio skypeRoster (tiled ||| reflectTiled ||| Grid) where
    chatLayout      = Grid
    ratio           = (1%7)
    skypeRatio      = (1%8)
    pidginRoster    = And (ClassName "Pidgin") (Role "buddy_list")
    skypeRoster     = (ClassName "Skype") `And`
        (Not (Title "Options")) `And`
        (Not (Title "Optionen")) `And`
        (Not (Role "CallWindow")) `And`
        (Not (Role "ConversationsWindow"))

webLayout = avoidStruts $ full

--}}}
-- Theme {{{
-- Color names are easier to remember:
colorOrange         = "#FD971F"
colorDarkGray       = "#1B1D1E"
colorPink           = "#F92672"
colorGreen          = "#A6E22E"
colorBlue           = "#66D9EF"
colorYellow         = "#E6DB74"
colorWhite          = "#CCCCC6"

colorNormalBorder   = "#3F3F3F"
colorFocusedBorder  = "#9d871f"

colorActive         = "#ebac54"


barFont  = "terminus"
barXFont = "aquafont:size=11"
xftFont = "xft: aquafont-11"
--}}}

-- Prompt Config {{{
mXPConfig :: XPConfig
mXPConfig =
    defaultXPConfig { font                  = barFont
                    , bgColor               = colorDarkGray
                    , fgColor               = colorActive
                    , bgHLight              = colorActive
                    , fgHLight              = colorDarkGray
                    , promptBorderWidth     = 0
                    , height                = 14
                    , historyFilter         = deleteConsecutive
                    }

-- Run or Raise Menu
largeXPConfig :: XPConfig
largeXPConfig = mXPConfig
                { font = xftFont
                , height = 22
                }
-- }}}
myScratchpads =
    [
    NS "htop" "xterm -e htop" (title =? "htop") defaultFloating ,
    NS "zim"     "zim"                (className =? "Zim")   (customFloating $ W.RationalRect (1/6) (1/6) (2/3) (2/3))
    ]
-- Key mapping {{{
keys' conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask,                    xK_p        ), runOrRaisePrompt largeXPConfig)
    , ((modMask .|. shiftMask,      xK_Return   ), spawn $ XMonad.terminal conf)
    , ((modMask,                    xK_F2       ), runOrRaise "gmrun" (className =? "Gmrun" ))
    , ((modMask,                    xK_v        ), runOrRaise "vmware" (className =? "Vmware" ))
    , ((modMask .|. shiftMask,      xK_c        ), kill)
    , ((modMask .|. shiftMask,      xK_l        ), spawn "slock")
    , ((modMask,                    xK_F8       ), spawn "/home/hatori/bin/window-go.sh")
    , ((modMask,                    xK_F3       ), runOrRaise "/home/hatori/bin/grfkill" (className =? "Grfkill" ))
    -- Programs
    , ((0,                          xK_Print    ), spawn "scrot -e 'mv $f ~/screenshots/'")
    , ((modMask,		            xK_o        ), runOrRaise "chromium-browser" (className =? "Chromium" ))
    {- , ((modMask,                    xK_m        ), spawn "nautilus --no-desktop --browser") -}
    , ((modMask,                    xK_m        ), spawn "thunar")
    -- Media Keys
    , ((0,                          0x1008ff12  ), spawn "amixer -q sset Master toggle")        -- XF86AudioMute
    , ((0,                          0x1008ff11  ), spawn "amixer -q sset Master 5%-")   -- XF86AudioLowerVolume
    , ((0,                          0x1008ff13  ), spawn "amixer -q sset Master 5%+")   -- XF86AudioRaiseVolume
    , ((modMask,                    xK_F10  ), spawn "mpc toggle >& /dev/null")
    , ((modMask,                    xK_F11  ), spawn "mpc prev >& /dev/null")
    , ((modMask,                    xK_F12  ), spawn "mpc next >& /dev/null")

    -- layouts
    , ((modMask,                    xK_space    ), sendMessage NextLayout)
    , ((modMask .|. shiftMask,      xK_space    ), setLayout $ XMonad.layoutHook conf)          -- reset layout on current desktop to default
    , ((modMask,                    xK_b        ), sendMessage ToggleStruts)
    , ((modMask,                    xK_n        ), refresh)
    , ((modMask,                    xK_Tab      ), windows W.focusDown)                         -- move focus to next window
    , ((modMask,                    xK_j        ), windows W.focusDown)
    , ((modMask .|. shiftMask,      xK_Tab      ), windows W.focusUp)                           -- move focus to previous window
    , ((modMask,                    xK_k        ), windows W.focusUp  )
    , ((modMask .|. shiftMask,      xK_j        ), windows W.swapDown)                          -- swap the focused window with the next window
    , ((modMask .|. shiftMask,      xK_k        ), windows W.swapUp)                            -- swap the focused window with the previous window
    , ((modMask,                    xK_Return   ), windows W.swapMaster)
    , ((modMask,                    xK_t        ), withFocused $ windows . W.sink)              -- Push window back into tiling
    , ((modMask,                    xK_h        ), sendMessage Shrink)                          -- %! Shrink a master area
    , ((modMask,                    xK_l        ), sendMessage Expand)                          -- %! Expand a master area
    , ((modMask,                    xK_comma    ), sendMessage (IncMasterN 1))
    , ((modMask,                    xK_period   ), sendMessage (IncMasterN (-1)))
    -- Move Floats
    , ((modMask,                    xK_Left     ), withFocused (keysMoveWindow (-15, 0)))
    , ((modMask,                    xK_Right    ), withFocused (keysMoveWindow (15, 0)))
    , ((modMask,                    xK_Down     ), withFocused (keysMoveWindow (0, 10)))
    , ((modMask,                    xK_Up       ), withFocused (keysMoveWindow (0, -10)))
    -- Size floats
    , ((modMask .|. shiftMask,      xK_Left     ), withFocused (keysResizeWindow (-15, 0) (0, 0)))
    , ((modMask .|. shiftMask,      xK_Right    ), withFocused (keysResizeWindow (15, 0) (0, 0)))
    , ((modMask .|. shiftMask,      xK_Down     ), withFocused (keysResizeWindow (0, 15) (0, 0)))
    , ((modMask .|. shiftMask,      xK_Up       ), withFocused (keysResizeWindow (0, -15) (0, 0)))

    -- Focus window with urgency hook
    , ((modMask,                     xK_u       ), focusUrgent )

    -- quake terminal
    , ((modMask,                    xK_s        ), scratchpadSpawnAction defaultConfig { terminal = "uxterm" })
    , ((modMask .|. shiftMask,      xK_s        ), namedScratchpadAction myScratchpads "zim")
    , ((modMask .|. shiftMask,      xK_t        ), namedScratchpadAction myScratchpads "htop")


    -- workspaces
    , ((modMask .|. controlMask,   xK_Right     ), nextWS)
    -- , ((modMask .|. shiftMask,     xK_Right     ), shiftToNext)
    , ((modMask .|. controlMask,   xK_Left      ), prevWS)
    -- , ((modMask .|. shiftMask,     xK_Left      ), shiftToPrev)
    , ((modMask,                   xK_Escape    ), toggleWS)

    -- quit, or restart
    , ((modMask .|. shiftMask,      xK_q        ), spawn "xfce4-session-logout")
    , ((modMask,                    xK_q        ), spawn "killall conky dzen2 && /usr/bin/xmonad --recompile && /usr/bin/xmonad --restart")
    ]
    ++
    -- mod-[1..9] %! Switch to workspace N
    -- mod-shift-[1..9] %! Move client to workspace N
    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modMask, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

--}}}
-- vim:foldmethod=marker sw=4 sts=4 ts=4 tw=0 et ai nowrap
