#!/bin/sh -e
#
## Setup variables
INSTALL_ARTIFACTS_DIR=${INSTALL_ARTIFACTS_DIR:-/vagrant/artifacts}
INSTALL_NAME=${INSTALL_NAME:-vega}
INSTALL_BASE=${INSTALL_BASE:-/opt}
INSTALL_VERSION=${INSTALL_VERSION:-1.0}
APPS_DIR=/usr/local/share/applications
ARTIFACT_TARBALL=$INSTALL_ARTIFACTS_DIR/VegaBuild-linux.gtk.x86_64.zip
INSTALL_DIR=$INSTALL_BASE/$INSTALL_NAME-$INSTALL_VERSION
#
#Ensure artifact is present
check_artifact(){
	if [ ! -f $ARTIFACT_TARBALL ]; then
	
		sudo mkdir -p $INSTALL_ARTIFACTS_DIR
		echo "Initiating installation process for Vega version "
		sudo wget --no-check-certificate https://support.subgraph.com/downloads/VegaBuild-linux.gtk.x86_64.zip -P  $INSTALL_ARTIFACTS_DIR
		if [  $? -ne 0 ]; then
			echo "Source download failed!!!"
			exit 1
		fi
	fi
}

#Function for set up the service file
create_servicefile(){
mkdir -p $APPS_DIR
cat <<EOF > $APPS_DIR/$INSTALL_NAME.desktop
[Desktop Entry]
Version=1.0
Name=Vega Vulnerability Scanner
Comment=Vega Vulnerability Scanner
Exec=/usr/bin/$INSTALL_NAME
Icon=$INSTALL_DIR/icon.xpm
Terminal=false
Type=Application
Categories=Utility;Development;
EOF
}

###MAIN

if [ "$1" = "--uninstall" ]; then
  update-alternatives --remove $INSTALL_NAME $INSTALL_DIR/vega.sh
  rm -fr $INSTALL_DIR $APPS_DIR/$INSTALL_NAME.desktop
  exit 0
fi
#
check_artifact
#
## Pre-requisites 
echo " Pre-requisites Installation initiated..."
apt update &&
	apt install -y openjdk-8-jdk unzip &&
        apt install -y libwebkitgtk-1.0-0 libcanberra-gtk-module libcanberra-gtk3-module
        if [  $? -ne 0 ]; then
                        echo "Failure in additional package install/update!!!"
                        exit 1

        fi
JAVA8_HOME=$(update-alternatives --list java | grep java-8 | sed -e 's/\/bin\/java//')	
echo "Pre-requisites Installation  and path setting completed successfully..."
#
# remove any previous dir
echo "Vega untaring and path setting started!"
rm -fr $INSTALL_DIR
(cd $INSTALL_BASE && unzip $ARTIFACT_TARBALL)
mv $INSTALL_BASE/vega $INSTALL_DIR
#
cat <<EOF > $INSTALL_DIR/$INSTALL_NAME.sh
#!/bin/sh -e
export JAVA_HOME=$JAVA8_HOME
$INSTALL_DIR/Vega -data \$HOME/workspace $@

EOF
#
# Add to path
update-alternatives --install /usr/bin/$INSTALL_NAME $INSTALL_NAME $INSTALL_DIR/$INSTALL_NAME.sh 1
	if [ $? -eq 0 ] ; then	
		echo "completed  untaring process/path setting up now proceeding with service file creation"	
	else	
		echo "issue with untaring/path set please check !!!"
	fi
#
create_servicefile
if [ $? -ne 0 ]; then	
	echo "service file creation failed"
	exit 1 
else
	# success message
	cat <<EOF
	Vega Vulnerability Scanner $INSTALL_VERSION installed successfully.

	Start using Vega Vulnerability Scanner from the application drawer.
EOF
fi

