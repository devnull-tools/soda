#!/bin/sh

function login_users {
  cat /etc/passwd | grep -v nologin
}

function user_home {
  echo "$1" | cut -d: -f6
}

function user_login {
  echo "$1" | cut -d: -f1
}
