#!/bin/sh

parameter "options=NAME" "Loads the $SODA_USER_DIR/options/NAME.conf file"

if [[ -n "$options" ]]; then
  . $SODA_USER_DIR/$options.conf
fi

# Dynamically sets a variable value
function set_var {
  eval "$1=$2"
}

# Dynamically gets a variable value
function get_var {
  eval echo "\$$1"
}
