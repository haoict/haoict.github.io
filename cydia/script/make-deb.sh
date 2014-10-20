#!/bin/bash

# Absolute path to this script, e.g. /home/user/bin/foo.sh
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in, thus /home/user/bin
SCRIPTPATH=$(dirname "$SCRIPT")

if [ "$1" != "" ]; then
    cp -r "$1" /tmp/"$1"
    cd /tmp
    chmod -R 755 "$1"

    # make deb file
    dpkg-deb --build /tmp/"$1"
    if [ $? -eq 0 ]; then
        echo "Success"
        output="$1".deb
        echo "Output file: $output"

        echo -ne "Size: "
        size=($(wc -c $output))
        echo $size

        echo -ne "MD5sum: "
        md5=($(md5sum $output))
        echo $md5

        echo -ne "SHA1: "
        sha1=($(sha1sum $output))
        echo $sha1

        echo -ne "SHA256: "
        sha256=($(sha256sum $output))
        echo $sha256

    else
        echo "[ERROR] Error code: "$?""
    fi

    # clean up
    rm -rf /tmp/"$1"
    mv /tmp/"$1".deb $SCRIPTPATH
else
    echo "[ERROR] Parameter 1 is empty, it should be a directory to build deb"
    echo "Usage example: ./make-deb.sh com.package.name"
fi
