#!/opt/local/bin/zsh

autoload -U compinit zrecompile

zsh_cache=${HOME}/.zsh_cache
mkdir -p $zsh_cache

if [ $UID -eq 0 ]; then
  compinit
else
  compinit -d $zsh_cache/zcomp-$HOST

  for f in ~/.zshrc $zsh_cache/zcomp-$HOST; do
    zrecompile -p $f && rm -f $f.zwc.old
  done
fi

setopt extended_glob
for zshrc_snipplet in ~/.zsh.d/S[0-9][0-9]*[^~] ; do
  source $zshrc_snipplet
done

# PATH="/home/timebomb/perl5/bin${PATH+:}${PATH}"; export PATH;
# PERL5LIB="/home/timebomb/perl5/lib/perl5${PERL5LIB+:}${PERL5LIB}"; export PERL5LIB;
# PERL_LOCAL_LIB_ROOT="/home/timebomb/perl5${PERL_LOCAL_LIB_ROOT+:}${PERL_LOCAL_LIB_ROOT}"; export PERL_LOCAL_LIB_ROOT;
# PERL_MB_OPT="--install_base \"/home/timebomb/perl5\""; export PERL_MB_OPT;
# PERL_MM_OPT="INSTALL_BASE=/home/timebomb/perl5"; export PERL_MM_OPT;

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
