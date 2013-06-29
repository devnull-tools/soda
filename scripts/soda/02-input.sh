#!/bin/sh

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
