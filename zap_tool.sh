#!/bin/sh -e
#
# Variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_NAME=${INSTALL_NAME:-zap}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-2.10.0}
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/ZAP_${INSTALL_VERSION}_Linux.tar.gz
INSTALL_DIR=$INSTALL_BASE/$INSTALL_NAME-$INSTALL_VERSION
#
#Ensure artifact is present
check_artifact(){
	if [ ! -f $ARTIFACT_TARBALL ]; then
	
		sudo mkdir -p $INSTALL_ARTIFACTS_DIR
		if [ ! -z "$2" ]; then 
			INSTALL_VERSION="$2"
		fi
		echo "Initiating installation process for ZAP version : $INSTALL_VERSION"
		sudo wget --no-check-certificate https://github.com/zaproxy/zaproxy/releases/download/v$INSTALL_VERSION/ZAP_${INSTALL_VERSION}_Linux.tar.gz -P  $INSTALL_ARTIFACTS_DIR
		if [  $? -ne 0 ]; then
			echo "Source download failed!!!"
			exit 1
		fi
	fi
}

#Function for set up the service file
create_servicefile(){
mkdir -p /usr/local/share/applications
cat <<EOF > /usr/local/share/applications/$INSTALL_NAME.desktop
[Desktop Entry]
Version=1.0
Name=Zed Attack Proxy
Comment=Zed Attack Proxy for Web Applications
Exec=env JAVA_HOME=$JAVA8_HOME $INSTALL_DIR/zap.sh
Icon=$INSTALL_DIR/zap.ico
Terminal=false
Type=Application
Categories=Utility;Development;
EOF
}

##Main ###

if [ "$1" = "--uninstall" ]; then
  update-alternatives --remove grabber $INSTALL_DIR/grabber.py
  rm -fr $INSTALL_DIR /usr/local/share/applications/$INSTALL_NAME.desktop
  exit 0
fi

check_artifact 

## Pre-requisites
echo " Pre-requisites Installation initiated..."
apt update && 
	apt install -y openjdk-8-jdk &&
	JAVA8_HOME=$(update-alternatives --list java | grep java-8 | sed -e 's/\/bin\/java//')
	if [ $? -eq 0 ] ; then	
		echo "Pre-requisites Installation completed successfully..."	
	else	
		echo "issue with Pre-requisites, Please check!!!"
	fi

# Remove any previous dir
echo "ZAP untaring and path setting started!"
rm -fr $INSTALL_DIR &&
	(cd $INSTALL_BASE && tar zxf $ARTIFACT_TARBALL) &&
	mv $INSTALL_BASE/ZAP_$INSTALL_VERSION $INSTALL_DIR &&
# Add to path
update-alternatives --install /usr/bin/$INSTALL_NAME $INSTALL_NAME $INSTALL_DIR/zap.sh 1
	if [ $? -eq 0 ] ; then	
		echo "completed  untaring process/path setting up now proceeding with service file creation"	
	else	
		echo "issue with untaring/path set please check !!!"
	fi

create_servicefile
if [ $? -ne 0 ]; then	
	echo "Service file creation failed."
	exit 1 
else
	# Success message

	cat <<EOF
	Zed Attack Proxy $INSTALL_VERSION installed successfully. Run following command to test
	$INSTALL_NAME -help
	Start using ZAP from the application drawer.
EOF
fi

