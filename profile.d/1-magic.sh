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

  addPathBefore ~/bin /opt/magic/bin ~/.local/bin

  #[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"

  which emacs >/dev/null && export EDITOR=emacs
  alias sudo='sudo env PATH=$PATH'
fi
cleanPath 2>/dev/null
