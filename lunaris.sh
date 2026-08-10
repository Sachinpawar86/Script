# ============================================================
#       LUNARIS-AOSP | POCO F7 (ONYX)
#       CRAVE AUTOMATED BUILD + GOFILE + TELEGRAM
# ============================================================

#!/bin/bash

set -Ee -o pipefail

# ============================================================
# CONFIGURATION
# ============================================================

ROM_NAME="Lunaris-AOSP"
DEVICE="onyx"
BRANCH="16.2"
MANIFEST_BRANCH="Lunaris-16-oss"
BUILD_TARGET="lineage_onyx-bp4a-user"

BIONIC_PATCH="https://github.com/sp-projectss/bionic/commit/8c732ec79000384e52de0efa656f50084f8403d.patch"

UPLOAD_SCRIPT="https://raw.githubusercontent.com/K4LCHAKRA/telegram_notification_gofile_upload/refs/heads/main/gofile_tg_upload.sh"

JSON_FILE="onyx.json"

export WITH_GMS=true

# ============================================================
# COLORS
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# ============================================================
# LOGGING FUNCTIONS
# ============================================================

log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${RESET} $1"
}

success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓ $1${RESET}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠ $1${RESET}"
}

error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ✗ $1${RESET}"
}

section() {
    echo
    echo -e "${CYAN}============================================================${RESET}"
    echo -e "${CYAN} $1${RESET}"
    echo -e "${CYAN}============================================================${RESET}"
}

# ============================================================
# ERROR HANDLER
# ============================================================

trap 'error "Build failed at line $LINENO: $BASH_COMMAND"' ERR

# ============================================================
# START
# ============================================================

START_TOTAL=$(date +%s)

clear

section "LUNARIS-AOSP BUILD"

echo
log "ROM       : $ROM_NAME"
log "DEVICE    : $DEVICE"
log "BRANCH    : $BRANCH"
log "MANIFEST  : $MANIFEST_BRANCH"
log "TARGET    : $BUILD_TARGET"
log "GMS       : $WITH_GMS"
echo

# ============================================================
# CLEAN OLD TREES
# ============================================================

section "CLEANING OLD XIAOMI TREES"

TREES=(
    "device/xiaomi/onyx"
    "vendor/xiaomi/onyx"
    "kernel/xiaomi/sm8735"
    "kernel/xiaomi/sm8735-modules"
    "kernel/xiaomi/sm8735-devicetrees"
    "hardware/xiaomi"
    "packages/apps/LunarisDolby"
    "packages/apps/GameBar"
    "packages/apps/NotGameTurbo"
    "device/xiaomi/onyx-miuicamera"
    "vendor/xiaomi/onyx-miuicamera"
)

for tree in "${TREES[@]}"; do
    if [ -e "$tree" ]; then
        log "Removing: $tree"
        rm -rf "$tree"
    else
        log "Skipping: $tree"
    fi
done

success "Old Xiaomi trees cleaned"

# ============================================================
# LOCAL MANIFESTS
# ============================================================

section "PREPARING LOCAL MANIFESTS"

if [ -d ".repo/local_manifests" ]; then
    rm -rf .repo/local_manifests
fi

git clone \
    -b "$MANIFEST_BRANCH" \
    https://github.com/Sachinpawar86/local_manifests \
    .repo/local_manifests

success "Local manifests cloned"

# ============================================================
# REPO INIT
# ============================================================

section "INITIALIZING ROM SOURCE"

repo init \
    --depth=1 \
    -u https://github.com/Lunaris-AOSP/android \
    -b "$BRANCH" \
    --git-lfs

success "Repo initialization completed"

# ============================================================
# SOURCE SYNC
# ============================================================

section "SYNCING SOURCE"

SYNC_START=$(date +%s)

/opt/crave/resync.sh

SYNC_END=$(date +%s)
SYNC_TIME=$((SYNC_END - SYNC_START))

success "Source sync completed"
log "Sync time: $((SYNC_TIME / 60))m $((SYNC_TIME % 60))s"

# ============================================================
# BIONIC PATCH
# ============================================================

section "APPLYING BIONIC PATCH"

cd bionic

log "Checking Bionic patch compatibility..."

curl -L \
    --fail \
    --silent \
    --show-error \
    "$BIONIC_PATCH" \
    | git apply --check

success "Bionic patch check passed"

log "Applying Bionic patch..."

curl -L \
    --fail \
    --silent \
    --show-error \
    "$BIONIC_PATCH" \
    | git am

success "Bionic patch applied successfully"

log "Bionic HEAD:"
git log -1 --oneline

cd ..

success "Returned to ROM source root"

# ============================================================
# BUILD ENVIRONMENT
# ============================================================

section "BUILD ENVIRONMENT"

source build/envsetup.sh

success "Build environment initialized"

# ============================================================
# LUNCH
# ============================================================

section "SELECTING BUILD TARGET"

lunch "$BUILD_TARGET"

