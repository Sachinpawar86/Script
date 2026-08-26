#!/bin/bash

# Remove old local_manifests
rm -rf .repo/local_manifests/
rm -rf .repo/local_manifests
rm -rf \
device/xiaomi/mojito \
device/xiaomi/sm6150-common \
vendor/xiaomi/mojito \
vendor/xiaomi/sm6150-common \
vendor/xiaomi/mojito-leicacamera \
kernel/xiaomi/mojito \
hardware/xiaomi \
packages/apps/ViPER4AndroidFX

# ROM source repo
repo init --depth=1 -u https://github.com/Lunaris-AOSP/android -b 16.2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone -b Lunaris-mojito https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

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
lunch lineage_mojito-bp4a-user
echo "============="

# Make clean install
make installclean
echo "============="

# Build ROM
m bacon
