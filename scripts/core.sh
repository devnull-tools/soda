#!/bin/sh

###################################################

function red {
  printf "\e[0;31m$1\e[0;0m"
}

function green {
  printf "\e[0;32m$1\e[0;0m"
}

function yellow {
  printf "\e[0;33m$1\e[0;0m"
}

function blue {
  printf "\e[0;34m$1\e[0;0m"
}

function magenta {
  printf "\e[0;35m$1\e[0;0m"
}

function cyan {
  printf "\e[0;36m$1\e[0;0m"
}

function gray {
  printf "\e[0;37m$1\e[0;0m"
}

function white {
  printf "\e[0;37m$1\e[0;0m"
}

function bold_gray {
  printf "\e[1;30m$1\e[0;0m"
}

function bold_red {
  printf "\e[1;31m$1\e[0;0m"
}

function bold_green {
  printf "\e[1;32m$1\e[0;0m"
}

function bold_yellow {
  printf "\e[1;33m$1\e[0;0m"
}

function bold_blue {
  printf "\e[1;34m$1\e[0;0m"
}

function bold_magenta {
  printf "\e[1;35m$1\e[0;0m"
}

function bold_cyan {
  printf "\e[1;36m$1\e[0;0m"
}

function bold_white {
  printf "\e[1;37m$1\e[0;0m"
}

#########################################################

[ -z "$OPTIONS_FILE" ] && OPTIONS_FILE=/dev/null
[ -z "$LOG_FILE" ] && LOG_FILE=/dev/null
[ -z "$COMMAND_LOG_FILE" ] && COMMAND_LOG_FILE=/dev/null
[ -z "$LAST_COMMAND_LOG_FILE" ] && LAST_COMMAND_LOG_FILE=/dev/null

#
# Invokes a function based on user choice. Additionally, a pre_$function
# and post_$function will be invoked if exists.
#
# Arguments:
#
#   1- Function description (used in the question message)
#   2- Function name
#
# If there is a variable named exactly like the function, its
# value will be used instead of asking user.
#
# The value will be stored in the $OPTIONS_FILE file
#
function invoke {
  [ -n "$(type -t $2)" ] && {
    option=$(get_var "$2")
    [ -z "$option" ] && {
      echo "$(bold_white "$1? (")$(bold_green 'y')$(bold_white '/')$(bold_green 'N')$(bold_white ')')"
      read option
    }
    echo "$2=$option" >> $OPTIONS_FILE
    echo "$option" | grep -qi "^Y$" && {
      [ -n "$(type -t "pre_$2")" ] && {
        debug "Invoking pre_$2"
        pre_$2
      }
      debug "Invoking $2"
      $2
      [ -n "$(type -t "post_$2")" ] && {
        debug "Invoking post_$2"
        post_$2
      }
    }
  }
}

#
# Asks user about something and returns true if
function ask {
  echo "$(bold_white "$1? (")$(bold_green 'y')$(bold_white '/')$(bold_green 'N')$(bold_white ')')"
  read option
  echo "$option" | grep -qi "^Y$"
}

#
# Checks if the previous command returned successfully.
#
# Arguments:
#
#  1- The command description
#
function check {
  code="$?"
  [ $code == 0 ] && {
    success "$1"
  } || {
    fail "$1" $code
  }
}

#
# Executes a command and checks if it was sucessfull
#
# Arguments:
#
#  1- The command description
#  ...- The command itself
#
function execute {
  description=$1
  shift
  printf "%-60s " "$description"
  $@ &>$LAST_COMMAND_LOG_FILE
  code="$?"
  cat $LAST_COMMAND_LOG_FILE >> $COMMAND_LOG_FILE
  [ $code == 0 ] && {
    printf "[  %s  ]\n" $(green "OK")
    log "OK" "$description"
  } || {
    printf "[ %s ]\n" $(red "FAIL")
    log "FAIL" "$description"
  }
}

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
  #TODO validate argument using validate_$3 and $4 will be the default value
  [ -z "$(get_var $2)" ] && {
    echo "$(bold_white "Input $1") $(bold_white "[")$(bold_green "$3")$(bold_white "]")"
    read $2
    [ "$(get_var $2)" == "" ] && set_var "$2" "$3"
  }
  echo "$2=$(eval echo \$$2)" >> $OPTIONS_FILE
}

#
# Asks user to choose a value from a list.
#
# Arguments:
#
#   1- Value description
#   2- Variable to store input (the 1-based index of the values list)
#   *- List of values description
#
# If there is a variable named as $2, the input will be skipped.
#
function choose {
  text=$1
  var=$2
  shift 2
  [ -z "$(get_var $var)" ] && {
    puts bold_white "Choose $text:"
    i=0
    for option in "$@"; do
      echo "  $(bold_white "($i)") - $(yellow "$option")"
      ((i++))
    done
    read $var
  }
  echo "$var=$(eval echo \$$var)" >> $OPTIONS_FILE
}

# Dynamically sets a variable value
function set_var {
  eval "$1=$2"
}

# Dynamically gets a variable value
function get_var {
  eval echo "\$$1"
}

# Puts a colorized text in the console
function puts {
  echo "$($1 "$2")"
}

# Displays an information message and logs it in the $LOG_FILE
function message {
  log "INFO" "$1"
  puts blue "$1"
}

# Displays a debug message and logs it in the $LOG_FILE
function debug {
  log "DEBUG" "$1"
  [ "$DEBUG" == true ] && puts gray "$1"
}

# Displays a warn message and logs it in the $LOG_FILE
function warn {
  log "WARN" "$1"
  puts yellow "$1"
}

# Displays en error message and logs it in the $LOG_FILE
function error {
  log "ERROR" "$1"
  puts red "$1"
}

# Logs a successfull operation
function success {
  log "OK" "$1"
  echo "$(printf "%-60s [  %s  ]" "$1" $(green "OK"))"
}

# Logs a failed operation
function fail {
  log "FAIL" "$1"
  echo "$(printf "%-60s [ %s ]" "$1" $(red "FAIL"))"
}

# Inserts a log message in $LOG_FILE
function log {
  printf "%s | %-6s | %s\n" $(date +%H:%M:%S) "$1" "$2" >> $LOG_FILE
}

# Aborts the script
function abort {
  exit $1
}

# Checks if the user exists
function exist_user {
  cut -d: -f1 /etc/passwd | grep "^$1$" > /dev/null
}
