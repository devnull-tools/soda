#!/bin/sh

# Subscribe to an event
when() {
  local event="$1"
  local subscriber="$2"
  debug "$subscriber subscribed to $event"
  append_var "SODA_EVENT_${event}" " $subscriber"
}

# Broadcast an event
broadcast() {
  local event="$1"
  debug "Broadcasting event $event"
  shift
  subscribers=$(get_var SODA_EVENT_${event})
  for subscriber in $subscribers; do
    debug "Notifying $subscriber"
    $subscriber "$@"
  done
}

parameter "no_broadcast" "Disable broadcasting events" && {
  echo "Disabling Broadcasting"
  broadcast() { :; }
}
