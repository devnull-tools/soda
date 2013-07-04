#!/bin/sh

# Stores the usage for exposed commands
TASKS_USAGE="  TASKS:"
PARAMETERS_USAGE="  PARAMETERS:"

NAMESPACES=""
PARAMETERS=""
TASKS=""

# Used for showing the namespaces of task functions in help message
TASK_NAMESPACE=""
PARAMETER_NAMESPACE=""

function clear_help_usage {
  TASKS_USAGE="  TASKS:"
  PARAMETERS_USAGE="  PARAMETERS:"  
}

#
# Expose the given function in the program usage and register it for autocompletion.
#
# Arguments:
#
#   1- function name (args should go here too)
#   2- function description
#
# Note that all functions are exposed, this only documents
# the function in the program help message.
#
function task {
  local task_name="${1//_/-}"
  TASKS_USAGE="$TASKS_USAGE
    $(printf "%-${SODA_FUNCTION_NAME_LENGTH}s" "$TASK_NAMESPACE$task_name") $2"
  TASKS="$TASKS $TASK_NAMESPACE${task_name%% *}"
}

#
# Exposes the given parameter in the program usage, register it for autocompletion 
# and returns indicating if the parameter was given.
#
# Arguments:
#
#   1- parameter name (args should go here too)
#   2- parameter description
#
function parameter {
  local parameter_name="${1//_/-}"
  PARAMETERS_USAGE="$PARAMETERS_USAGE
    $(printf "%-${SODA_PARAMETER_NAME_LENGTH}s" "--${parameter_name}")$(printf "%+${SODA_PARAMETER_NAMESPACE_LENGTH}s" "$PARAMETER_NAMESPACE") $2"
  PARAMETERS="$PARAMETERS --${parameter_name%%=*}"
  if [[ "$parameter_name" =~ .+=.+ ]]; then
    PARAMETERS="${PARAMETERS}="
  fi
  if [[ $(get_var "${1%%=*}") ]]; then
    return 0
  else
    return 1
  fi
}

SODA_IMPORTS=""

function clear_imports {
  SODA_IMPORTS=""
  TASK_NAMESPACE=""
  PARAMETER_NAMESPACE=""
}

#
# Loads all scripts in the *scripts/namespace* directory. The scripts may be in
# $SODA_USER_DIR or $SODA_DIR.
# 
# If a namespace was already imported, then it will not be imported again.
#
# Example: to import the namespace denoted by $SODA_USER_DIR/scripts/install
# use `import install`.
#
function import {
  if [[ ! $(echo "$SODA_IMPORTS" | grep -ie ":$1:") ]]; then
    if [[ "$1" != "soda" ]]; then
      if [[ "$1" != "common" ]]; then
        TASK_NAMESPACE="$1$SODA_NAMESPACE_DELIMITER"
        PARAMETER_NAMESPACE="[$1]"
      fi
    fi
    SODA_IMPORTS="$SODA_IMPORTS:$1:"
    NAMESPACES="$NAMESPACES $1"

    load_scripts "$SODA_DIR/scripts/$1"
    load_scripts "$SODA_USER_DIR/scripts/$1"
  fi
}

function import_all_namespaces {
  for namespace in $(ls $SODA_USER_DIR/scripts); do
    import "$namespace"
  done
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


#
# Parse the function name. By convention, '-' will be replaced
# by '_' to build the function name.
#
function build_name {
  echo "${1//-/_}"
}

#
# Calls the given function with the given args.
#
# Before the call, the function name will be normalized using
# the conventions in #build_name.
#
# To call a function in a namespace without import it implicit, use
# the sintax namespace#function as the function name.
#
# To change the namespace delimiter (defaults to "#"), use the
# SODA_NAMESPACE_DELIMITER variable
#
function call {
  TASK="$1"
  shift
  if [[ -n "$TASK" ]]; then
    parse_task "$TASK" && {
      import "$NAMESPACE"
    }
    "$TASK" "$@"
  fi
}

function parse_task {
  TASK="$1"
  NAMESPACE="${TASK%%$SODA_NAMESPACE_DELIMITER*}"
  TASK="${TASK#*${SODA_NAMESPACE_DELIMITER}}"
  if [[ $(expr length "$1") == $(expr length "$NAMESPACE") ]]; then
    NAMESPACE=""
  fi
  TASK=$(build_name "$TASK")
  if [[ -n "$NAMESPACE" ]]; then
    return 0
  else
    return 1
  fi
}

# Dynamically sets a variable value
function set_var {
  eval "$1=$2"
}

# Dynamically gets a variable value
function get_var {
  eval echo "\$$1"
}

[ -z "$OPTIONS_FILE" ] && OPTIONS_FILE=/dev/null
[ -z "$LOG_FILE" ] && LOG_FILE=/dev/null
[ -z "$COMMAND_LOG_FILE" ] && COMMAND_LOG_FILE=/dev/null
[ -z "$LAST_COMMAND_LOG_FILE" ] && LAST_COMMAND_LOG_FILE=/dev/null

function parameters {
  import_all_namespaces
  echo "$PARAMETERS"
}

function tasks {
  import_all_namespaces
  echo "$TASKS"
}

function soda_task_bash_completion {
  parse_task "$1" && {
    import "$NAMESPACE"
  }
  shift
  if [[ $(type -t "${TASK}_bash_completion") ]]; then
    "${TASK}_bash_completion" "$@"
  else
    tasks
  fi
}

function namespaces {
  import_all_namespaces
  echo "$NAMESPACES"
}
