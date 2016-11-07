#
# zaw-src-applications
#
# zaw source for desktop applications
#

function zaw-src-music() {
    emulate -L zsh
    setopt local_options extended_glob null_glob
    # Glob common locations anyway since both of previous indexes may
    # be stale or non-existent
    candidates+=({,~}/Music/**/*.{mp3,m4a})

    candidates=(${(iou)candidates[@]})
    actions=("zaw-callback-launch-mpv-novideo" "zaw-callback-append-to-buffer")
    act_descriptions=("execute movie" "append to edit buffer")

}

function zaw-callback-launch-mpv-novideo() {
    BUFFER="mpv -no-video \"${(j:; :)@}\""
    zle accept-line
}

zaw-register-src -n music zaw-src-music
