#!/bin/bash

# Remove Xiaomi device/vendor/kernel trees for onyx
rm -rf device/xiaomi/onyx
rm -rf vendor/xiaomi/onyx
rm -rf kernel/xiaomi/onyx
rm -rf kernel/xiaomi/onyx-modules
rm -rf kernel/xiaomi/onyx-devicetrees

# Remove Xiaomi hardware folder
rm -rf hardware/xiaomi

# Remove Dolby & GameBar & Camera
rm -rf packages/apps/LunarisDolby
rm -rf packages/apps/GameBar
rm -rf packages/apps/NotGameTurbo
rm -rf device/xiaomi/onyx-miuicamera
rm -rf vendor/xiaomi/onyx-miuicamera

# Remove local manifests
rm -rf .repo/local_manifests/

# ROM source repo
repo init --depth=1 -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b Lunaris-16-OSS https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

# Bionic
cd bionic
curl -L https://github.com/Sachinpawar86/bionic/commit/af180de003807047d69b7c10a83ff05891b71ed3.patch | git am

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
