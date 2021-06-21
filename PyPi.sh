#!/bin/bash
#
install_module(){
	python3 -m pip install pybuilder bandit
}

install_app(){

	echo "\e[1;34m Initiating pip/pybuilder/bandit installation \e[0m"
    python3 --version
	if [ $? -eq 0 ]; then	
		install_module

	else
		echo "\e[1;34m Installing python3. \e[0m"

		apt update &&
		apt install python3.8
		if [ $? -ne 0 ]; then
			echo "\e[1;31m Python3 install failed, Please do a mannual install  \e[0m"
			exit 1
		fi 
		install_module
		echo "Installed pybuilder bandit and pip"

	fi 

}	

###Main

if [ "$1" = "--uninstall" ]; then
	
	apt-get remove --purge python-pip
	if [ $? -ne 0 ]; then
		apt-get remove --purge python3-pip
			if [ $? -ne 0 ]; then
				echo "\e[1;31m Uninstall Failed \e[0m"
			fi 
	fi 
fi

install_app
