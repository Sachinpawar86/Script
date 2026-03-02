#!/bin/bash
set -e

# ==============================
# PixelDrain API KEY
# ==============================
PIXELDRAIN_KEY="3a3a801f-99c6-4136-8be1-0dbf0a37ded9"

echo "=================================="
echo "Cleaning old trees & manifests"
echo "=================================="

rm -rf device/xiaomi/mojito
rm -rf device/xiaomi/sm6150-common
rm -rf vendor/xiaomi/mojito
rm -rf vendor/xiaomi/sm6150-common
rm -rf kernel/xiaomi/mojito
rm -rf hardware/xiaomi
rm -rf packages/apps/ViPER4AndroidFX
rm -rf .repo/local_manifests

echo "=================================="
echo "Setting timezone"
echo "=================================="

sudo rm -rf /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

echo "=================================="
echo "Initializing Evolution-X Source"
echo "=================================="

repo init -u https://github.com/Evolution-X/manifest -b bq2 --git-lfs
echo "Repo init success"

echo "=================================="
echo "Cloning local_manifests"
echo "=================================="

git clone -b Evo-16-QPR2 https://github.com/Sachinpawar86/local_manifests .repo/local_manifests

echo "=================================="
echo "Syncing source"
echo "=================================="

/opt/crave/resync.sh


# ==============================
# VANILLA BUILD
# ==============================
echo "=================================="
echo "Starting VANILLA build"
echo "=================================="

source build/envsetup.sh
export WITH_GMS=false
lunch lineage_mojito-bp4a-userdebug

make installclean
m evolution

# Find Vanilla ZIP
cd out/target/product/mojito

VANILLA_ZIP=$(find . -maxdepth 1 -type f -name "*mojito*.zip" -size +500M | head -n 1)

if [[ -z "$VANILLA_ZIP" ]]; then
    echo "❌ ERROR: ROM ZIP not found for vanilla build!"
    exit 1
fi

# Copy to safe folder
mkdir -p ../vanilla
cp "$VANILLA_ZIP" ../vanilla/

cd ../../../../


# ==============================
# GAPPS BUILD
# ==============================
echo "=================================="
echo "Starting GAPPS build"
echo "=================================="

source build/envsetup.sh
export TARGET_USES_PICO_GAPPS=true
lunch lineage_mojito-bp4a-userdebug

make installclean
m evolution

# Find GApps ZIP  
cd out/target/product/mojito

GAPPS_ZIP=$(find . -maxdepth 1 -type f -name "*mojito*.zip" -size +500M | head -n 1)

if [[ -z "$GAPPS_ZIP" ]]; then
    echo "❌ ERROR: ROM ZIP not found for gapps build!"
    exit 1
fi

mkdir -p ../gapps
cp "$GAPPS_ZIP" ../gapps/

cd ../../../../


# ==============================
# UPLOAD VANILLA TO PIXELDRAIN
# ==============================
echo "=================================="
echo "Uploading VANILLA build to PixelDrain"
echo "=================================="

cd out/target/product/vanilla
VANILLA_ROM=$(ls *.zip | head -n 1)

curl -T "$VANILLA_ROM" \
    -u :$PIXELDRAIN_KEY \
    https://pixeldrain.com/api/file/

cd ../../..


# ==============================
# UPLOAD GAPPS TO PIXELDRAIN
# ==============================
echo "=================================="
echo "Uploading GAPPS build to PixelDrain"
echo "=================================="

cd out/target/product/gapps
GAPPS_ROM=$(ls *.zip | head -n 1)

curl -T "$GAPPS_ROM" \
    -u :$PIXELDRAIN_KEY \
    https://pixeldrain.com/api/file/

cd ../../..


echo "=================================="
echo "🎉 BUILD + UPLOAD COMPLETED SUCCESSFULLY!"
echo "=================================="