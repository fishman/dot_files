#
# zaw-src-ack
#
# search using ack and open file
#

zmodload zsh/parameter

if (( $+commands[ack] )); then
    ACK_COMMAND="ack"
elif (( $+commands[ack-grep] )); then
    ACK_COMMAND="ack-grep"
else
    # ack not found
    return
fi

autoload -U read-from-minibuffer

function zaw-src-ack() {
    local ack_args REPLY f line ret cand
    local -a ack_history
    ack_history=( "${(@)${(f)"$(fc -l -n -m "$ACK_COMMAND *" 0 -1)"}#ack }" )

    function() {
        local HISTNO
        integer histno=1
        # temporary switch to new empty history
        fc -p -a
        # and add only ack's args to the history
        for ack_args in "${(@)ack_history}"; do
            print -s -r -- "${ack_args}"
            (( histno++ ))
        done
        HISTNO="${histno}"
        read-from-minibuffer "${ACK_COMMAND} "
        ret=$?
    }

    if [[ "${ret}" == 0 ]]; then
        $ACK_COMMAND --group --nocolor "${(Q@)${(z)REPLY}}" | \
            while read f; do
                while read line; do
                    if [[ -z "${line}" ]]; then
                        break
                    fi

                    if [ ! ${ZAW_EDITOR_JUMP_PARAM} ]; then
                        ZAW_EDITOR_JUMP_PARAM="+%LINE% %FILE%"
                    fi

                    cand="${ZAW_EDITOR_JUMP_PARAM/\%LINE\%/${line/:*/}}"
                    cand="${cand/\%FILE\%/${f}}"

                    candidates+="${cand}"
                    cand_short=`echo ${f} | awk -F'/' '{if (NF>3){LASTDIR=NF-1; print $1"/.../"$LASTDIR"/"$NF;} else {print $0}}'`
                    cand_descriptions+="${cand_short}:${line}"
                done
            done

        print -s -r -- "${ACK_COMMAND} ${REPLY}"

        actions=("zaw-src-ack-open-file" "zaw-callback-append-to-buffer")
        act_descriptions=("edit file" "append to edit buffer")
        options=("-m")
    else
        return 1
    fi
}

function zaw-src-ack-open-file() {
  BUFFER="${ZAW_EDITOR} $1"
  zle accept-line
}

zaw-register-src -n ack zaw-src-ack
