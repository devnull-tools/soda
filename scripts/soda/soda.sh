#!/bin/sh
#                            The MIT License
#
#        Copyright (c) 2013 Marcelo Guimaraes <ataxexe@gmail.com>
# ----------------------------------------------------------------------
# Permission  is hereby granted, free of charge, to any person obtaining
# a  copy  of  this  software  and  associated  documentation files (the
# "Software"),  to  deal  in the Software without restriction, including
# without  limitation  the  rights to use, copy, modify, merge, publish,
# distribute,  sublicense,  and/or  sell  copies of the Software, and to
# permit  persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The  above  copyright  notice  and  this  permission  notice  shall be
# included  in  all  copies  or  substantial  portions  of the Software.
#                        -----------------------
# THE  SOFTWARE  IS  PROVIDED  "AS  IS",  WITHOUT  WARRANTY OF ANY KIND,
# EXPRESS  OR  IMPLIED,  INCLUDING  BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN  NO  EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM,  DAMAGES  OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT  OR  OTHERWISE,  ARISING  FROM,  OUT OF OR IN CONNECTION WITH THE
# SOFTWARE   OR   THE   USE   OR   OTHER   DEALINGS  IN  THE  SOFTWARE.

parameter "help" "Print the help message." && {
  usage
}

parameter "options=NAME" "Load all NAME.conf file inside \$SODA_USER_DIR/options" && {
  for conf in $(find $SODA_USER_DIR/options -type f -name "$value.conf"); do
    source $conf
  done
}

task "help [NAMESPACE]" "Print the help message for the given namespace (leave empty for all)"
help() {
  usage "$1"
}

help_bash_completion () {
  namespaces
}

task bash_completion_parameter "Show proposals for parameters"
bash_completion_parameter () {
  if [[ $# -ge 1 ]]; then
    parse_task "$1" && {
      clear_help_usage
      clear_imports
      import "$NAMESPACE"
    } || {
      import soda
      import common
    }
  else
    import_all_namespaces
  fi
  echo "$BASH_COMPLETION_PARAMETERS"
}

task "bash_completion_task [TASK]" "Show proposals for autocomplete tasks"
bash_completion_task() {
  parse_task "$1" && {
    import "$NAMESPACE"
  }
  if [[ $(type -t "${TASK}${SODA_TASK_BASH_COMPLETION_SUFFIX}") ]]; then
    shift
    "${TASK}${SODA_TASK_BASH_COMPLETION_SUFFIX}" "$@"
  elif [[ $# == 0 ]]; then
    import_all_namespaces
    echo "$BASH_COMPLETION_TASKS"
  else
    task_exists "$1" && {
      exit 1
    } || {
      import_all_namespaces
      echo "$BASH_COMPLETION_TASKS"
    }
  fi
}
