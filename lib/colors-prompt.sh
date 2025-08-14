# Prompt colors, Magic's way

if [ -n "$PS1" ]; then PS1='\h:\W \u\$ '; fi

DEFAULT="\[\033[00m\]"
  BLACK="\[\033[01;30m\]"
    RED="\[\033[01;31m\]"
  GREEN="\[\033[01;32m\]"
 YELLOW="\[\033[01;33m\]"
   BLUE="\[\033[01;34m\]"
MAGENTA="\[\033[01;35m\]"
   CYAN="\[\033[01;36m\]"
  WHITE="\[\033[01;37m\]"
whoami | grep -q "^root$" \
    && COLOR_USER=$RED \
    || COLOR_USER=$GREEN
[ "$WINDOW" ] && W="-$WINDOW"

PS1="${debian_chroot:+($debian_chroot)}${COLOR_USER}\u${GREEN}@\h${W}:${YELLOW}\W${DEFAULT} \$ "
unset COLOR_USER W
