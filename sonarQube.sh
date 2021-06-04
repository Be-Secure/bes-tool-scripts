#!/bin/sh -e
#
## Setup variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_NAME=${INSTALL_NAME:-sonarqube}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-8.6.0.39681}
INSTALL_USER=${INSTALL_USER:-sonar}
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/sonarqube-$INSTALL_VERSION.zip
INSTALL_DIR=$INSTALL_BASE/$INSTALL_NAME-$INSTALL_VERSION

#Ensure artifact is present
check_artifact(){

	if [ ! -f $ARTIFACT_TARBALL ]; then
	
		sudo mkdir -p $INSTALL_ARTIFACTS_DIR
		if [ ! -z "$2" ]; then 
			INSTALL_VERSION="$2"
		fi
		echo "Initiating installation process for Sonarqube version : $INSTALL_VERSION"
		sudo wget --no-check-certificate https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$INSTALL_VERSION.zip -P  $INSTALL_ARTIFACTS_DIR
		if [  $? -ne 0 ]; then
			echo "Source download failed!!!"
			exit 1
		fi
	fi
}
#Function for set up the service file
create_servicefile(){
cat <<EOF > /etc/systemd/system/$INSTALL_NAME.service
[Unit]
Description=Sonarqube Static Code Analyser
After=network.target auditd.service

[Service]
Type=simple
ExecStart=$INSTALL_DIR/bin/linux-x86-64/sonar.sh console
User=$INSTALL_USER
Group=$INSTALL_USER
Environment="JAVA_HOME=$JAVA11_HOME"
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

}

###MAIN

if [ "$1" = "--uninstall" ]; then
  systemctl stop $INSTALL_NAME
  systemctl disable $INSTALL_NAME
  if id $INSTALL_USER ; then
    userdel $INSTALL_USER -f
  fi
  rm -fr $INSTALL_DIR /etc/systemd/system/$INSTALL_NAME.service
  systemctl daemon-reload
  exit 0
fi

check_artifact 

## Pre-requisites 
echo " Pre-requisites Installation initiated..."
apt update  &&
	apt install -y openjdk-11-jdk unzip
	
JAVA11_HOME=$(update-alternatives --list java | grep java-11 | sed -e 's/\/bin\/java//')
        if [  $? -ne 0 ]; then
                        echo "Failure in setting up Pre-requisites !!!"
                        exit 1

        fi
		echo "Pre-requisites Installation  and path setting completed successfully..."
#
echo "Vega untaring and path setting started!"
# remove any previous dir
rm -fr $INSTALL_DIR &&
	cd $INSTALL_BASE && 
	unzip $ARTIFACT_TARBALL
echo "completed  untaring process/path setting up "
#
# Create nexus user and update ownership
echo "Creating Sonarqube user and initiating ownership update"
#
if ! id $INSTALL_USER >/dev/null 2>&1; then
  groupadd $INSTALL_USER
  useradd -g $INSTALL_USER -M $INSTALL_USER -d $INSTALL_DIR
fi
chown -R $INSTALL_USER:$INSTALL_USER $INSTALL_DIR
echo "User creation and ownership  update completed successfully Proceeding with service file creation."

create_servicefile
	if [ $? -ne 0 ]; then

		echo "service file creation failed"
		exit 1
	else	
	  	echo "service file creation completed successfully..."	
	fi

echo "Opening port 9000"
ufw allow 9000/tcp
if [ $? -ne 0 ]; then
        echo "firewall opening failed"
        exit 1
fi

systemctl daemon-reload
systemctl enable $INSTALL_NAME
systemctl restart $INSTALL_NAME
if [ $? -ne 0 ]; then	
	echo "package reload/enable failed"
	exit 1 
else
	# success message
	cat <<EOF
	Sonarqube OSS $INSTALL_VERSION installed successfully. Run following command to test
	systemctl start $INSTALL_NAME

	http://localhost:9000
	Use admin/admin to login
EOF
fi


