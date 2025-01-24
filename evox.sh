#!/bin/bash

rm -rf .repo/local_manifests/

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

# Leica Cam
git clone --depth=1 https://gitlab.com/pnplusplus/android_vendor_xiaomi_mojito-leicacamera vendor/xiaomi/mojito-leicacamera

# Leica Fix
cd frameworks/native
curl -s https://github.com/ProjectInfinity-X/frameworks_native/commit/ac92117c735ac28bf9d216b09c60a5b930786011.patch | git am
curl -s https://github.com/ProjectInfinity-X/frameworks_native/commit/756ffb40bea544e5d381d8adc47e15c01be728cc.patch | git am
cd ../..

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
lunch lineage_mojito-ap4a-userdebug || lunch lineage_mojito-userdebug || lunch lineage_mojito-ap3a-userdebug || lunch lineage_mojito-ap2a-userdebug
echo "============="

# Make cleaninstall
make installclean
echo "============="

# Build rom
m evolution
