#!/bin/bash

# Remove Xiaomi device/vendor/kernel trees for onyx
rm -rf device/xiaomi/onyx
rm -rf vendor/xiaomi/onyx
rm -rf device/xiaomi/onyx-kernel

# Remove Xiaomi hardware folder
rm -rf hardware/xiaomi

# Remove Dolby & GameBar
rm -rf packages/apps/LunarisDolby
rm -rf packages/apps/GameBar

# Remove local manifests
rm -rf .repo/local_manifests/

# Local TimeZone
sudo rm -rf /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

# ROM source repo
repo init -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b Lunaris-16 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

rm -rf device/xiaomi/miuicamera-onyx
rm -rf vendor/xiaomi/miuicamera-onyx
git clone https://github.com/Sachinpawar86/android_device_xiaomi_miuicamera-onyx.git device/xiaomi/miuicamera-onyx
git clone https://gitlab.com/sachinbarange86/miuicamera-onyx.git vendor/xiaomi/miuicamera-onyx

cd upto 8750
curl -s https://github.com/K4LCHAKRA/android_device_qcom_sepolicy_vndr/commit/feba0f0a99b7416a8aca0537aa44df2d84c602e5.patch | git am

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# Export
export WITH_GMS=true
echo "======= Export Done ======"

# Set up build environment
source build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_onyx-bp4a-user
echo "============="

# Make clean install
make installclean
echo "============="

# Build ROM
m bacon
echo "============="
