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

# Logs a message using 'DEBUG' category
log_debug() {
  log "DEBUG" "$1" "$SODA_COLOR_DEBUG"
}

# Logs a message using 'INFO' category
log_info() {
  log "INFO" "$1" "$SODA_COLOR_INFO"
}

# Logs a message using 'NOTICE' category
log_notice() {
  log "NOTICE" "$1" "$SODA_COLOR_NOTICE"
}

# Logs a message using 'WARN' category
log_warn() {
  log "WARN" "$1" "$SODA_COLOR_WARN"
}

# Logs a message using 'ERROR' category
log_error() {
  log "ERROR" "$1" "$SODA_COLOR_ERROR"
}

# Logs a message using 'FATAL' category
log_fatal() {
  log "FATAL" "$1" "$SODA_COLOR_FATAL"
}

# Logs a successfull operation
log_ok() {
  log "OK" "$1" "$SODA_COLOR_OK"
}

# Logs a failed operation
log_fail() {
  log "FAIL" "$1" "$SODA_COLOR_FAIL"
}

# Logs the given message
log() {
  local category="$1"
  local message="$2"
  local color="$3"
  file_log "$category" "$message"
  console_log "$category" "$message" "$color"
}

# Put a log message in $LOG_FILE
file_log() {
  printf "$SODA_FILE_LOG_PATTERN" "$(date +"${SODA_DATE_LOG_PATTERN}")" "$1" "$2" >> $LOG_FILE
}

# Put a log message in console
console_log() {
  local message="$(printf "$SODA_CONSOLE_LOG_PATTERN" "$1" "$2")"
  if [[ -n "$3" ]]; then
    echo "$($3 "$message")"
  else
    echo "$message"
  fi
}

parameter "no-file-log" "$SODA_DESCRIPTION_NO_FILE_LOG" && {
  file_log() { :; }
} || {
  if ! [[ -f "$LOG_FILE" ]]; then
    touch "$LOG_FILE"
  fi
}

parameter "no-console-log" "$SODA_DESCRIPTION_NO_CONSOLE_LOG" && {
  console_log() { :; }
}

parameter "verbose" "$SODA_DESCRIPTION_VERBOSE" && {
  LOG_LEVEL=DEBUG
}

if [[ -z "$LOG_LEVEL" ]]; then
  LOG_LEVEL=INFO
fi

parameter "LOG_LEVEL" "N" "$SODA_DESCRIPTION_LOG_LEVEL" && {
  case "$(uppercase ${LOG_LEVEL})" in
    DEBUG)
      ;;
    INFO)
      log_debug() { :; }
      ;;
    NOTICE)
      log_debug() { :; }
      log_info() { :; }
      ;;
    WARN)
      log_debug() { :; }
      log_info() { :; }
      log_notice() { :; }
      ;;
    ERROR)
      log_debug() { :; }
      log_info() { :; }
      log_notice() { :; }
      log_warn() { :; }
      ;;
    FATAL)
      log_debug() { :; }
      log_info() { :; }
      log_notice() { :; }
      log_warn() { :; }
      log_error() { :; }
      ;;
    NONE)
      log_debug() { :; }
      log_info() { :; }
      log_notice() { :; }
      log_warn() { :; }
      log_error() { :; }
      log_fatal() { :; }
      ;;
    *)
      echo "Invalid log-level: $LOG_LEVEL"
      exit 1
      ;;
  esac
}
