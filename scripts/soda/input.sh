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

#
# Asks user to input a value.
#
# Arguments:
#
#   1- Value description
#   2- Variable to store input
#   3- Default value to assign if user input is empty
#
input() {
  local prompt="$(bold_white "$1"): "
  if [[ -n "$3" ]]; then
    prompt="$prompt $(bold_white "[")$(bold_green "$3")$(bold_white "]")"
  fi
  read -p "$prompt" $2
  if [[ "$(get_var $2)" == "" ]]; then
    set_var "$2" "$3"
  fi
}

#
# Asks user to choose a value from a list. The label for selection will be stored in
# $VAR_label variable.
#
# Arguments:
#
#   1- Value description
#   2- Variable to store the selected label
#   *- List of labels
#
choose() {
  text="$1"
  var="$2"
  shift 2
  local prompt="$(bold_white "$text:")"
  local i=0
  local options=()
  for option in "$@"; do
    prompt="$prompt
$(bold_white "($i)") - $(yellow "$option")"
    ((i++))
    options+=("$option")
  done
  prompt="$prompt
"
  size=$(($i / 10 + 1))
  read -p "$prompt" -n$size $var
  echo ""
  set_var "${var}_label" "${options[$REPLY]}"
}
