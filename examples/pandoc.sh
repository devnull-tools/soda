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

# Example of using pandoc

parameter "open-file[=PROGRAM]" "Open the generated file after compilation"

task "parse FILE OUTPUT_FORMAT" \
     'Parses the given file and outputs it in a file $FILE.$OUTPUT_FORMAT'
function parse {
  local basename="$(basename "$1")"
  pandoc -o "${basename%%.*}.$2" -S -s "$1" && {
    success "pandoc converting"
    # Checks if the parameter was set
    if [[ $open_file ]]; then
      if [[ ${open_file} == true ]]; then
        message "Opening file using kde-open"
        # opens the file using kde system
        kde-open "${basename%%.*}.$2" &
      else
        message "Opening file using $open_file"
        $open_file "${basename%%.*}.$2" &
      fi
    fi
  }
}

function parse_bash_completion {
  if [[ -f "$1" ]]; then
    # Only a few output examples
    echo "html pdf docx odt"
  else
    return 1
  fi
}
