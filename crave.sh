
repo init --depth=1 -u https://github.com/VoltageOS/manifest.git -b 16.2 --git-lfs
/opt/crave/resync.sh

git clone https://github.com/onyx-voltage/android_device_xiaomi_onyx.git -b bliss-1 device/xiaomi/onyx
git clone https://gitlab.com/onyx-vendor/proprietary_vendor_xiaomi_onyx.git -b lineage-23-1 vendor/xiaomi/onyx
git clone https://github.com/BlissRoms-Devices/android_device_xiaomi_onyx-kernel.git -b lineage-23-1 device/xiaomi/onyx-kernel
git clone https://github.com/BlissRoms-Devices/android_hardware_xiaomi.git -b onyx-1 hardware/xiaomi
git clone https://github.com/poco-f7-onyx/packages_apps_GameBar.git -b lineage-23-1 packages/apps/GameBar
git clone https://github.com/poco-f7-onyx/packages_apps_LunarisDolby.git -b 16-1 packages/apps/LunarisDolby
. build/envsetup.sh
brunch oηyx
# m precompiled_sepolicy -j$(nproc)
