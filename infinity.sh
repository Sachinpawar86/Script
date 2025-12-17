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
repo init --no-repo-verify --git-lfs -u https://github.com/ProjectInfinity-X/manifest -b 16 -g default,-mips,-darwin,-notdefault
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b Infinity-16 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
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
lunch infinity_onyx-user
echo "============="

# Make clean install
make installclean
echo "============="

# Build ROM
m bacon
echo "============="
