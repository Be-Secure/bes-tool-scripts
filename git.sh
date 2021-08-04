#!/bin/bash

install_app(){

        if [ -n "`which git`" ]; then
 
           echo "\e[1;32m Application already Existing... \e[0m"
           exit 1
        fi

	

	echo "\e[1;34m  Install git"
	sudo apt update &&
		sudo apt install git -y
		if [ $? -eq 0 ]; then
			echo "\e[1;32m  Application install Successfull. \e[0m"
		else
			echo "\e[1;31m  Application install failed.  Exiting!!... \e[0m"
			exit 1
		fi 
}

uninstall_app(){

 if [ -n "`which git`" ]; then
 
         sudo apt update &&
		sudo apt remove git -y
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
echo "\e[1;34m  Git uninstall initiated!!! \e[0m"
	uninstall_app
	exit 0
fi


echo "\e[1;34m  Git install initiated!!! \e[0m"
install_app
