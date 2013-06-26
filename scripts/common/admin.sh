#!/bin/sh

# Indicates that a reboot is required to finish the process
function require_reboot {
  REBOOT_REQUIRED=true
}

function finish {
  [ "$REBOOT_REQUIRED" == true ] && {
    warn "A reboot was required to complete process!"
    invoke "Reboot system" "reboot"
  }
}

function reboot {
  warn "Rebooting system now!"
  init 6
}

function set_proxy {
  message "Configuring proxy variables"

  input "proxy server" "proxy_server"

  execute "Exporting http_proxy variable" export http_proxy="$proxy_server"
  execute "Exporting HTTP_PROXY variable" export HTTP_PROXY="$proxy_server"
}

function export_display {
  input "IP to export display" "display_to"

  execute "Exporting display" export DISPLAY="$display_to:0"
}

function disable_selinux {
  message "Disabling SELINUX"

  execute "Changing enforce" setenforce 0
  execute "Changing selinux file" sed -ie "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
  
  warn "Reboot to apply settings"
  require_reboot
}

function disable_firewall {
  message "Disabling Firewall"

  execute "Stopping iptables service" service iptables stop
  execute "Turning off iptables service" chkconfig iptables off
}
