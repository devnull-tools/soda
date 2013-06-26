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

  cp soda $temp
  cp soda.conf $temp
  cp -r scripts $temp
  cp -r $SODA_USER_DIR $temp

  echo "SODA_USER_DIR=.soda" >> $temp/soda.conf

  rm -rf build
  mkdir build
  
  cd /tmp

  zip -r $SODA_DIR/build/soda.zip soda
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

public "install_ssh_keys" "Installs the configured ssh keys for login without password"

function install_ssh_keys {
  ssh_dir=/root/.ssh
  [ -d "$ssh_dir" ] || execute "Creating ssh dir" mkdir $ssh_dir
  cat ./config/authorized_keys >> $ssh_dir/authorized_keys
  check "Installing SSH Authorized Keys"
}

