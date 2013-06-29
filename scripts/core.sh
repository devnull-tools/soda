#!/bin/sh

# Stores the usage for exposed commands
PUBLIC_FUNCTIONS_USAGE="  FUNCTIONS:"
OPTIONS_USAGE="  OPTIONS:"

CURRENT_NAMESPACE=""

#
# Exposes the given function in the program usage.
#
# Arguments:
#
#   1- function name (args should go here too)
#   2- function description
#
# Note that all functions are exposed, this only documents
# the function in the program help message.
#
function public {
  PUBLIC_FUNCTIONS_USAGE="$PUBLIC_FUNCTIONS_USAGE
    $(printf "%-${SODA_FUNCTION_NAME_LENGTH}s" "$CURRENT_NAMESPACE::${1//_/-}") $2"
}

#
# Exposes the given parameter in the program usage.
#
# Arguments:
#
#   1- parameter name
#   2- parameter description
#
# Note that all parameters are exposed, this only documents
# the parameter in the program help message.
#
function parameter {
  OPTIONS_USAGE="$OPTIONS_USAGE
    $(printf "%-${SODA_PARAMETER_NAME_LENGTH}s" "--${1//_/-}") $2"
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
    CURRENT_NAMESPACE="$1"
    SODA_IMPORTS="$SODA_IMPORTS:$1:"
    load_scripts "$SODA_USER_DIR/scripts/$1" || load_scripts "$SODA_DIR/scripts/$1"
  fi
}

#
# Loads all scripts inside a directory
#
function load_scripts {
  if [[ -d "$1" ]]; then
    for script in $(ls "$1" | grep .sh | sort); do
      . "$1/$script"
    done
    return 0
  else
    return 1
  fi
}

function set_parameter {
  local var="${1#*--}"
  local value="${var#*=}"
  if [[ ! $(echo "$1" | grep -ie "=") ]]; then
    value=true
  fi
  var="${var%%=*}"

  eval "${var//-/_}=$value"
}

[ -z "$OPTIONS_FILE" ] && OPTIONS_FILE=/dev/null
[ -z "$LOG_FILE" ] && LOG_FILE=/dev/null
[ -z "$COMMAND_LOG_FILE" ] && COMMAND_LOG_FILE=/dev/null
[ -z "$LAST_COMMAND_LOG_FILE" ] && LAST_COMMAND_LOG_FILE=/dev/null
