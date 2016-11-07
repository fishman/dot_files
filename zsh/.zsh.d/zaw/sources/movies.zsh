#
# zaw-src-applications
#
# zaw source for desktop applications
#

function zaw-src-movies() {
    emulate -L zsh
    setopt local_options extended_glob null_glob
    # Glob common locations anyway since both of previous indexes may
    # be stale or non-existent
    candidates+=({,~}/Movies/Anime/*.{flv,mp4}(N) ~/Downloads/Torrents/**/*.mp4(N))

    candidates=(${(iou)candidates[@]})
    actions=("zaw-callback-launch-mpv" "zaw-callback-append-to-buffer")
    act_descriptions=("execute movie" "append to edit buffer")

}

function zaw-callback-launch-mpv() {
    BUFFER="mpv \"${(j:; :)@}\""
    zle accept-line
}

zaw-register-src -n movies zaw-src-movies
