#!/bin/bash

install_app(){

        if [ -n "`which code`" ]; then
 
           echo "\e[1;32m Application already Existing... \e[0m"
           exit 1
        fi

	echo "\e[1;34m  Installing required additional utilities\e[0m"
	sudo apt update &&
		sudo apt install software-properties-common apt-transport-https wget -y

	echo "\e[1;34m  Importing GPG key and enbling the repository \e[0m"
	wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
         if [ -z "`grep 'https://packages.microsoft.com/repos/vscode' /etc/apt/sources.list|grep -v '#'`" ]; then
	    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
         fi

	echo "\e[1;34m  Install VScode"
	sudo apt update &&
		sudo apt install code -y
		if [ $? -eq 0 ]; then
			echo "\e[1;32m  Application install Successfull. \e[0m"
		else
			echo "\e[1;31m  Application install failed.  Exiting!!... \e[0m"
			exit 1
		fi 
}

uninstall_app(){

 if [ -n "`which code`" ]; then
 
         sudo apt update &&
		sudo apt remove code -y
		if [ $? -eq 0 ]; then
			echo "\e[1;32m  Application uninstall Successfull. \e[0m"
		else
			echo "\e[1;31m  Application uninstall failed.  Exiting!!... \e[0m"
			exit 1
		fi
 else
			echo "\e[1;32m  Application already uninstalled. \e[0m"
			exit 1
        
 fi

}

###Main

if [ "$1" = "--uninstall" ]; then
echo "\e[1;34m  VScode uninstall initiated!!! \e[0m"
	uninstall_app
	exit 0
fi


echo "\e[1;34m  VScode and dependency install initiated!!! \e[0m"
install_app
