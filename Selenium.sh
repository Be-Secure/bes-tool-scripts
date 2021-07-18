#!/bin/sh -e

## Setup variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_NAME=${INSTALL_NAME:-selenium}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-3.141.59}
SYSTEMD_DIR=/etc/systemd/system
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/selenium-server-standalone-$INSTALL_VERSION.jar
INSTALL_DIR=$INSTALL_BASE/$INSTALL_NAME-$INSTALL_VERSION
#
# Ensure artifact is present
check_artifact(){

	if [ ! -f $ARTIFACT_TARBALL ]; then
	
		sudo mkdir -p $INSTALL_ARTIFACTS_DIR
		if [ ! -z "$2" ]; then 
			INSTALL_VERSION="$2"
		fi
		echo "Initiating installation process for Selenium version : $INSTALL_VERSION"
		sudo wget --no-check-certificate https://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-$INSTALL_VERSION.jar -P  $INSTALL_ARTIFACTS_DIR
		if [  $? -ne 0 ]; then
			echo "Source download failed!!!"
			exit 1
		fi
	fi
}

#Function for set up the service file
create_servicefile(){
cat <<EOF > $SYSTEMD_DIR/$INSTALL_NAME.service
[Unit]
Description=Selenium Standalone Server
After=network.target auditd.service

[Service]
Type=simple
ExecStart=/usr/bin/$INSTALL_NAME
Restart=on-failure
Environment="JAVA_HOME=$JAVA8_HOME"

[Install]
WantedBy=multi-user.target
EOF
}

###MAIN
#
if [ "$1" = "--uninstall" ]; then
  systemctl stop $INSTALL_NAME
  update-alternatives --remove $INSTALL_NAME $INSTALL_DIR/$INSTALL_NAME.sh
  systemctl disable $INSTALL_NAME
  rm -fr $INSTALL_DIR $SYSTEMD_DIR/$INSTALL_NAME.desktop $ARTIFACT_TARBALL
  exit 0
fi
#
check_artifact 
#
## Pre-requisites
echo " Pre-requisites Installation initiated..."
apt update &&
	apt install -y openjdk-8-jdk  &&
	JAVA8_HOME=$(update-alternatives --list java | grep java-8 | sed -e 's/\/bin\/java//')
if [ $? -eq 0 ] ; then	
	echo "Pre-requisites Installation completed successfully..."	
else	
	echo "issue with Pre-requisites, Please check!!!"
fi
#
# remove any previous dir
echo "Selenium untaring and path setting started!"
rm -fr $INSTALL_DIR &&
	mkdir -p $INSTALL_DIR && 
		cp $ARTIFACT_TARBALL $INSTALL_DIR 

cat <<EOF > $INSTALL_DIR/$INSTALL_NAME.sh
#!/bin/sh -e
java -jar $INSTALL_DIR/$(basename $ARTIFACT_TARBALL) $@
EOF

chmod +x $INSTALL_DIR/$INSTALL_NAME.sh &&

# add to path
update-alternatives --install /usr/bin/$INSTALL_NAME $INSTALL_NAME $INSTALL_DIR/$INSTALL_NAME.sh 1
	if [ $? -eq 0 ] ; then	
		echo "completed  untaring process/path setting up now proceeding with service file creation"	
	else	
		echo "issue with untaring/path set please check !!!"
	fi
	
create_servicefile
	if [ $? -ne 0 ]; then	
			echo "Package reload/enable failed"
			exit 1 
	fi
	
#Firewall opening for 4444 TCP port
echo "Initiating firewall opening and system service restart!!!"
ufw allow 4444/tcp	 && 
	systemctl daemon-reload && 
	systemctl enable $INSTALL_NAME && 
	systemctl restart $INSTALL_NAME
if [ $? -ne 0 ]; then	
	echo "Package reload/enable failed"
	exit 1 
else
	# success message
	cat <<EOF
	Selenium Standalone Server $INSTALL_VERSION installed successfully. Run following command to test

	systemctl start $INSTALL_NAME
	http://localhost:4444
EOF
fi
