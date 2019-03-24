[ -e /etc/torrent ] \
    && . /etc/torrent \
    && alias transmission-remote="transmission-remote -n \$auth"
