#!/bin/sh

parameter "import=NAMESPACE" "Import the given namespace" && {
  import "$import"
}

parameter "help" "Print the help message." && {
  usage "$help"
}

parameter "options=NAME" "Load all NAME.conf file inside \$SODA_USER_DIR/options" && {
  for conf in $(find $SODA_USER_DIR/options -type f -name "$options.conf"); do
    source $conf
  done
}

task "help [NAMESPACE]" "Print the help message for the given namespace (leave empty for all)"

function help {
  usage "$1"
}

function help_bash_completion {
  namespaces
}
