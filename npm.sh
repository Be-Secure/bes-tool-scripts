#!/bin/sh -e
#
#Installing the Requried packages. 
install_app(){

	apt update
	echo "Proceeding with installation of nodejs and npm"
	apt install -y nodejs npm
	if [ $? -ne 0 ]; then	
			echo "package install failed."
			exit 1 
	fi
}

##Main

if [ "$1" = "--uninstall" ]; then
   
   echo "uninstalling nodejs and npm"
   npm uninstall npm -g
   apt-get purge --auto-remove nodejs
   exit 0
	
fi 

install_app

