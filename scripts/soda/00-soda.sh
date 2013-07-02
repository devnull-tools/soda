#!/bin/sh

parameter "import=NAMESPACE" "Import the given namespace" && {
  import "$import"
}

parameter "help" "Print this help message" && {
  usage
}

parameter "options=NAME" "Load the \$SODA_USER_DIR/options/NAME.conf file" && {
  . $SODA_USER_DIR/options/$options.conf
}
