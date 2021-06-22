#!/bin/bash
#

uninstall_module(){
 
        echo "\e[1;34m This operation would unstall the listed modules : pybuilder, bandit \e[0m"
	python3 -m pip uninstall bandit pybuilder
		if [ $? -ne 0 ]; then
			echo "\e[1;31m Uninstall Failed \e[0m"
		else
			echo "\e[1;32m Uninstall Successfull \e[0m"
		fi 
}

install_module(){
	python3 -m pip install pybuilder bandit
	if [ $? -eq 0 ]; then
		echo "\e[1;32m  Installed pybuilder bandit and pip \e[0m"
	else
		echo "\e[1;31m  Install failed. Existing !! \e[0m"
		exit 1
	fi
}

install_app(){

    echo "\e[1;34m Initiating pip/pybuilder/bandit installation \e[0m"
    python3 -m pip --version
    if [ $? -eq 0 ]; then	
	install_module
    else
	echo "\e[1;34m Installing python3. \e[0m"

	apt update &&
	apt install -y python3-pip
	if [ $? -ne 0 ]; then
		echo "\e[1;31m Python3 install failed, Please do a mannual install  \e[0m"
		exit 1
	fi 
	install_module
	

     fi 

}	

###Main

if [ "$1" = "--uninstall" ]; then
	uninstall_module
	exit 1
fi

install_app
