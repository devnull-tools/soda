#!/bin/sh

function red {
  printf "\e[0;31m$1\e[0;0m"
}

function green {
  printf "\e[0;32m$1\e[0;0m"
}

function yellow {
  printf "\e[0;33m$1\e[0;0m"
}

function blue {
  printf "\e[0;34m$1\e[0;0m"
}

function magenta {
  printf "\e[0;35m$1\e[0;0m"
}

function cyan {
  printf "\e[0;36m$1\e[0;0m"
}

function gray {
  printf "\e[0;37m$1\e[0;0m"
}

function white {
  printf "\e[0;37m$1\e[0;0m"
}

function bold_gray {
  printf "\e[1;30m$1\e[0;0m"
}

function bold_red {
  printf "\e[1;31m$1\e[0;0m"
}

function bold_green {
  printf "\e[1;32m$1\e[0;0m"
}

function bold_yellow {
  printf "\e[1;33m$1\e[0;0m"
}

function bold_blue {
  printf "\e[1;34m$1\e[0;0m"
}

function bold_magenta {
  printf "\e[1;35m$1\e[0;0m"
}

function bold_cyan {
  printf "\e[1;36m$1\e[0;0m"
}

function bold_white {
  printf "\e[1;37m$1\e[0;0m"
}

[[ "$NO_COLORS" == true ]] && import "soda/no-colors"
