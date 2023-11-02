#!/bin/bash

# Prepare a handful of needed variables
BOOTLOADER_DIR="$(dirname "$(readlink -f "$BASH_SOURCE")")"
BOOT_UNPACKER_DIR="$BOOTLOADER_DIR/Android_boot_image_editor"
BOOT_UNPACKER_KEYS_DIR="$BOOT_UNPACKER_DIR/aosp/avb/data"
BOOT_UNPACKER_PRIVATE_KEY="$BOOT_UNPACKER_KEYS_DIR/testkey_rsa4096.pem"
BOOT_UNPACKER_PUBLIC_KEY="$BOOT_UNPACKER_KEYS_DIR/testkey_rsa4096_pub.key"
BOOT_UNPACKER_OUTPUT_DIR="$BOOT_UNPACKER_DIR/build/unzip_boot"
BASE_DIR="$BOOTLOADER_DIR/base"
BASE_KEYS_DIR="$BASE_DIR/keys"
BASE_VBMETA="$BASE_DIR/vbmeta.img"
BASE_BOOT="$BASE_DIR/boot.img"
PATCHES_DIR="$BOOTLOADER_DIR/patches"
SDBOOT_DIR="$BOOTLOADER_DIR/sdboot"
SDBOOT_VBMETA="$SDBOOT_DIR/vbmeta.img"
SDBOOT_BOOT="$SDBOOT_DIR/boot.img"
AVBTOOL="python3 $BOOT_UNPACKER_DIR/aosp/avb/avbtool.v1.2.py"
DHTBSIGN="python2 $BOOTLOADER_DIR/dhtbsign.py"

# Move to the bootloader home directory
cd "$BOOTLOADER_HOME"

# Initialize the submodules
git submodule status | grep "^-" >/dev/null 2>&1
SUBMODULES_READY=$?
if [ $SUBMODULES_READY -eq 0 ]
then
	git submodule update --init --recursive
	SUBMODULES_READY=$?
	if [ $SUBMODULES_READY -eq 0 ]
	then
		SUBMODULES_READY=1
	else
		echo "Failed to initialize submodules!"
		exit 1
	fi
fi

# Clear the output directory
rm -rf "$SDBOOT_DIR" >/dev/null 2>&1
mkdir "$SDBOOT_DIR"

# Build boot.img
echo "Building boot.img..."
cd "$BOOT_UNPACKER_DIR"
./gradlew clear >/dev/null 2>&1
rm *.img >/dev/null 2>&1
rm *.img.signed >/dev/null 2>&1
cp "$BASE_BOOT" "$BOOT_UNPACKER_DIR/boot.img"
#cp "$BASE_VBMETA" "$BOOT_UNPACKER_DIR/vbmeta.img"
./gradlew unpack >/dev/null 2>&1
cp -rf $PATCHES_DIR/* "$BOOT_UNPACKER_OUTPUT_DIR/root"
./gradlew pack >/dev/null 2>&1
cp "$BOOT_UNPACKER_DIR/boot.img.signed" "$SDBOOT_BOOT"
cd - >/dev/null 2>&1
if [ ! -f "$SDBOOT_BOOT" ]
then
	echo "Failed to build boot.img!"
	exit 2
fi

# Build vbmeta.img
echo "Building vbmeta.img..."
$AVBTOOL make_vbmeta_image \
--key "$BOOT_UNPACKER_KEYS_DIR/testkey_rsa4096.pem" --algorithm SHA256_RSA4096 \
--flag 0 \
--chain_partition boot:1:$BOOT_UNPACKER_KEYS_DIR/testkey_rsa4096_pub.bin \
--chain_partition dtbo:6:$BASE_KEYS_DIR/dtbo.key \
--chain_partition socko:13:$BASE_KEYS_DIR/socko.key \
--chain_partition odmko:14:$BASE_KEYS_DIR/odmko.key \
--chain_partition vbmeta_system:2:$BASE_KEYS_DIR/vbmeta_system.key \
--chain_partition vbmeta_system_ext:3:$BASE_KEYS_DIR/vbmeta_system_ext.key \
--chain_partition vbmeta_vendor:4:$BASE_KEYS_DIR/vbmeta_vendor.key \
--chain_partition vbmeta_product:5:$BASE_KEYS_DIR/vbmeta_product.key \
--chain_partition l_agdsp:7:$BASE_KEYS_DIR/l_agdsp.key \
--chain_partition l_cdsp:8:$BASE_KEYS_DIR/l_cdsp.key \
--chain_partition pm_sys:9:$BASE_KEYS_DIR/pm_sys.key \
--padding_size 16384 --output "$SDBOOT_VBMETA.unsigned"
$DHTBSIGN "$SDBOOT_VBMETA.unsigned" "$SDBOOT_VBMETA"
rm "$SDBOOT_VBMETA.unsigned" >/dev/null 2>&1
if [ ! -f "$SDBOOT_VBMETA" ]
then
	echo "Failed to build vbmeta.img!"
	exit 3
fi

# Let the user know everything's fine
echo "Built sdboot bootloader!"
