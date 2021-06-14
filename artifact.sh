#!/bin/bash

PUBKY="https://api.bintray.com/orgs/jfrog/keys/gpg/public.key"
REPOURL="https://jfrog.bintray.com/artifactory-debs"

 echo "Installing Java for Jfrog Artifactory"
 apt-get update
 apt-get install default-jdk -y
 
 java -version
 if [ $? -eq 0 ]; then
	
	wget -qO - $PUBKY |  apt-key add - 
	add-apt-repository "deb [arch=amd64] $REPOURL $(lsb_release -cs) main"
	apt-get update
	
	echo "Installing Jfrog artifactory"
	apt install jfrog-artifactory-oss -y
	
	echo "Setting up services!!!"
	for i in start enable status ; do
		systemctl $i artifactory.service
	done 
	if [ $? -eq 0 ]; then
		echo "Install succesfull"
	else
		echo "Failed installation, Please check logs"
	fi 
 fi
 
 echo "Java install failed !!"
