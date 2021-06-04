#!/bin/bash
#
install_app(){

	apt update
	echo "Initiating PyPI installation based on the python version"
	ver=$(python -c"import sys; print(sys.version_info.major)")
	if [ $ver -eq 2 ]; then
		echo "Python version is 2 " 
		apt install -y python-pip
	elif [ $ver -eq 3 ]; then
		echo "Python version is 3 " 
		apt install -y python3-pip
	else 
		echo "Unknown python version"
		exit 1
	fi
}

###Main
#
if [ "$1" = "--uninstall" ]; then
	
	apt-get remove --purge python-pip
	if [ $? -ne 0 ]; then
		apt-get remove --purge python3-pip
			if [ $? -ne 0 ]; then
				echo "Uninstall Failed"
			fi 
	fi 
}

install_app
