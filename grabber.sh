#!/bin/sh -e
#
## Setup variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_NAME=${INSTALL_NAME:-grabber}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-0.1}
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/Grabber.zip
INSTALL_DIR=$INSTALL_BASE/$INSTALL_NAME-$INSTALL_VERSION
#
# Ensure artifact is present
check_artifact(){

	if [ ! -f $ARTIFACT_TARBALL ]; then
	
		echo "Initiating installation process for Grabber version "
		sudo wget --no-check-certificate http://rgaucher.info/beta/grabber/Grabber.zip -P  $INSTALL_ARTIFACTS_DIR
		if [  $? -ne 0 ]; then
			echo "Source download failed!!!"
			exit 1
		fi
	fi
}

#Main
#
if [ "$1" = "--uninstall" ]; then
  update-alternatives --remove grabber $INSTALL_DIR/grabber.py
  rm -fr $INSTALL_DIR
  exit 0
fi
#
check_artifact 
#
## Pre-requisites
echo " Pre-requisites Installation initiated..."
apt update  &&
	apt install -y python-pip unzip dos2unix && 
	pip install BeautifulSoup
	if [ $? -eq 0 ] ; then	
		echo "Pre-requisites Installation completed successfully..."	
	else	
		echo "issue with Pre-requisites, Please check!!!"
	fi
#
# remove any previous dir
echo "grabber untaring/install started!"
	rm -fr $INSTALL_DIR && 
	cd $INSTALL_BASE && 
	unzip -o $ARTIFACT_TARBALL
#
mv $INSTALL_BASE/Grabber $INSTALL_DIR
chmod +x $INSTALL_DIR/grabber.py
(cd $INSTALL_DIR && dos2unix *.py)
#
# add to path
update-alternatives --install /usr/bin/grabber grabber $INSTALL_DIR/grabber.py 1
#
if [ $? -ne 0 ]; then	
	echo "untaring/install  failed!!!"
	exit 1 
else
	# success message
	cat <<EOF
	Grabber $INSTALL_VERSION installed successfully. Run following command to test
	grabber --help
EOF

fi

