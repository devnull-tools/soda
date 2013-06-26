#!/bin/sh

# Structure scripts (for users and directories)

public "colorize_users_bash" "Colorizes bash for all users that can login"

function colorize_users_bash {
  choose "server type" "SERVER_TYPE" "Unknown" "Production" "Development" "Test"

  users=$(login_users)
  for user in $users; do
    login=$(user_login $user)
    ask "Colorize bash for user $login" && {
      home=$(user_home $user)
      case $login in
        root)
          color=1
          ;;
        *)
          color=3
          ;;
      esac
      bash_colors "$home/.bashrc" $color $SERVER_TYPE 4
      check "Defining bash colors for $login user"
    }
  done
}

function bash_colors {
  cat >> $1 <<EOF
alias l='ls -lha --color=auto'
alias ll='ls -lha --color=auto'
alias grep="grep --color=auto"
EOF
  tput="tput"
  # when using ssh, the TERM variable will not be set in some cases
  [ "$TERM" == "dumb" ] && {
    tput="tput -T xterm"
  }
  echo "PS1='[\[$($tput setaf $2)\]\u\[$($tput sgr0)\]@\[$($tput setaf $3)\]\h\[$($tput sgr0)\] \[$($tput bold)$($tput setaf $4)\]\w\[$($tput sgr0)\]]\\\\$ '" >> $1
}
