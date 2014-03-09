#
# zaw-src-rails-rake
#

autoload -U read-from-minibuffer

function zaw-src-rails-rake(){
    rakefile="`pwd`/Rakefile"

    if [[ ! -f $rakefile ]]; then
        return
    fi

    rake -T | \
        while read f; do
          candidate="${$(echo $f | awk '/^rake/ {print $1,$2}')}"
          if ! [[ "$candidate" == "" ]]; then
              candidates+="$candidate"
              cand_description+="${$(echo $f | sed -e "s/$candidate//" | sed -e "s/^ *#//")}"
          fi
        done

    actions=("zaw-callback-execute" "zaw-callback-rails-rake-with-options")
    act_descriptions=("execute rake command." "execute rake command with options.")
}

zaw-register-src -n rails-rake zaw-src-rails-rake

function zaw-callback-rails-rake-with-options(){
    local orig_buffer="${BUFFER}"

    read-from-minibuffer "$1 "
    ret=$?
    if [[ "${ret}" == 0 ]]; then
        BUFFER="$1 ${REPLY}"
    else
        BUFFER="$1"
    fi

    zle accept-line
}

