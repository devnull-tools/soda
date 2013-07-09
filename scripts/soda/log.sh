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

# Puts a colorized text in the console
puts() {
  echo "$($1 "$2")"
}

# Displays an information message and logs it in the $LOG_FILE
message() {
  log "INFO" "$1"
  puts blue "INFO: $1"
}

# Displays a debug message and logs it in the $LOG_FILE
debug() {
  log "DEBUG" "$1"
  puts gray "DEBUG: $1"
}

# Displays a warn message and logs it in the $LOG_FILE
warn() {
  log "WARN" "$1"
  puts yellow "WARN: $1"
}

# Displays en error message and logs it in the $LOG_FILE
error() {
  log "ERROR" "$1"
  puts red "ERROR: $1"
}

# Logs a successfull operation
success() {
  log "OK" "$1"
  echo "$(printf "%-60s [  %s  ]" "$1" $(green "OK"))"
}

# Logs a failed operation
fail() {
  log "FAIL" "$1"
  echo "$(printf "%-60s [ %s ]" "$1" $(red "FAIL"))"
}

# Inserts a log message in $LOG_FILE
log() {
  printf "%s | %-6s | %s\n" $(date +%H:%M:%S) "$1" "$2" >> $LOG_FILE
}

parameter "no_log_files" "Do not use log files" && {
  log() { :; }
} || {
  # Clears the output files
  [[ -n "$LOG_FILE" ]]              > $LOG_FILE
  [[ -n "$COMMAND_LOG_FILE" ]]      > $COMMAND_LOG_FILE
  [[ -n "$LAST_COMMAND_LOG_FILE" ]] > $LAST_COMMAND_LOG_FILE
}

parameter "verbose" "Set the log level to DEBUG" && {
  log_level=0
}

if [[ ! $log_level ]]; then
  log_level=1
fi

parameter "log_level=N" "Set the log level (DEBUG=0 MESSAGE=1 WARN=2 ERROR=3 NONE=4)" && {
  case $value in
    1)
      debug() { :; }
      ;;
    2)
      debug() { :; }
      message() { :; }
      ;;
    3)
      debug() { :; }
      message() { :; }
      warn() { :; }
      ;;
    4)
      debug() { :; }
      message() { :; }
      warn() { :; }
      error() { :; }
      ;;
  esac
}
