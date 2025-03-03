#!/bin/bash

rm -rf .repo/local_manifests/

# Local TimeZone
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/India /etc/localtime

# Rom source repo
repo init -u https://github.com/Evolution-X/manifest -b vic --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b Evo-15 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
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
lunch lineage_mojito-ap4a-userdebug
echo "============="

# Make cleaninstall
make installclean
echo "============="

# Build rom
m evolution
