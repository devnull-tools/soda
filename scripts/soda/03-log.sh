#!/bin/sh

# Puts a colorized text in the console
function puts {
  echo "$($1 "$2")"
}

# Displays an information message and logs it in the $LOG_FILE
function message {
  log "INFO" "$1"
  puts blue "INFO: $1"
}

# Displays a debug message and logs it in the $LOG_FILE
function debug {
  log "DEBUG" "$1"
  puts gray "DEBUG: $1"
}

# Displays a warn message and logs it in the $LOG_FILE
function warn {
  log "WARN" "$1"
  puts yellow "WARN: $1"
}

# Displays en error message and logs it in the $LOG_FILE
function error {
  log "ERROR" "$1"
  puts red "ERROR: $1"
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

parameter "no_log_files" "Do not use log files" && {
  function log { :; }
} || {
  # Clears the output files
  [[ -n "$LOG_FILE" ]]              > $LOG_FILE
  [[ -n "$OPTIONS_FILE" ]]          > $OPTIONS_FILE
  [[ -n "$COMMAND_LOG_FILE" ]]      > $COMMAND_LOG_FILE
  [[ -n "$LAST_COMMAND_LOG_FILE" ]] > $LAST_COMMAND_LOG_FILE
}

if [[ ! $log_level ]]; then
  log_level=1
fi

parameter "verbose" "Set the log level to DEBUG" && {
  log_level=0
}

parameter "log_level=N" "Set the log level (DEBUG=0 MESSAGE=1 WARN=2 ERROR=3 NONE=4)" && {
  case $log_level in
    1)
      function debug { :; }
      ;;
    2)
      function debug { :; }
      function message { :; }
      ;;
    3)
      function debug { :; }
      function message { :; }
      function warn { :; }
      ;;
    4)
      function debug { :; }
      function message { :; }
      function warn { :; }
      function error { :; }
      ;;
  esac
}
