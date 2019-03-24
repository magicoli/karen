# This is Magic's way 

if [ "`id -u`" -eq 0 ]; then
  PS1='# '
else
  PS1='$ '
fi
PS1="$USER@$(hostname)$PS1"

umask 0002

addPathBefore "$HOME/bin"
addPath "/opt/magic/bin"

#[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

which emacs >/dev/null && export EDITOR=emacs
