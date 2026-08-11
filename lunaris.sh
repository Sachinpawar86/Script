```bash
#!/bin/bash

ROM_NAME="Lunaris-AOSP"
DEVICE="onyx"
BRANCH="16.2"
MANIFEST_BRANCH="Lunaris-16-oss"
BUILD_TARGET="lineage_onyx-bp4a-user"

BIONIC_PATCH="https://github.com/sp-projectss/bionic/commit/8c732ec79000384e52de0efa656f50084f8403d.patch"
UPLOAD_SCRIPT="https://raw.githubusercontent.com/K4LCHAKRA/telegram_notification_gofile_upload/refs/heads/main/gofile_tg_upload.sh"

JSON_FILE="onyx.json"

TG_BOT_TOKEN="8804773566:AAFJ2_ORCBLh-hES_2T5AvpQIdZ4QGoutp4"
TG_CHAT_ID="-1003799985450"

export WITH_GMS=true

set -e

# ------------------------------------------------------------
# Clean old trees
# ------------------------------------------------------------

rm -rf \
device/xiaomi/onyx \
vendor/xiaomi/onyx \
kernel/xiaomi/sm8735 \
kernel/xiaomi/sm8735-modules \
kernel/xiaomi/sm8735-devicetrees \
hardware/xiaomi \
packages/apps/LunarisDolby \
packages/apps/GameBar \
packages/apps/NotGameTurbo \
device/xiaomi/onyx-miuicamera \
vendor/xiaomi/onyx-miuicamera

# ------------------------------------------------------------
# Repo init
# ------------------------------------------------------------

repo init \
    --depth=1 \
    -u https://github.com/Lunaris-AOSP/android \
    -b "$BRANCH" \
    --git-lfs

# ------------------------------------------------------------
# Local manifests
# ------------------------------------------------------------

rm -rf .repo/local_manifests

git clone \
    -b "$MANIFEST_BRANCH" \
    https://github.com/Sachinpawar86/local_manifests \
    .repo/local_manifests

# ------------------------------------------------------------
# Sync source
# ------------------------------------------------------------

/opt/crave/resync.sh

# ------------------------------------------------------------
# Bionic patch
# ------------------------------------------------------------

cd bionic

curl -L --fail --silent --show-error "$BIONIC_PATCH" | git apply --check
curl -L --fail --silent --show-error "$BIONIC_PATCH" | git am

cd ..

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------

source build/envsetup.sh

lunch "$BUILD_TARGET"

make installclean

m bacon

# ------------------------------------------------------------
# Locate ROM
# ------------------------------------------------------------

OUT_DIR="out/target/product/$DEVICE"

ROM_ZIP=$(find "$OUT_DIR" \
    -maxdepth 1 \
    -type f \
    -name "Lunaris-AOSP-onyx-*.zip" \
    -printf "%T@ %p\n" |
    sort -nr |
    head -n1 |
    cut -d' ' -f2-)

if [ -z "$ROM_ZIP" ]; then
    echo "ERROR: ROM ZIP not found!"
    exit 1
fi

ROM_FILE=$(basename "$ROM_ZIP")

# ------------------------------------------------------------
# OTA JSON
# ------------------------------------------------------------

JSON_PATH="$OUT_DIR/$JSON_FILE"

if [ ! -f "$JSON_PATH" ]; then
    echo "ERROR: $JSON_FILE not found!"
    exit 1
fi

# ------------------------------------------------------------
# SHA256
# ------------------------------------------------------------

cd "$OUT_DIR"

SHA_FILE="${ROM_FILE}.sha256sum"

sha256sum "$ROM_FILE" > "$SHA_FILE"

cd ../../../../

# ------------------------------------------------------------
# GoFile + Telegram
# ------------------------------------------------------------

UPLOAD_TMP="/tmp/gofile_tg_upload.sh"

curl -L --fail --silent --show-error \
    "$UPLOAD_SCRIPT" \
    -o "$UPLOAD_TMP"

chmod +x "$UPLOAD_TMP"

printf '%s\n%s\n%s\n%s\n' \
    "$ROM_FILE" \
    "$JSON_FILE" \
    "$TG_BOT_TOKEN" \
    "$TG_CHAT_ID" |
    bash "$UPLOAD_TMP"

rm -f "$UPLOAD_TMP"

echo
echo "=========================================="
echo " LUNARIS-AOSP BUILD SUCCESSFUL"
echo "=========================================="
echo "ROM  : $ROM_FILE"
echo "JSON : $JSON_FILE"
echo "SHA  : $SHA_FILE"
echo "=========================================="
```
