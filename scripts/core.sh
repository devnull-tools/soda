#!/bin/sh
#                            The MIT License
#
#        Copyright (c) 2013 Marcelo Guimaraes <ataxexe@gmail.com>
# ----------------------------------------------------------------------
# Permission  is hereby granted, free of charge, to any person obtaining
# a  copy  of  this  software  and  associated  documentation files (the
# "Software"),  to  deal  in the Software without restriction, including
# without  limitation  the  rights to use, copy, modify, merge, publish,
# distribute,  sublicense,  and/or  sell  copies of the Software, and to
# permit  persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The  above  copyright  notice  and  this  permission  notice  shall be
# included  in  all  copies  or  substantial  portions  of the Software.
#                        -----------------------
# THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT  WARRANTY OF ANY KIND,
# EXPRESS  OR  IMPLIED,  INCLUDING  BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN  NO  EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM,  DAMAGES  OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT  OR  OTHERWISE,  ARISING  FROM,  OUT OF OR IN CONNECTION WITH THE
# SOFTWARE   OR   THE   USE   OR   OTHER   DEALINGS  IN  THE  SOFTWARE.

# Stores the usage for exposed commands
TASKS_USAGE="  TASKS:"
PARAMETERS_USAGE="  PARAMETERS:"

NAMESPACES=""
TASKS=""

BASH_COMPLETION_TASKS=""
BASH_COMPLETION_PARAMETERS=""

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
# Tasks not registered cannot be executed.
#
# Arguments:
#
#   1- function name (args should go here too)
#   2- function description
#
function task {
  local task_name="${1//_/-}"
  TASKS_USAGE="$TASKS_USAGE
    $(printf "%-${SODA_FUNCTION_NAME_LENGTH}s" "$TASK_NAMESPACE$task_name") $2"
  TASKS="$TASKS {$TASK_NAMESPACE${task_name%% *}}"
  BASH_COMPLETION_TASKS="$BASH_COMPLETION_TASKS $TASK_NAMESPACE${task_name%% *}"
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
    $(printf "%-${SODA_PARAMETER_NAME_LENGTH}s" "--${parameter_name}")"
  PARAMETERS_USAGE="${PARAMETERS_USAGE}$(printf "%+${SODA_PARAMETER_NAMESPACE_LENGTH}s" "$PARAMETER_NAMESPACE") $2"
  BASH_COMPLETION_PARAMETERS="$BASH_COMPLETION_PARAMETERS $PARAMETERS --${parameter_name%%=*}"
  if [[ "$parameter_name" =~ .+=.+ ]]; then
    BASH_COMPLETION_PARAMETERS="${BASH_COMPLETION_PARAMETERS}="
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
  BASH_COMPLETION_PARAMETERS=""
  BASH_COMPLETION_TASKS=""
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
  if [[ ! $(echo "$SODA_IMPORTS" | grep ":$1:") ]]; then
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
  local parameter="${1#*--}"
  if [[ -z "$parameter" ]]; then
    return 1
  fi
  local value="${parameter#*=}"
  if [[ ! $(echo "$1" | grep -ie "=") ]]; then
    value=true
  fi
  parameter="${parameter%%=*}"

  eval "${parameter//-/_}=$value"
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
  local task_name="$1"
  shift
  if [[ -n "$task_name" ]]; then
    parse_task "$task_name" && {
      import "$NAMESPACE"
    }
    if [[ ! "$TASKS" == *"{${task_name}}"* ]]; then
      error "Task \"$task_name\" not found."
      exit 1
    fi
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

function namespaces {
  import_all_namespaces
  echo "$NAMESPACES"
}
