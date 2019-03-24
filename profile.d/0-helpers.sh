# Magic's helpers for bash profiles

addPath() {
    for path in $@
    do
	echo ":$PATH:" | grep -q ":$path:" && continue
	[ -d "$path" ] && PATH="$PATH:$path"
    done
}

addPathBefore() {
    for path in $@
    do
	echo ":$PATH:" | grep -q ":$path:" && continue
	[ -d "$path" ] && PATH="$path:$PATH"
    done
}

#alias dusort='du -sk ./* | sort -n | cut -f 2 | while read folder; do du -sh "$folder"; done'
alias dusort='ls -d ./.* ./ | grep -v "^\./\.*$" | while read item; do du -sk "$item"; done  | sort -n | cut -f 2 | while read item; do du -sh "$item" | sed "s|[[:blank:]]\.||"; done'
