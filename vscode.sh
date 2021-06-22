#!/bin/bash

install_app(){

	code --version
	if [ $? -eq 0 ]; then 
		echo "\e[1;32m  Application already installed. Exiting... \e[0m"
		exit 1
	fi 

	echo "\e[1;34m  Installing requried additional utilities\e[0m"
	sudo apt update &&
		sudo apt install software-properties-common apt-transport-https wget

	echo "\e[1;34m  Importing GPG key and enbling the repository \e[0m"
	wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main \e[0m"

	echo "\e[1;34m  Install VScode"
	sudo apt update &&
		sudo apt install code
		if [ $? -eq 0 ]; then
			echo "\e[1;32m  Application install Successfull. \e[0m"
		else
			echo "\e[1;31m  Application install failed.  Exiting!!... \e[0m"
			exit 1
		fi 
}

###Main

if [ -n $(which code) ]; then
 
 echo "\e[1;32m Application already Existing... \e[0m"
 exit 1
fi

echo "\e[1;34m  VScode and dependency install initiated!!! \e[0m"
install_app
