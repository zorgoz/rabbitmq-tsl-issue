#!/bin/sh

if [ "$(ls -A)" ]; then
    echo "Directory is not empty, exiting."
    exit 0
fi

/usr/local/bin/create-server-certs.sh 
/usr/local/bin/create-user-certs.sh 
chmod go+r * 
ls -al

