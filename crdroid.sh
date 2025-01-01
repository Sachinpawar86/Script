#!/bin/bash

rm -rf .repo/local_manifests/

# repo init rom
repo init -u https://github.com/crdroidandroid/android.git -b 15.0 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Local manifests
git clone -b Crdroid-15 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync
/opt/crave/resync.sh
echo "============="
echo "Sync success"
echo "============="

# keys
# mkdir vendor/lineage-priv
# cp build-keys/* vendor/lineage-priv
# echo "============="
# echo "Keys copied"
# echo "============="

# Custom Source
wget https://raw.githubusercontent.com/custom-crdroid/custom_cr_setup/refs/heads/15.0/vendorsetup.sh && bash vendorsetup.sh

# Export
export BUILD_USERNAME=Sachin
export BUILD_HOSTNAME=crave
export TZ="Asia/India"
echo "======= Export Done ======"

# Set up build environment
source build/envsetup.sh
echo "====== Envsetup Done ======="

# Lunch
lunch lineage_mojito-user || lunch lineage_mojito-ap2a-user || lunch lineage_mojito-ap3a-user
#echo "============="

# Run to prepare our devices list
. build/envsetup.sh
# ... now run
brunch mojito
