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

parameter "no_colors" "Do not use colors" && {
  function _color_escape {
    printf "$3"
  }
}
