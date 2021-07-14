#!/bin/sh -e
#
## Setup variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_NAME=${INSTALL_NAME:-maven}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-3.6.3}
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/apache-maven-$INSTALL_VERSION-bin.tar.gz
INSTALL_DIR=$INSTALL_BASE/$INSTALL_NAME-$INSTALL_VERSION
#
#Ensure artifact is present
check_artifact(){

	if [ ! -f $ARTIFACT_TARBALL ]; then
	
		sudo mkdir -p $INSTALL_ARTIFACTS_DIR
		if [ ! -z "$2" ]; then 
			INSTALL_VERSION="$2"
		fi
		
		echo "Initiating installation process for Mavan version : $INSTALL_VERSION"
		sudo wget --no-check-certificate  https://mirrors.estointernet.in/apache/maven/maven-3/$INSTALL_VERSION/binaries/apache-maven-$INSTALL_VERSION-bin.tar.gz  -P  $INSTALL_ARTIFACTS_DIR
		if [  $? -ne 0 ]; then
			echo "Source download failed!!!"
			exit 1
		fi
	fi
}


###MAIN
#
if [ "$1" = "--uninstall" ]; then
  update-alternatives --remove mvn $INSTALL_DIR/bin/mvn
  rm -fr $INSTALL_DIR
  exit 0
fi
#
check_artifact 
## Pre-requisites
echo " Pre-requisites Installation initiated..."
sudo apt update && 
	sudo apt install -y openjdk-8-jdk
	if [ $? -eq 0 ] ; then	
		echo "Pre-requisites Installation completed successfully..."	
	else	
		echo "issue with Pre-requisites, Please check!!!"
	fi
#
# remove any previous dir
echo "mavan untaring and path setting started!"
rm -fr $INSTALL_DIR && 
cd $INSTALL_BASE && sudo tar zxf $ARTIFACT_TARBALL &&
mv $INSTALL_BASE/apache-$INSTALL_NAME-$INSTALL_VERSION $INSTALL_DIR

# Add to path
update-alternatives --install /usr/bin/mvn mvn $INSTALL_DIR/bin/mvn 1
if [ $? -ne 0 ]; then	
	echo "Mavan configure failed!!!"
	exit 1 
else
	# success message
	cat <<EOF
	Maven $INSTALL_VERSION installed successfully. Run following command to test
	mvn --version
EOF
fi
