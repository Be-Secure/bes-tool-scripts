#!/bin/bash

#Installing the Requried packages. 
install_app(){

	## Pre-requisites
	echo " Pre-requisites Installation initiated..."
	apt update
	apt dist-upgrade
	apt-get install -y software-properties-common
	if [ $? -eq 0 ] ; then	
		echo "Pre-requisites Installation completed successfully..."	
	else	
		echo "issue with Pre-requisites, Please check!!!"
	fi
	
	echo "Setting up repository !!!"
	add-apt-repository ppa:mrazavi/openvas
	apt-get update

	echo -e "Initiating Openvas installation process!!\n"
	echo -e "You will be requested to configure Redis database for OpenVAS while installation ongoing \n"	
	 apt-get install -y openvas9
	if [ $? -ne 0 ]; then	
			echo "package installation failed."
			exit 1 
	fi

}
#Installing the dependent application including database for OpenVAS
install_dep(){
	echo -e "Installing SQLite 3 database and other dependencies for OpenVAS\n"
	echo -e "The SQLite 3 database package stores the Common Vulnerabilities and Exposures (CVE) data and some other packages for the PDF report to work\n"
    apt install -y sqlite3
    apt install -y texlive-latex-extra --no-install-recommends
	apt install -y texlive-fonts-recommended
	apt install -y libopenvas9-dev

}

###Main

if [ "$1" = "--uninstall" ]; then
   
   echo "uninstalling OpenVAS and its dependencies"
   apt-get remove --auto-remove openvas
   if [ $? -ne 0 ]; then	
			echo "package installation failed."
			exit 1 
	fi
    apt-get purge --auto-remove openvas  
	exit 0
	
fi 
#
install_app
install_dep
#
#Downloading Network Vulnerability Tests
echo "Downloading Network Vulnerability Tests from OpenVAS Feed"

	greenbone-nvt-sync && 
	greenbone-scapdata-sync &&
	greenbone-certdata-sync
#
	if [ $? -ne 0 ]; then	
			echo "Downloading failed.!!!"
			exit 1 
	fi
	
echo "Proceeding with restart of the OpenVAS scanner, OpenVAS GSA and OpenVAS Manager "	

	service openvas-scanner restart &&
	service openvas-manager restart &&
	service openvas-gsa restart  &&
	service openvas-scanner status 
	if [ $? -ne 0 ]; then	
			echo "Restart attempt failed, Please check!!!"
			exit 1 
	fi
	
	openvasmd --rebuild --progress
