#!/bin/sh

# Subscribe to an event
when() {
  local event="${1//-/_}"
  local subscriber="${2//-/_}"
  log_debug "$subscriber subscribed to $event"
  append_to_var "SODA_EVENT_${event}" " $subscriber"
}

# Broadcast an event
broadcast() {
  local event="${1//-/_}"
  log_debug "Broadcasting event $event"
  shift
  subscribers=$(get_var SODA_EVENT_${event})
  for subscriber in $subscribers; do
    log_debug "Notifying $subscriber"
    $subscriber "$@"
  done
}

parameter "no-broadcast" "$SODA_DESCRIPTION_NO_BROADCAST" && {
  broadcast() { :; }
}