success "Lunch completed"

# ============================================================
# INSTALL CLEAN
# ============================================================

section "RUNNING INSTALL CLEAN"

make installclean

success "Install clean completed"

# ============================================================
# BUILD ROM
# ============================================================

section "BUILDING ROM"

BUILD_START=$(date +%s)

m bacon

BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))

success "ROM build completed successfully"

log "Build time: $((BUILD_TIME / 3600))h $(((BUILD_TIME % 3600) / 60))m $((BUILD_TIME % 60))s"

# ============================================================
# LOCATE ROM
# ============================================================

section "LOCATING ROM OUTPUT"

OUT_DIR="out/target/product/$DEVICE"

if [ ! -d "$OUT_DIR" ]; then
    error "Output directory not found: $OUT_DIR"
    exit 1
fi

ROM_ZIP=$(find "$OUT_DIR" \
    -maxdepth 1 \
    -type f \
    -name 'Lunaris-AOSP-onyx-*.zip' \
    -printf '%T@ %p\n' \
    | sort -nr \
    | head -n1 \
    | cut -d' ' -f2-)

if [ -z "$ROM_ZIP" ]; then
    error "No Lunaris-AOSP onyx ROM ZIP found!"
    exit 1
fi

ROM_FILE=$(basename "$ROM_ZIP")

success "ROM detected: $ROM_FILE"

# ============================================================
# CHECK JSON
# ============================================================

section "CHECKING OTA JSON"

JSON_PATH="$OUT_DIR/$JSON_FILE"

if [ ! -f "$JSON_PATH" ]; then
    error "$JSON_FILE not found!"
    exit 1
fi

success "$JSON_FILE found"

# ============================================================
# SHA256
# ============================================================

section "GENERATING SHA256"

cd "$OUT_DIR"

SHA_FILE="${ROM_FILE}.sha256sum"

sha256sum "$ROM_FILE" > "$SHA_FILE"

success "SHA256 generated"

cat "$SHA_FILE"

cd ../../../../

# ============================================================
# GOFILE + TELEGRAM UPLOAD
# ============================================================

section "GOFILE + TELEGRAM UPLOAD"

# ------------------------------------------------------------
# Telegram credentials
#
# Put your NEW regenerated bot token below.
# Chat ID can remain as it is.
# ------------------------------------------------------------

TG_BOT_TOKEN="8804773566:AAFJ2_ORCBLh-hES_2T5AvpQIdZ4QGoutp4"
TG_CHAT_ID="-1003799985450"

if [ "$TG_BOT_TOKEN" = "PASTE_NEW_BOT_TOKEN_HERE" ]; then
    error "Telegram bot token is not configured!"
    exit 1
fi

UPLOAD_TMP="/tmp/gofile_tg_upload.sh"

log "Downloading upload script..."

curl -L \
    --fail \
    --silent \
    --show-error \
    "$UPLOAD_SCRIPT" \
    -o "$UPLOAD_TMP"

chmod +x "$UPLOAD_TMP"

success "Upload script ready"

log "ROM : $ROM_FILE"
log "JSON: $JSON_FILE"

UPLOAD_START=$(date +%s)

printf '%s\n%s\n%s\n%s\n' \
    "$ROM_FILE" \
    "$JSON_FILE" \
    "$TG_BOT_TOKEN" \
    "$TG_CHAT_ID" \
    | bash "$UPLOAD_TMP"

UPLOAD_END=$(date +%s)
UPLOAD_TIME=$((UPLOAD_END - UPLOAD_START))

success "GoFile + Telegram upload completed"

log "Upload time: $((UPLOAD_TIME / 60))m $((UPLOAD_TIME % 60))s"

rm -f "$UPLOAD_TMP"

# ============================================================
# FINAL SUMMARY
# ============================================================

TOTAL_END=$(date +%s)
TOTAL_TIME=$((TOTAL_END - START_TOTAL))

section "BUILD + UPLOAD COMPLETE"

echo
echo -e "${GREEN}ROM:${RESET}  $ROM_FILE"
echo -e "${GREEN}JSON:${RESET} $JSON_FILE"
echo -e "${GREEN}SHA256:${RESET} $SHA_FILE"
echo
echo -e "${GREEN}Build time:${RESET} $((BUILD_TIME / 3600))h $(((BUILD_TIME % 3600) / 60))m $((BUILD_TIME % 60))s"
echo -e "${GREEN}Upload time:${RESET} $((UPLOAD_TIME / 60))m $((UPLOAD_TIME % 60))s"
echo -e "${GREEN}Total time:${RESET} $((TOTAL_TIME / 3600))h $(((TOTAL_TIME % 3600) / 60))m $((TOTAL_TIME % 60))s"
echo
echo -e "${GREEN}============================================================${RESET}"
echo -e "${GREEN}              LUNARIS-AOSP SUCCESS                         ${RESET}"
echo -e "${GREEN}============================================================${RESET}"
echo
