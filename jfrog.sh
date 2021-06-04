#!/bin/bash
#
## Setup variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-7.11.5}
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/jfrog-artifactory-oss-$INSTALL_VERSION-linux.tar.gz
INSTALL_DIR=$INSTALL_BASE/artifactory-oss-$INSTALL_VERSION
#
#Ensure artifact is present
check_artifact_status(){
	echo "! -f $ARTIFACT_TARBALL "
	if [ ! -f $ARTIFACT_TARBALL ]; then
	
			sudo mkdir -p /vagrant/artifacts
			if [ ! -z "$2" ]; then 
					INSTALL_VERSION="$2"
			fi
	
			echo "Initiating installation process for JFrog artifactory version : $INSTALL_VERSION"
			sudo wget --no-check-certificate https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/$INSTALL_VERSION/jfrog-artifactory-oss-$INSTALL_VERSION-linux.tar.gz -P  $INSTALL_ARTIFACTS_DIR
			if [  $? -ne 0 ]; then
				echo "Source download failed!!!"
				exit 1
			fi
	fi
}
#
#
#Function to handle installation of the Artifactory. 
install_app(){

	## Pre-requisites
	echo " Pre-requisites Installation initiated..."
	
	sudo apt-get update &&
	sudo apt-get install -y openjdk-8-jdk
	if [ $? -ne 0 ]; then

		echo "Error occured either in either update or openjdc install!!"
		exit 1
	else	
	  	echo "Pre-requisites Installation completed successfully..."	
	fi

	# Remove any previous dir
	rm -fr $INSTALL_DIR &&
	cd $INSTALL_BASE && 
	tar zxf $ARTIFACT_TARBALL
	
	echo "JFrog installation initiated..."
	sudo $INSTALL_DIR/app/bin/installService.sh
	if [ $? -ne 0 ]; then 
		echo "Error in the install Script execution. Please fix and run it again!!!"
		exit 1	
	fi
	
	sudo systemctl start artifactory
	if [ $? -eq 0 ]; then 
		cat <<EOF
			JFrog Artifactory OSS $INSTALL_VERSION installed successfully and service Up and Running fine. 
			Use below URL and credentials to login

		http://localhost:8082/ui/login
		admin/password 
EOF
	fi 
}

###Main###
check_artifact_status  
if [ "$1" = "--uninstall" ]; then
  $INSTALL_DIR/app/bin/uninstallService.sh
  rm -fr $INSTALL_DIR
  exit 0
fi
install_app

