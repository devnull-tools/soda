#/bin/sh

PUBLIC_FUNCTIONS_USAGE="Public functions:"

function public {
  PUBLIC_FUNCTIONS_USAGE="$PUBLIC_FUNCTIONS_USAGE
  $(printf "%-30s" "${1//_/-}") $2"
}

function import {
  load_scripts "$SODA_USER_DIR/scripts/$1"
}
