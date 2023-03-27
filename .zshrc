# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

#!/opt/local/bin/zsh
source ~/.zinit/bin/zinit.zsh
zinit light zsh-users/zsh-autosuggestions
zinit load zdharma/history-search-multi-word

autoload -U compinit zrecompile

zsh_cache=${HOME}/.zsh_cache
mkdir -p $zsh_cache

if [ -f ~/.asdf/asdf.sh ]; then
    . ~/.asdf/asdf.sh
	# append completions to fpath
	fpath=(~/.asdf/completions $fpath)
fi

source ~/.zsh.d/antigen.zsh

if [ $UID -eq 0 ]; then
  compinit
else
  compinit -d $zsh_cache/zcomp-$HOST

  for f in ~/.zshrc $zsh_cache/zcomp-$HOST; do
    zrecompile -p $f && rm -f $f.zwc.old
  done
fi


# PATH="/home/timebomb/perl5/bin${PATH+:}${PATH}"; export PATH;
# PERL5LIB="/home/timebomb/perl5/lib/perl5${PERL5LIB+:}${PERL5LIB}"; export PERL5LIB;
# PERL_LOCAL_LIB_ROOT="/home/timebomb/perl5${PERL_LOCAL_LIB_ROOT+:}${PERL_LOCAL_LIB_ROOT}"; export PERL_LOCAL_LIB_ROOT;
# PERL_MB_OPT="--install_base \"/home/timebomb/perl5\""; export PERL_MB_OPT;
# PERL_MM_OPT="INSTALL_BASE=/home/timebomb/perl5"; export PERL_MM_OPT;

# if which ruby >/dev/null && which gem >/dev/null; then
#   PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
# fi

# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# [[ -s "$HOME/.local/share/marker/marker.sh" ]] && source "$HOME/.local/share/marker/marker.sh"

# added by travis gem
[ -f /home/timebomb/.travis/travis.sh ] && source /home/timebomb/.travis/travis.sh

[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases


source /home/timebomb/.config/broot/launcher/bash/br

if [ -f /usr/share/nnn/quitcd/quitcd.bash_zsh ]; then
    source /usr/share/nnn/quitcd/quitcd.bash_zsh
fi

setopt extended_glob
for zshrc_snipplet in ~/.zsh.d/S[0-9][0-9]*[^~] ; do
  source $zshrc_snipplet
done

antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
# antigen bundle heroku
antigen bundle pip
# antigen bundle command-not-found
# antigen bundle kubectx
# antigen bundle kube-ps1

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme afowler

# Tell Antigen that you're done.
antigen apply
