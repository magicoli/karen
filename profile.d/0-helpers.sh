# Magic's helpers for bash profiles
if [ ! "$PROFILE_HELPERS" ]
then
  PROFILE_HELPERS=/opt/magic/etc/profile.d/0-helpers.sh
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
    for path in $PATH
    do
      path=$(echo $path | sed "s:/$::")
      [ -d $path ] || continue
      echo ":$newpath:" | grep -q ":$path:" && continue
      newpath="$newpath:$path"
    done
    IFS=$keepifs
    PATH=$(echo $newpath | sed "s/^://")
  }
fi
cleanPath 2>/dev/null
