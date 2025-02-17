#!/bin/bash

rm -rf .repo/local_manifests/

# Local TimeZone
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/India /etc/localtime

# repo init rom
repo init -u https://github.com/Project-Mist-OS/manifest -b 15 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Local manifests
git clone -b Mist-15 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync
/opt/crave/resync.sh
echo "============="
echo "Sync success"
echo "============="

# Export
export BUILD_USERNAME=Sachin
export BUILD_HOSTNAME=crave
echo "======= Export Done ======"

# Set up build environment
source build/envsetup.sh
. build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
mistify mojito eng

# Build rom
mist b
