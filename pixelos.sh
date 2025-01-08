#!/bin/bash

rm -rf .repo/local_manifests/
rm -rf vendor/xiaomi/mojito-leicacamera
rm -rf android/vendor/xiaomi/mojito-leicacamera

# Rom source repo
repo init -u https://github.com/PixelOS-AOSP/manifest.git -b fifteen-qpr1 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b PixelOS-15 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
git clone https://gitlab.com/ItzDFPlayer/vendor_xiaomi_miuicamera -b leica-5.0 vendor/xiaomi/miuicamera
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
lunch aosp_mojito-ap4a-user
echo "============="

# Make cleaninstall
make installclean
echo "============="

# Build rom
mka bacon
