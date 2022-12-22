#!/usr/bin/env bash
# 
# VAZ Projects
# 
# 
# Author: Marcelo Tellier Sartori Vaz <marcelotsvaz@gmail.com>



echo 'Starting Instance Configuration Script...'



# Script Setup
#---------------------------------------
set -e	# Abort on error.



# System Setup
#---------------------------------------
echo ${ssh_key} > ~marcelotsvaz/.ssh/authorized_keys	# Admin user.
hostnamectl set-hostname ${hostname}

# Configure GitLab Runner.
mv /tmp/deploy/config.toml /etc/gitlab-runner/config.toml
chmod 600 ${_}
systemctl enable --now gitlab-runner



echo 'Finished Instance Configuration Script.'