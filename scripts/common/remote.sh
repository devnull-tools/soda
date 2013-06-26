#/bin/sh

function remove_soda_package {
  ssh $SSH_USER@$SSH_SERVER "cd $DEST_DIR; rm -rf soda soda.zip"
  check "Removing soda package"
}

public "build" "Builds the soda package"

function build {
  temp=/tmp/soda
  rm -rf $temp
  mkdir $temp

  cd $SODA_DIR

  execute "Copying main program" cp soda $temp
  execute "Copying configuration files" cp soda.conf $temp
  execute "Copying scripts" cp -r scripts $temp
  execute "Copying user files" cp -r $SODA_USER_DIR $temp

  echo "SODA_USER_DIR=.soda" >> $temp/soda.conf

  check "Creating custom configuration"

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
  scp build/soda.zip $SSH_USER@$SSH_SERVER:$DEST_DIR
  check "Sending package"
}

function execute_soda_package {
  message "Executing soda"
  ssh $SSH_USER@$SSH_SERVER "cd $DEST_DIR; rm -rf soda; unzip soda.zip ; cd soda ; ./soda $@ ;"
  
  check "Executing package"
  invoke "Remove soda package from server" remove_soda_package
}

public "remote" "Invokes the function in a remote server"
function remote {
  input "server" "SSH_SERVER"
  input "user" "SSH_USER" "root"
  input "directory" "DEST_DIR" "/tmp/."

  ask "Build package" && build
  ask "Send package" && send_soda_package

  execute_soda_package $@
}

public "install_ssh_keys" "Installs the ssh keys in $SODA_USER_DIR for login without password"

function install_ssh_keys {
  ssh_dir=$HOME/.ssh
  [[ -d "$ssh_dir" ]] || execute "Creating ssh dir" mkdir $ssh_dir
  cat $SODA_USER_DIR/resources/authorized_keys >> $ssh_dir/authorized_keys
  check "Installing SSH Authorized Keys"
}
