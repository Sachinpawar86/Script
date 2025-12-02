#!/bin/bash

# Remove Xiaomi device/vendor/kernel trees for onyx
rm -rf device/xiaomi/onyx
rm -rf vendor/xiaomi/onyx
rm -rf device/xiaomi/onyx-kernel

# Remove Xiaomi hardware folder
rm -rf hardware/xiaomi

# Remove Xiaomi Dolby app
rm -rf packages/apps/XiaomiDolby

# Remove local manifests
rm -rf .repo/local_manifests/

# Local TimeZone
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# ROM source repo
repo init -u https://github.com/Lunaris-AOSP/android -b 16 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b Lunaris-16 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Camera
git clone https://gitea.com/goziko32/vendor_gcam.git vendor/mgc

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# Export
export BUILD_USERNAME=Sachin
export BUILD_HOSTNAME=crave
TARGET_DISABLE_EPPE=true
echo "======= Export Done ======"

# Set up build environment
source build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_onyx-bp2a-user
echo "============="

# Make clean install
make installclean
echo "============="

# Build ROM
m lunaris
echo "============="
