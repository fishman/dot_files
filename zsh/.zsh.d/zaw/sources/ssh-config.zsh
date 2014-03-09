#
# zaw-src-ssh-config
#

function zaw-src-ssh-config(){
  local config_file

  # 基本は ~/.ssh/config
  config_file="${HOME}/.ssh/config"

  if [[ -f $config_file ]]; then
    candidates=(${(f)"$(< ${config_file})"})
    candidates=(${(M)candidates:#(Host|HOST|host)*})
    candidates=(${(S)candidates#(Host|HOST|host) })
  fi

  actions=("zaw-callback-ssh-connect")

  act_descriptions=("ssh")
}

zaw-register-src -n ssh-config zaw-src-ssh-config

function zaw-callback-ssh-connect(){
  local orig_buffer="${BUFFER}"
  BUFFER="ssh $1"
  zle accept-line
}

