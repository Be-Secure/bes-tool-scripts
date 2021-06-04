#!/bin/bash
#
#Installing the Requried packages. 
install_app(){
	echo " Pre-requisites Installation initiated..."
	apt update &&
	apt dist-upgrade && 
	apt autoremove && 
	curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
	if [ $? -ne 0 ]; then	
			echo "Pre-requisites install/package fetching (msfupdate.erb) failed"
			exit 1 
	fi

	chmod 755 msfinstall
	sudo ./msfinstall >/dev/null 2>&1 &
	echo "Initiating msf db initialization!!!"
	msfdb init
	sudo msfupdate
	if [ $? -ne 0 ]; then	
			echo "Metasploit update failed!!!"
			exit 1 
	fi
}

##Main

if [ "$1" = "--uninstall" ]; then
   
   echo "Uninstalling metasploit-framework, its dependencies and local/config files for metasploit-framework \n"
   apt-get remove --auto-remove metasploit-framework
   apt-get purge --auto-remove metasploit-framework  
   exit 0
	
fi 

install_app
