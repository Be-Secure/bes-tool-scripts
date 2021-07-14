#!/bin/bash

PUBKY="https://api.bintray.com/orgs/jfrog/keys/gpg/public.key"
REPOURL="https://jfrog.bintray.com/artifactory-debs"

install_app(){

	systemctl --all --type service | grep  -q "artifactory.service"
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

        grep -q 'artifactory' /etc/group
        
         if [ $? -ne 0 ]; then
            addgroup artifactory
         fi;

        grep -q 'artifactory' /etc/passwd
        
        if [ $? -ne 0 ]; then
          adduser --system --ingroup artifactory artifactory
        fi;
	
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

uninstall_app(){

        systemctl --all --type service | grep  -q "artifactory.service"
	if [ $? -ne 0 ]; then
		echo "\e[1;34m  Application already uninstalled. Exiting... \e[0m"
		exit 1
	fi

        if [ "`systemctl show -p ActiveState --value artifactory.service`" = "active" ]; then
            
            echo "\e[1;32m  Stopping Artifactory Service \e[0m"
            systemctl stop artifactory.service
            i=1
            while [ i<5 -a "`systemctl show -p ActiveState --value artifactory.service`" = "inactive" ]; do
                          echo "\e[1;32m  Waiting for Service to stop \e[0m"
              sleep 5
              i=i+1
            done
        fi
        
        apt remove jfrog-artifactory-oss -y
        if [ $? -eq 0 ]; then
			echo "\e[1;32m  Application uninstall Successfull. \e[0m"
                        echo "\e[1;32m  Cleaning up existing backup Directory \e[0m"
                        rm -rf "/var/opt/jfrog"
                        rm -rf "/opt/jfrog"
                        rm -rf "/home/artifactory"
                        
		else
			echo "\e[1;31m  Application uninstall failed.  Exiting!!... \e[0m"
			exit 1
		fi
         

}


####MAIN 

if [ "$1" = "--uninstall" ]; then
echo "\e[1;34m  Initiating Jfrog artifactory uninstall!!! \e[0m"
	uninstall_app
	exit 0
fi

echo "\e[1;37m  Initiating Jfrog artifactory install!!! \e[0m"
install_app
