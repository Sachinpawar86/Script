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
repo init -u https://github.com/alphadroid-project/manifest -b alpha-16.1 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b Alpha-16 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Custom Soong
rm -rf build/soong
git clone https://github.com/Sachinpawar86/build_soong.git build/soong

# Custom Bionic
rm -rf bionic
git clone https://github.com/Sachinpawar86/bionic.git -b alpha-16.1 bionic

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
lunch alpha_onyx-userdebug
echo "============="

# Make clean install
make installclean
echo "============="

# Build ROM
make bacon
echo "============="
