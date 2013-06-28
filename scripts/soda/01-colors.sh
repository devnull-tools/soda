#!/bin/sh

parameter "no_colors" "Do not use colors"

function _color_escape {
  printf "\e[$1;3$2m$3\e[0;0m"
}

function red {
  _color_escape 0 1 "$1"
}

function green {
  _color_escape 0 2 "$1"
}

function yellow {
  _color_escape 0 3 "$1"
}

function blue {
  _color_escape 0 4 "$1"
}

function magenta {
  _color_escape 0 5 "$1"
}

function cyan {
  _color_escape 0 6 "$1"
}

function gray {
  _color_escape 0 7 "$1"
}

function white {
  _color_escape 0 7 "$1"
}

function bold_gray {
  _color_escape 1 0 "$1"
}

function bold_red {
  _color_escape 1 1 "$1"
}

function bold_green {
  _color_escape 1 2 "$1"
}

function bold_yellow {
  _color_escape 1 3 "$1"
}

function bold_blue {
  _color_escape 1 4 "$1"
}

function bold_magenta {
  _color_escape 1 5 "$1"
}

function bold_cyan {
  _color_escape 1 6 "$1"
}

function bold_white {
  _color_escape 1 7 "$1"
}

if [[ "$no_colors" ]]; then
  function _color_escape {
    printf "$3"
  }
fi
