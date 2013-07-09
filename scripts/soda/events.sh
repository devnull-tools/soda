#!/bin/sh

# Subscribe an event
subscribe() {
  local subscriber="$1"
  if [[ "$2" == "to" ]]; then
    local event="$3"
  else
    local event="$2"
  fi
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
