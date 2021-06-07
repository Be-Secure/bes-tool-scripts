#!/bin/bash
#
#Installing the Requried packages. 
install_app(){

echo "Initiating  ruby and depedent packages installation"
 apt install -y ruby-dev libffi-dev make gcc &&
 gem install travis
	if [ $? -ne 0 ]; then	
			echo "package installation failed."
			exit 1 
	fi
}
##Main

if [ "$1" = "--uninstall" ]; then

	echo "Uninstalling Travis CI"
	gem uninstall travis-cli
   
fi
###MAIN
install_app
