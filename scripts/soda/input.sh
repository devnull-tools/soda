#!/bin/bash
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

#
# Asks user to input a value and stores it in the given variable.
# If the variable is in upper case and previously set, the prompt
# will be skipped
#
# Arguments:
#
#   1- Value description
#   2- Variable to store input
#   3- Default value to assign if user input is empty
#
input() {
  if [[ ("$(uppercase "$2")" == "$2") && (-n "$(get_var "$2")") ]]; then
    log_debug "Variable '\$$2' already set. Skipping input..."
    return 1
  fi
  local prompt="$(bold_white "$1"): "
  if [[ -n "$3" ]]; then
    prompt="$prompt $(bold_white "[")$(bold_green "$3")$(bold_white "]") "
  fi
  read -p "$prompt" $2
  if [[ "$(get_var $2)" == "" ]]; then
    set_var "$2" "$3"
  fi
}

#
# Asks user to choose a value from a list and stores it in the given variable.
# If the variable is in upper case and previously set, the prompt
# will be skipped
#
# The label for selection will be stored in $VAR_label variable.
#
# Arguments:
#
#   1- Value description
#   2- Variable to store the selected label
#   *- List of labels
#
choose() {
  local text="$1"
  local var="$2"
  shift 2
  if [[ ("$(uppercase "$var")" == "$var") && (-n "$(get_var "$var")") ]]; then
    log_debug "Variable '\$$var' already set. Skipping input..."
    local options=("$@")
  else
    local prompt="$(bold_white "$text:")"
    local i=0
    local options=()
    for option in "$@"; do
      prompt="$prompt
  $(bold_white "($i)") - $(yellow "$option")"
      if [[ $i == 0 ]]; then
        prompt="$prompt <=="
      fi
      ((i++))
      options+=("$option")
    done
    prompt="$prompt
> "
    read -p "$prompt" $var
    echo ""
    while [[ ("$var" -ge $i) || ("$var" -lt 0) ]]; do
      echo "$(red "Invalid input, choose a value between 0 and $(($i - 1))")"
      read -p "> " $var
      echo ""
    done
  fi
  if [[ -z "$(get_var $var)" ]]; then
    set_var "$var" "0"
  fi
  set_var "${var}_label" "${options[$var]}"
}
