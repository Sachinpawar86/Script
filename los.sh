#!/bin/bash

rm -rf .repo/local_manifests/

# Local TimeZone
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/India /etc/localtime

# Rom source repo
 repo init -u https://github.com/Los-Ext/manifest.git -b 15 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b LOS-15 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
 repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags --optimized-fetch --prune
echo "============================"

# Set up build environment
source build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
 lunch lineage_mojito-user
echo "============="

# Make cleaninstall
make installclean
echo "============="

# Build rom
make bacon
