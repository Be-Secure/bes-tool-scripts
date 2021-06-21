#!/bin/bash


pip --version
if [ $? -eq 0 ]; then
	echo "application available"

else
	echo "application not"
fi
