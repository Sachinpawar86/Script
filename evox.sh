#!/bin/bash

# Remove old local_manifests
rm -rf .repo/local_manifests/

# ROM source repo
repo init -u https://github.com/Evolution-X/manifest -b bq2 --git-lfs
echo "=================="
echo "Repo init success"
echo "=================="

# Clone local_manifests repository
git clone https://github.com/Sachinpawar86/local_manifests.git -b Evo-16-QPR2 .repo/local_manifests
echo "============================"
echo "Local manifest clone success"
echo "============================"

# Sync the repositories
/opt/crave/resync.sh
echo "============================"

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
m evolution
