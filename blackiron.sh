#!/bin/bash

rm -rf .repo/local_manifests/

# Local TimeZone
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/India /etc/localtime

# Rom source repo
repo init -u https://github.com/Black-Iron-Project/manifest -b v15_QPR1 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b BlackIron-15 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Signed Build
crave ssh && git clone https://github.com/Black-Iron-Project/vendor_blackiron-priv_keys-template vendor/blackiron-priv/keys && cd vendor/blackiron-priv/keys && ./generate.sh && exit

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
blkilunch mojito user
echo "============="

# Make cleaninstall
make installclean
echo "============="

# Build rom
blki b
