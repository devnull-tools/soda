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
# If there is a variable named as $2, the input will be skipped.
#
function input {
  if [[ -z "$(get_var $2)" ]]; then
    printf "$(bold_white "$1"): "
    if [[ -n "$3" ]]; then
      printf $(bold_white "[")$(bold_green "$3")$(bold_white "]")
    fi
    echo ""
    printf "$(yellow " > ")"
    read $2
    if [[ "$(get_var $2)" == "" ]]; then
      set_var "$2" "$3"
    fi
  fi
  echo "# $1" >> $OPTIONS_FILE
  echo "$2=$(eval echo \$$2)" >> $OPTIONS_FILE
}

#
# Asks user to choose a value from a list.
#
# Arguments:
#
#   1- Value description
#   2- Variable to store input (the 0-based index of the values list)
#   *- List of values description
#
# If there is a variable named as $2, the choice will be skipped.
#
function choose {
  text=$1
  var=$2
  shift 2
  if [[ -z "$(get_var $var)" ]]; then
    puts bold_white "$text:"
    i=0
    for option in "$@"; do
      echo "  $(bold_white "($i)") - $(yellow "$option")"
      ((i++))
    done
    printf "$(yellow " > ")"
    read $var
  fi
  echo "# $text ($@)" >> $OPTIONS_FILE
  echo "$var=$(eval echo \$$var)" >> $OPTIONS_FILE
}
