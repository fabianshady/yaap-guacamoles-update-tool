#!/bin/bash

if [ -f payload-dumper-go ]; then
    echo "payload-dumper-go exists"
else
    echo "payload-dumper-go not found, downloading..."
    # Set the repository information
    USERNAME="ssut"
    REPO_NAME="payload-dumper-go"

    # Determine the current operating system
    OS=$(uname -ms | awk '{print tolower($0)}' | tr ' ' '_')
    echo "Your OS is $OS"
    # Get the download URL for the latest release asset for the current OS
    ASSET_URL=$(curl -s "https://api.github.com/repos/${USERNAME}/${REPO_NAME}/releases/latest" |
        grep "browser_download_url.*${OS}.tar.gz" |
        cut -d : -f 2,3 |
        tr -d \")
    # Download and extract the asset
    curl -sL ${ASSET_URL} | tar xzf - payload-dumper-go
    chmod +x payload-dumper-go
fi

# Get the download URL for the latest release firmware
zip_url=$(curl -s https://mirror.codebucket.de/yaap/guacamoles/ | grep -Eo 'href="[^\"]*"' | sed -e 's/^href="//' -e 's/"$//' | grep 'YAAP-[0-9]*-Tripoli-guacamoles-[0-9]*\.zip' | sed -e 's/^/https:\/\/mirror.codebucket.de/' -e 's/\.sha256sum$//' | sort -V | tail -n1)
zip_file=$(basename $zip_url)
if ls | grep -q "$zip_file"; then
    echo "Your firmware is up to date"
else
    echo "The latest firmware is $zip_file, downloading..."
    curl -LO $zip_url && unzip $(ls -td YAAP* | head -n1) payload.bin
    ./payload-dumper-go payload.bin
    folder=$(ls -td extracted_* | head -n1)
    # wait for device to enter fastboot mode
    while true; do
        fastboot devices 2>&1 >/dev/null && break
        sleep 1
    done

    # device is in fastboot mode, execute your code here
    echo "Device is in fastboot mode, executing code..."
    fastboot devices
    fastboot --set-active=a
    fastboot flash boot $folder/boot.img
    fastboot flash dtbo $folder/dtbo.img
    fastboot flash odm $folder/odm.img
    fastboot flash system $folder/system.img
    fastboot flash vbmeta $folder/vbmeta.img
    fastboot flash vendor $folder/vendor.img
    fastboot --set-active=b
    fastboot flash boot $folder/boot.img
    fastboot flash dtbo $folder/dtbo.img
    fastboot flash odm $folder/odm.img
    fastboot flash system $folder/system.img
    fastboot flash vbmeta $folder/vbmeta.img
    fastboot flash vendor $folder/vendor.img
    fastboot reboot
fi
