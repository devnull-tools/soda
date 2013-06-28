#/bin/sh

function remove_remote_package {
  input "server" "SSH_SERVER"
  input "user" "SSH_USER" "root"
  input "directory" "DEST_DIR" "/tmp/."

  ssh $SSH_USER@$SSH_SERVER "cd $DEST_DIR; rm -rf soda soda.zip"
  check "Removing soda package"
}

function build_remote_package {
  local temp=/tmp/soda
  rm -rf $temp
  mkdir $temp

  cd $SODA_DIR

  execute "Copying main program" cp soda $temp
  execute "Copying configuration files" cp soda.conf $temp
  execute "Copying scripts" cp -r scripts $temp
  execute "Copying user files" cp -r $SODA_USER_DIR $temp

  echo "SODA_USER_DIR=.soda" >> $temp/soda.conf
  
  rm -rf build
  mkdir build
  
  cd /tmp

  local package=$SODA_DIR/build/soda.zip

  execute "Creating soda package" zip -r $package soda
  execute "Removing temporary files" rm -rf $temp

  [[ -f "$package" ]] && {
    message "Soda package created at $package"
  } || {
    error "Soda package not build"
  }
}

function send_soda_package {
  input "server" "SSH_SERVER"
  input "user" "SSH_USER" "root"
  input "directory" "DEST_DIR" "/tmp/."

  scp $SODA_DIR/build/soda.zip $SSH_USER@$SSH_SERVER:$DEST_DIR
  check "Sending package"
}

function execute_soda_package {
  input "server" "SSH_SERVER"
  input "user" "SSH_USER" "root"
  input "directory" "DEST_DIR" "/tmp/."

  message "Executing soda"
  ssh $SSH_USER@$SSH_SERVER "cd $DEST_DIR; rm -rf soda; unzip soda.zip ; cd soda ; ./soda $SODA_PARAMETERS $@ ;"
  
  invoke "Remove soda package from server" remove_remote_package
}

public "remote" "Invokes the function in a remote server using ssh"

function remote {
  ask "Build package" && {
    build_remote_package
    send_soda_package
  } || {
    ask "Send package" && send_soda_package
  }

  execute_soda_package $@
}
