#!/bin/sh -e
#
## Setup variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_NAME=${INSTALL_NAME:-beef}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-0.4.7.3}
INSTALL_USER=${INSTALL_USER:-beef}
APPS_DIR=/usr/local/share/applications
SYSTEMD_DIR=/etc/systemd/system
#
# Download from https://github.com/beefproject/beef/archive/v0.5.0.0.tar.gz and rename
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/beef-$INSTALL_VERSION.tar.gz
INSTALL_DIR=$INSTALL_BASE/$INSTALL_NAME-beef-$INSTALL_VERSION
#
#Ensure artifact is present
check_artifact(){

	if [ ! -f $ARTIFACT_TARBALL ]; then
	
		sudo mkdir -p $INSTALL_ARTIFACTS_DIR
		if [ ! -z "$2" ]; then 
			INSTALL_VERSION="$2"
		fi
		echo "Initiating installation process for BeEF version : $INSTALL_VERSION"
		sudo wget --no-check-certificate https://github.com/beefproject/beef/archive/refs/tags/beef-$INSTALL_VERSION.tar.gz -P  $INSTALL_ARTIFACTS_DIR
		if [  $? -ne 0 ]; then
			echo "Source download failed!!!"
			exit 1
		fi
	fi
}
#
#Function for set up the service file
create_servicefile(){

echo "Initiating service file creation"
cat <<EOF > $SYSTEMD_DIR/$INSTALL_NAME.service
[Unit]
Description=The Browser Exploitation Framework
After=network.target auditd.service

[Service]
Type=simple
ExecStart=$INSTALL_DIR/beef
User=$INSTALL_USER
Group=$INSTALL_USER
WorkingDirectory=$INSTALL_DIR
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
}

###MAIN

if [ "$1" = "--uninstall" ]; then
  echo "Initiating BeEF Uninstall!!!"
  systemctl stop $INSTALL_NAME
  if id $INSTALL_USER >/dev/null 2>&1 ; then
    userdel $INSTALL_USER -f
 fi
	systemctl disable $INSTALL_NAME || echo >/dev/null # ingore failure
	rm -fr $INSTALL_DIR $SYSTEMD_DIR/$INSTALL_NAME.service
	systemctl daemon-reload
	exit 0
fi
#
check_artifact 
#
## Pre-requisites
echo " Pre-requisites Installation initiated..."
(cd $INSTALL_BASE && tar zxf $ARTIFACT_TARBALL)  &&
#
if ! grep 'apt-get install -y' $INSTALL_DIR/install >/dev/null 2>&1; then
  sed -i 's/apt-get install/apt-get install -y/' $INSTALL_DIR/install
fi
#
(cd $INSTALL_DIR && echo y | ./install) &&
sed -i -E 's/passwd: .*$/passwd: "password"/' $INSTALL_DIR/config.yaml
	if [ $? -eq 0 ] ; then	
		echo "Pre-requisites Installation completed successfully..."	
	else	
		echo "issue with Pre-requisites, Please check!!!"
	fi

# Create user and update ownership
echo "Creating nexus user and initiating ownership update"
if ! id $INSTALL_USER >/dev/null 2>&1; then
  groupadd $INSTALL_USER
  useradd -g $INSTALL_USER -M $INSTALL_USER -d $INSTALL_DIR
fi
chown -R $INSTALL_USER:$INSTALL_USER $INSTALL_DIR  &&
	create_servicefile
	if [ $? -ne 0 ]; then	
			echo "Package reload/enable failed"
			exit 1 
	fi
echo "User creation and ownership  update completed successfully Proceeding with service file creation."

#Firewall opening for 3000 TCP port
echo "Initiating firewall opening and system service restart!!!"
ufw allow 3000/tcp

systemctl daemon-reload &&
systemctl enable $INSTALL_NAME
systemctl restart beef
if [ $? -ne 0 ]; then	
	echo "package reload/enable failed"
	exit 1 
else
	# success message
	cat <<EOF
		The Browser Exploitation Framework $INSTALL_VERSION installed successfully. Run following command to test
		systemctl start $INSTALL_NAME
		http://localhost:3000/ui/panel
		Use beef/password to login
EOF
fi

