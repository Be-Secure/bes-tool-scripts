#!/bin/bash

PUBKY="https://api.bintray.com/orgs/jfrog/keys/gpg/public.key"
REPOURL="https://jfrog.bintray.com/artifactory-debs"

install_app(){

	systemctl status artifactory.service --no-pager
	if [ $? -eq 0 ]; then
		echo "\e[1;34m  Application already installed. Exiting... \e[0m"
		exit 1
	fi

	java -version
	if [ $? -ne 0 ]; then
		echo "\e[1;34m Installing openJdk... \e[0m"
		apt-get update &&
		 	apt-get install default-jdk -y
		if [ $? -ne 0 ]; then	
			echo "\e[1;31m JDK install failed!!! Exiting... \e[0m"
			exit 1
		fi 
	fi
	
	wget -qO - $PUBKY |  apt-key add - 
	add-apt-repository "deb [arch=amd64] $REPOURL $(lsb_release -cs) main"
	apt-get update
	
	echo "\e[1;37m Installing Jfrog artifactory \e[0m"
	apt install jfrog-artifactory-oss -y
	
	echo "\e[1;37m Setting up services!!! \e[0m"
	for i in start enable status ; do
		systemctl $i artifactory.service --no-pager 
	done 
	if [ $? -eq 0 ]; then
		echo "\e[1;32m  Install successfull \e[0m"
	else
		echo "\e[1;31m  Failed installation, Please check logs \e[0m"
	fi 

}


####MAIN 
echo "\e[1;37m  Initiating Jfrog artifactory install!!! \e[0m"
install_app
