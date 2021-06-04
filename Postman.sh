#!/bin/sh -e
#
## Setup variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_NAME=${INSTALL_NAME:-postman}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-7.36.1}
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/Postman-linux-x64-$INSTALL_VERSION.tar.gz
INSTALL_DIR=$INSTALL_BASE/$INSTALL_NAME-$INSTALL_VERSION
#
# ensure artifact is present
check_artifact(){
	if [ ! -f $ARTIFACT_TARBALL ]; then
			cat <<EOF
		$(basename $ARTIFACT_TARBALL) not available in $INSTALL_ARTIFACTS_DIR.
		Download from https://www.postman.com/downloads/
EOF
			exit 1
fi
}
#
#Function for set up the service file
create_servicefile(){
	mkdir -p /usr/local/share/applications
	cat <<EOF > /usr/local/share/applications/$INSTALL_NAME.desktop
[Desktop Entry]
Version=1.0
Name=Postman
Comment=Postman API Client
Exec=/usr/bin/$INSTALL_NAME
Icon=$INSTALL_DIR/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Utility;Development;
EOF

}

###MAIN

if [ "$1" = "--uninstall" ]; then
  echo "Initiating uninstallation !!!"
  rm -fr $INSTALL_DIR /usr/local/share/applications/Postman.desktop
  exit 0
fi
#
check_artifact 
#
# remove any previous dir
echo "Postman untaring and path setting started!"
rm -fr $INSTALL_DIR
cd $INSTALL_BASE && tar zxf $ARTIFACT_TARBALL &&
mv $INSTALL_BASE/Postman $INSTALL_DIR
update-alternatives --install /usr/bin/$INSTALL_NAME $INSTALL_NAME $INSTALL_DIR/Postman 1
if [ $? -ne 0 ]; then	
			echo "Untarning or path setting failed. Please check and continue"
			exit 1 
fi

create_servicefile
if [ $? -ne 0 ]; then	
			echo "Service file creation failed"
			exit 1 
else
	# success message
	cat <<EOF
	Postman version $INSTALL_VERSION installed successfully.

	Start using postman from the application drawer.
EOF
fi


 



