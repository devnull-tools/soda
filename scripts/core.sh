#!/bin/sh

# Stores the usage for exposed commands
PUBLIC_FUNCTIONS_USAGE="Public functions:"

#
# Exposes the given function in the program usage.
#
# Arguments:
#
#   1- function name
#   2- function description
#
# Note that all functions are exposed, this only documents
# the function in the program help message.
#
function public {
  PUBLIC_FUNCTIONS_USAGE="$PUBLIC_FUNCTIONS_USAGE
    $(printf "%-30s" "${1//_/-}") $2"
}

#
# Imports a set of scripts in the scripts directory. The scripts
# may be in $SODA_USER_DIR/scripts or $SODA_DIR/scripts. If the
# scripts are present in the first directory, the second will not
# be used.
#
# Example: to import scripts in $SODA_USER_DIR/scripts/install
# use `import install`.
#
function import {
  load_scripts "$SODA_USER_DIR/scripts/$1" || load_scripts "$SODA_DIR/scripts/$1"
}

#
# Loads all scripts inside a directory
#
function load_scripts {
  if [[ -d "$1" ]]; then
    for script in $(find $1 -type f -name "*.sh"); do
      . $script
    done
    return 0
  else
    return 1
  fi
}

[ -z "$OPTIONS_FILE" ] && OPTIONS_FILE=/dev/null
[ -z "$LOG_FILE" ] && LOG_FILE=/dev/null
[ -z "$COMMAND_LOG_FILE" ] && COMMAND_LOG_FILE=/dev/null
[ -z "$LAST_COMMAND_LOG_FILE" ] && LAST_COMMAND_LOG_FILE=/dev/null

import soda
