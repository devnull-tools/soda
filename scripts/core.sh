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
#   3- function params
#
# Note that all functions are exposed, this only documents
# the function in the program help message.
#
function public {
  PUBLIC_FUNCTIONS_USAGE="$PUBLIC_FUNCTIONS_USAGE
    $(printf "%-${SODA_FUNCTION_NAME_LENGTH}s %-${SODA_FUNCTION_ARGS_LENGTH}s" "${1//_/-}" "$3") $2"
}

SODA_IMPORTS=""

#
# Loads all scripts in the *scripts/namespace* directory. The scripts may be in
# $SODA_USER_DIR or $SODA_DIR. If the scripts are present in the first directory,
# the second one will not be used.
# 
# If a namespace was already imported, then it will not be imported again.
#
# Example: to import the namespace denoted by $SODA_USER_DIR/scripts/install
# use `import install`.
#
function import {
  if [[ ! $(echo "$SODA_IMPORTS" | grep -ie ":$1:") ]]; then
    SODA_IMPORTS="$SODA_IMPORTS:$1:"
    load_scripts "$SODA_USER_DIR/scripts/$1" || load_scripts "$SODA_DIR/scripts/$1"
  fi
}

#
# Loads all scripts inside a directory
#
function load_scripts {
  if [[ -d "$1" ]]; then
    for script in $(ls "*.sh" | sort); do
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
