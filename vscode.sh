#!/bin/bash

echo "VScode install initiated!!!"

install_app(){

	echo "Installing requried additional utilities"
	sudo apt update &&
		sudo apt install software-properties-common apt-transport-https wget

	echo "Importing GPG key and enbling the repository"
	wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

	echo "install VScode"
	sudo apt update &&
		sudo apt install code
}

###Main

install_app
