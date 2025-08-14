# Magic's helpers for bash profiles
if [ ! "$PROFILE_HELPERS" ]
then
  PROFILE_HELPERS=$KAREN_ETC/profile.d/0-helpers.sh
  # echo BEEN THERE $PROFILE_HELPERS
  addPath() {
    for path in $@
    do
      # echo ":$PATH:" | grep -q ":$path:" && continue
      [ -d "$path" ] && PATH="$PATH:$path"
    done
    cleanPath
  }

  addPathBefore() {
    for path in $(echo $@ | tr ' ' '\n' | tac | tr '\n' ' ')
    do
      # echo ":$PATH:" | grep -q ":$path:" && continue
      [ -d "$path" ] && PATH="$path:$PATH"
    done
    cleanPath
  }

  cleanPath() {
    keepifs=$IFS
    IFS=:
    newpath=
    for path in $PATH
    do
      path=$(echo $path | sed "s:/$::")
      # echo "trying $path" >&2
      # echo "  current path $newpath" >&2
      [ -d $path ] || continue
      # echo "  $path exists" >&2
      echo ":$newpath:" | grep -q ":$path:" && continue
      # echo "  $path is not there yet" >&2
      newpath="$newpath:$path"
      # echo "  new path is $newpath" >&2
    done
    IFS=$keepifs
    PATH=$(echo $newpath | sed "s/^://")
  }
fi
cleanPath 2>/dev/null
