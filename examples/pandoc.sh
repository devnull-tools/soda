#!/bin/sh

task "compile FILE OUTPUT_FORMAT" "Parses the given file and outputs a html"
function compile {
  local basename="$(basename "$1")"
  pandoc -o "${basename%%.*}.$2" -S -s "$1"
}

function compile_bash_completion {
  if [[ -f "$1" ]]; then
    echo "html pdf docx"
  else
    ls
  fi
}
