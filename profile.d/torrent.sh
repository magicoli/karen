[ -e /etc/torrent ] \
    && . /etc/torrent \
    && alias transmission-remote="transmission-remote $tr_host -n \$auth"
