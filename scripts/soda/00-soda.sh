#!/bin/sh

parameter "import=NAMESPACE" "Import the given namespace" && {
  import "$import"
}

parameter "help" "Print the help message." && {
  usage "$help"
}

parameter "options=NAME" "Load the \$SODA_USER_DIR/options/NAME.conf file" && {
  . $SODA_USER_DIR/options/$options.conf
}

task "help [NAMESPACE]" "Print the help message for the given namespace (leave empty for all)"

function help {
  usage "$1"
}
