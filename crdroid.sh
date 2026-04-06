#!/bin/bash

# Remove old local_manifests
rm -rf .repo/local_manifests/
rm -rf .repo/local_manifests
rm -rf device/xiaomi/mojito
rm -rf device/xiaomi/sm6150-common
rm -rf vendor/xiaomi/mojito
rm -rf vendor/xiaomi/sm6150-common
rm -rf kernel/xiaomi/mojito
rm -rf hardware/xiaomi
rm -rf packages/apps/ViPER4AndroidFX
rm -rf vendor/xiaomi/mojito-leicacamera
rm -rf frameworks/native

# Local TimeZone
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# ROM source repo
repo init -u https://github.com/crdroidandroid/android.git -b 16.0 --git-lfs --no-clone-bundle
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b crDroid https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
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

# Make clean install
make installclean
echo "============="

# Build ROM
brunch mojito
