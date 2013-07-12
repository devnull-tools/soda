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
# Invokes a function based on user choice.
#
# Arguments:
#
#   1- Function description (used in the question message)
#   2- Function name
#
# If there is a variable named exactly like the function, its
# value will be used instead of asking user.
#
invoke() {
  if [[ -n "$(type -t $2)" ]]; then
    local option="$(get_var "$2")"
    if [[ -z "$option" ]]; then
      local prompt="$(bold_white "$1?")"
      local open="$(bold_white '(')"
      local close="$(bold_white ')')"
      local sep="$(bold_white '/')"
      local yes="$(green "[")Y$(green "]")es"
      local no="$(red "[")N$(red "]")o"
      local always="$(bold_green "[")A$(bold_green "]")lways"
      local never="n$(red "[")E$(red "]")ver"
      prompt="$prompt ${open}${yes}${sep}${no}${sep}${always}${sep}${never}${close}"
      read -p "$prompt " -n1 option
      echo ""
      if [[ "$option" =~ ^[Aa]$ ]]; then
        # sets the var for always invoke
        set_var "$2" "y"
        option="y"
      elif [[ "$option" =~ ^[Ee]$ ]]; then
        # sets the var for never invoke
        set_var "$2" "n"
        option="n"
      fi
    fi
    if [[ "$option" =~ ^[Yy]$ ]]; then
      log_debug "Invoking $2"
      $2
    fi
  else
    log_error "$2 not defined"
  fi
}

#
# Asks user about something and indicates if the answer is 'yes' or 'no'
#
ask() {
  prompt="$(bold_white "$1 (")$(bold_green 'y')$(bold_white '/')$(bold_green 'N')$(bold_white ')')"
  read -p "$prompt " -n1
  echo ""
  if [[ "$REPLY" =~ ^[Yy] ]]; then
    return 0
  else
    return 1
  fi
}

#
# Checks if the previous command returned successfully.
#
# Arguments:
#
#  1- The command description
#
check() {
  code="$?"
  if [[ $code == 0 ]]; then
    log_ok "$1"
  else
    log_fail "$1" $code
    broadcast "fail" "$code"
  fi
}

#
# Executes a command and checks if it was sucessfull. The output will be redirected
# to $LOG_FILE
#
# Arguments:
#
#  1- The command description
#  ...- The command itself (and parameters)
#
execute() {
  description=$1
  shift
  printf "%-60s " "$description"
  "$@" &>>$LOG_FILE
  code="$?"
  if [[ $code == 0 ]]; then
    printf "[  %s  ]\n" "$(green "OK")"
    file_log "OK" "$description"
  else
    printf "[ %s ]\n" "$(red "FAIL")"
    file_log "FAIL" "$description"
    broadcast "fail" "$code"
  fi
}
