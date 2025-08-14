# You may uncomment the following lines if you want `ls' to be colorized:
if [ -x /usr/bin/dircolors ]; then
    export LS_OPTIONS='--human --color=auto'
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
elif [ "$(uname -s)" = "FreeBSD" -o "$(uname -s)" = "Darwin" ]; then
    export LS_OPTIONS='-h -G'
    export CLICOLOR=cons25
fi

alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'
