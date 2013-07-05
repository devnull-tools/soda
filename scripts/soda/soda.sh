#!/bin/sh

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

task bash_completion_parameter "Show proposals for parameters"
function bash_completion_parameter {
  if [[ $# -ge 1 ]]; then
    parse_task "$1" && {
      clear_help_usage
      clear_imports
      import "$NAMESPACE"
      echo "$BASH_COMPLETION_PARAMETERS"
    }
  else
    import_all_namespaces
    echo "$BASH_COMPLETION_PARAMETERS"
  fi
}

task "bash_completion_task [TASK]" "Show proposals for autocomplete tasks"
function bash_completion_task {
  parse_task "$1" && {
    import "$NAMESPACE"
  }
  shift
  if [[ $(type -t "${TASK}${SODA_TASK_BASH_COMPLETION_SUFFIX}") ]]; then
    "${TASK}${SODA_TASK_BASH_COMPLETION_SUFFIX}" "$@"
  else
    import_all_namespaces
    echo "$BASH_COMPLETION_TASKS"
  fi
}
