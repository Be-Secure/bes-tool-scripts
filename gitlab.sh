#!/bin/sh -e
#
###Main
#Uninstall command block
if [ "$1" = "--uninstall" ]; then
  echo "Uninstalling Gitlab community edition"
  gitlab-ctl uninstall
  gitlab-ctl cleanse
  gitlab-ctl remove-accounts
  dpkg -P gitlab-ce
  rm -fr /opt/gitlab \
     /var/opt/gitlabl \
     /etc/gitlab \
     /var/log/gitlab
  exit 0
fi

echo " Pre-requisites Installation initiated..."
apt-get update 
#
echo "Installing curl, openssh-server, ca-certificates, tzdata"
apt-get install -y curl openssh-server ca-certificates tzdata
	if [ $? -eq 0 ] ; then	
		echo "Pre-requisites Installation completed successfully..."	
	else	
		echo "issue with Pre-requisites, Please check!!!"
	fi

# Download install script
fetch_source(){
	curl -o /tmp/script.deb.sh -L https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh
	if [ $? -ne 0 ]; then 
		echo "script download failed"
		exit 1
	fi
	chmod +x /tmp/script.deb.sh
	/tmp/script.deb.sh
}

# Install gitlab from repo
echo "Initiating with gitlab community installation."
	apt-get update
	apt-get install -y gitlab-ce

# Reconfigure
echo "Initiating reconfiguration of installed gitlab"
	sudo gitlab-ctl reconfigure


