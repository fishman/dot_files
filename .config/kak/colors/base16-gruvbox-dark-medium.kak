# Base16 Gruvbox Dark Theme

evaluate-commands %sh{
    bg0="rgb:282828"
    bg0_hard="rgb:1d2021"
    bg0_soft="rgb:32302f"

    bg1="rgb:3c3836"
    bg2="rgb:504945"
    bg3="rgb:665c54"
    bg4="rgb:7c6f64"

    fg0="rgb:fbf1c7"
    fg0_hard="rgb:f9f5d7"
    fg0_soft="rgb:f2e5bc"

    fg1="rgb:ebdbb2"
    fg2="rgb:d5c4a1"
    fg3="rgb:bdae93"
    fg4="rgb:a89984"

    # Bright Colors
    b_red="rgb:fb4934"
    b_green="rgb:b8bb26"
    b_yellow="rgb:fabd2f"
    b_blue="rgb:83a598"
    b_purple="rgb:d3869b"
    b_aqua="rgb:8ec07c"
    b_orange="rgb:fe8019"
    b_gray="rgb:928374"

    # Normal Colors
    red="rgb:cc241d"
    green="rgb:98971a"
    yellow="rgb:d79921"
    blue="rgb:458588"
    purple="rgb:b16286"
    aqua="rgb:689d6a"
    orange="rgb:d65d0e"

    # Faded Colors
    f_red="rgb:9d0006"
    f_green="rgb:79740e"
    f_yellow="rgb:b57614"
    f_blue="rgb:076678"
    f_purple="rgb:8f3f71"
    f_aqua="rgb:427b58"
    f_orange="rgb:af3a03"
    f_gray="rgb:828374"

    echo "
        # Code highlighting
        face global value     ${b_orange}
        face global type      ${b_yellow}
        face global variable  ${b_aqua}
        face global module    ${f_yellow}
        face global function  ${b_blue}
        face global string    ${b_green}
        face global keyword   ${b_purple}
        face global operator  ${b_blue}
        face global attribute ${b_orange}
        face global comment   ${b_gray}+a
        face global meta      ${b_red}
        face global builtin   default+b

        # Markup
        face global title         ${b_green}+b
        face global header        ${b_blue}+b
        face global bold          default,default+ba
        face global italic        default,default+ia
        face global underline     default,default+ufa
        face global strikethrough ${bg3}
        face global mono          ${fg2}
        face global block         ${fg3}
        face global link          ${b_aqua}+u
        face global bullet        ${b_red}
        face global list          ${fg0}

        face global Default            ${fg0},${bg0}
        face global PrimarySelection   default,${bg2}+g
        face global SecondarySelection default,${bg1}+g
        face global PrimaryCursor      ${bg0},${fg0}+fg
        face global SecondaryCursor    ${bg0},${fg3}+fg
        face global PrimaryCursorEol   ${bg0},${fg2}+fg
        face global SecondaryCursorEol ${bg0},${fg4}+fg
        face global LineNumbers        ${bg3}
        face global LineNumberCursor   ${fg3}
        face global LineNumbersWrapped ${bg0}
        face global MenuForeground     ${fg1},${bg3}+b
        face global MenuBackground     default,${bg2}
        face global MenuInfo           ${b_blue}
        face global Information        ${bg0},${fg4}
        face global Error              ${b_red},default+b
        face global StatusLine         ${fg1},${bg1}
        face global StatusLineMode     ${fg1}
        face global StatusLineInfo     ${fg3}
        face global StatusLineValue    ${b_red}
        face global StatusCursor       ${bg0},${fg0}
        face global Prompt             default
        face global MatchingChar       default,${bg2}
        face global BufferPadding      ${bg0},${bg0}
        face global Whitespace         ${bg2}+f
        face global WrapMarker         ${bg2}+f
    "
}
