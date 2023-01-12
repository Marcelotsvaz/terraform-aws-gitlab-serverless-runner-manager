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
instanceId=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
mv /tmp/deploy/config.toml /etc/gitlab-runner/config.toml
sed -Ei 's|url = "(.*)"$|url = "\1/'${instanceId}'/"|g' ${_}	# Apppend workerId to URL.
chmod 600 ${_}
systemctl enable --now gitlab-runner



echo 'Finished Instance Configuration Script.'