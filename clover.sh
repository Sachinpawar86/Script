#!/bin/bash

rm -rf .repo/local_manifests/

# Local TimeZone
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/India /etc/localtime

# repo init rom
repo init -u https://github.com/The-Clover-Project/manifest.git -b 15-qpr1
echo "=================="
echo "Repo init success"
echo "=================="

# Local manifests
git clone -b Clover-15 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# Export
export BUILD_USERNAME=Sachin
export BUILD_HOSTNAME=crave
echo "======= Export Done ======"

# Set up build environment
source build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch clover_mojito-ap4a-userdebug
echo "============="

# Make cleaninstall
make installclean
echo "============="

# Build rom
mka clover