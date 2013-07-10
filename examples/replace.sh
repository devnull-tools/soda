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

# Example for replacing strings in files

task "replace PATTERN OLD NEW [PATH]" \
"Replaces the text in all files that matches the pattern under the given directory"
replace() {
  SEARCH_PATTERN="$1"
  OLD_STRING="$2"
  NEW_STRING="$3"
  DIR_PATH="$4"
  if [[ -z "$DIR_PATH" ]]; then
    DIR_PATH="$(pwd)"
  fi
  for file_name in `find "$DIR_PATH" -type f -name "$SEARCH_PATTERN"`
  do
    # Tests if the file is a text file
    [[ $(file $file_name | grep -i "text")  ]] || continue
    # Tests if the file contains the old string
    [[ $(grep "$OLD_STRING" $file_name)  ]] || continue
    message "Found in $(basename "$file_name")"
    invoke "Replace changes in $(basename "$file_name")" replace_in_file
  done
}

parameter "backup[=EXTENSION]" ".bak" "Backups the changes with the extension"

replace_in_file() {
  execute "Replacing in $(basename "$file_name")" \
    sed -i$backup -e "s/${OLD_STRING}/${NEW_STRING}/g" "$file_name"
  if [[ -n "$backup" ]]; then
    invoke "Show diff" show_diff
  fi
}

show_diff() {
  diff "$file_name" "$file_name$backup"
}
