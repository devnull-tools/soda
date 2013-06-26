#/bin/sh

PUBLIC_FUNCTIONS_USAGE="Public functions:"

function public {
  PUBLIC_FUNCTIONS_USAGE="$PUBLIC_FUNCTIONS_USAGE
  $(printf "%-30s" "${1//_/-}") $2"
}

function load_scripts {
  if [[ -d "$1" ]]; then
    for script in $(find $1 -type f -name "*.sh"); do
      debug "Loading $script"
      . $script
    done
  fi
}

function require {
  load_scripts "$SODA_USER_DIR/scripts/$1"
}
