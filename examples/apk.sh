#!/bin/bash
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

# Example of handling apk files for renaming and install

task name "APK" "Extracts the apk name from its Android Manifest"
name() {
  retain_set="[A-Za-z0-9-_.+[:blank:]]"
  label_patterns=("application: label=" "launchable activity name=")
  for pattern in ${label_patterns[@]}
  do
    label=$(aapt d badging "$1" | grep $pattern | cut -d\' -f2- | rev | cut -d\' -f4- | rev | \
     tr -dc $retain_set)
    [ -n "$label" ] && break
  done
  echo $label
}

task install "APK" "Installs the apk file in device"
install() {
  for apk in "$@";
  do
    adb install -r "$apk"
  done
}

task version "APK" "Extracts the apk version from its Android Manifest"
version() {
  version=$(aapt d badging "$1" | grep "versionName=" | cut -d\' -f6)
  echo $version
}

task rename "APK|DIR" \
    "Renames the desired apks based on the Android Manifest. Replaces whitespaces with underscores."
rename() {
  if [[ -d "$1" ]]; then
    dir=$1
    [ -z "$dir" ] && dir=.
    find $dir -type f -name "*.apk" -exec soda $NAMESPACE.rename {} \;
  else
    whitespace_replace=_
    for apk in "$@";
    do
      apk_dir=$(dirname "$apk")
      label=$(name "$apk")
      [ -n "$label" ] && {
        version=$(version "$apk")
        [ -z "$version" ] && {
          name=$label
        } || {
          name="$label-$version"
        }
        name=$(echo "$name" | sed "s/\s/$whitespace_replace/g").apk
        message "$apk > $name"
        mv "$apk" "$apk_dir/$name"
      }
    done
  fi
}
