#!/bin/bash

# install/install.sh
# Must be called by helpers when config file is not set.

set -e

get_config > $TMP.env
cat $TMP.env | wc -l | grep -q "^0" && end 1 "I can't find any defaults, what did you do wrong?"

# Show environment if requested
log 1 "I am entitled to a config file. I will save these values in $ENV_FILE"

sed "s/^/\t/" $TMP.env | sort -n

yesno -y "Proceed?" || end $? "Abort"

cat $TMP.env > $ENV_FILE && log 1 "Preferences updated, have fun"
