#!/bin/bash
# /opt/magic/etc/bashrc: executed by bash(1) for non-login shells.

PATH=$HOME/bin:/opt/wrap/bin:/opt/magic/bin:$PATH
PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin:/opt/opensim/bin:/opt/hypevents/bin:/opt/singtwice/bin

# Path cleanup. Keep at the end, after any path modification.
keepifs=$IFS
IFS=:
newpath=
for path in $PATH
do
  path=$(echo $path | sed "s:/$::")
  [ -d $path ] || continue
  echo ":$newpath:" | grep -q ":$path:" && continue
  newpath="$newpath:$path"
done
IFS=$keepifs
export PATH=$(echo $newpath | sed "s/^://")
# End path cleanup.
