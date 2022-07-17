# This is Magic's way
if [ ! "$PROFILE_MAGIC" ]
then
  PROFILE_MAGIC=/opt/magic/etc/profile.d/1-magic.sh
  # echo BEEN THERE $PROFILE_MAGIC
  if [ "`id -u`" -eq 0 ]; then
    PS1='# '
  else
    PS1='$ '
  fi
  PS1="$USER@$(hostname)$PS1"

  umask 0002

  addPathBefore ~/bin /opt/wrap/bin /opt/magic/bin ~/.local/bin

  #[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

  which emacs >/dev/null && export EDITOR=emacs
#  hostname -I | grep -q "^(192|10)\." && alias sudo='sudo env PATH=$PATH'
fi
cleanPath 2>/dev/null

alias cdreal='cd $(realpath "$PWD")'
