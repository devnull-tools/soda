#!/bin/sh

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
