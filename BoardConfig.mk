#
# Copyright (C) 2011 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This variable is set first, so it can be overridden
# by BoardConfigVendor.mk


# Use the non-open-source parts, if they're present
-include vendor/rockchip/pascal2/BoardConfigVendor.mk

TARGET_BOARD_PLATFORM := rk29sdk
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv7-a-neon
TARGET_ARCH_VARIANT_CPU := cortex-a8
ARCH_ARM_HAVE_NEON := true
ARCH_ARM_HAVE_TLS_REGISTER := true
TARGET_GLOBAL_CFLAGS += -mtune=cortex-a8 -mfpu=neon
# -mfloat-abi=softfp
TARGET_GLOBAL_CPPFLAGS += -mtune=cortex-a8 -mfpu=neon
# -mfloat-abi=softfp

TARGET_PROVIDES_INIT_RC := true

TARGET_BOOTLOADER_BOARD_NAME := rk29board
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true

#Lib BINDER
BOARD_NEEDS_MEMORYHEAPPMEM := true
TARGET_USES_ION := true
#COMMON_GLOBAL_CFLAGS += -DBINDER_COMPAT

#DISABLE_HW_ID_MATCH_CHECK := true

#boot
BOARD_KERNEL_CMDLINE := console=ttyS1,115200n8n androidboot.console=ttyS1 init=/init initrd=0x62000000,0x800000 mtdparts=rk29xxnand:0x00002000@0x00002000(misc),0x00004000@0x00004000(kernel),0x00008000@0x00008000(boot),0x00008000@0x00010000(recovery),0x000F0000@0x00018000(backup),0x0003a000@0x00108000(cache),0x00200000@0x00142000(userdata),0x00002000@0x00342000(kpanic),0x000E6000@0x00344000(system),-@0x0042A000(user)

BOARD_KERNEL_BASE := 0x60400000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_BASE := 0x62000000


# Partitions 
BOARD_BOOTIMAGE_PARTITION_SIZE := 8936582
#BOARD_RECOVERYIMAGE_PARTITION_SIZE := 9388608
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 9988608
#BOARD_SYSTEMIMAGE_PARTITION_SIZE := 339738624
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 410000000
BOARD_USERDATAIMAGE_PARTITION_SIZE := 2013200384
BOARD_FLASH_BLOCK_SIZE := 4096
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_HAS_LARGE_FILESYSTEM := true


# Kernel
#TARGET_KERNEL_SOURCE    := kernel/rockchip/rk2918
#TARGET_KERNEL_CONFIG    := CM10_Pascal2_defconfig

TARGET_PREBUILT_KERNEL := device/rockchip/pascal2/kernel
DEVICE_RESOLUTION := 800x480

TARGET_SPECIFIC_HEADER_PATH := device/rockchip/pascal2/include

# Releasetools
TARGET_RELEASETOOL_OTA_FROM_TARGET_SCRIPT := ./device/rockchip/pascal2/releasetools/ota_from_target_files
#TARGET_RELEASETOOL_IMG_FROM_TARGET_SCRIPT := ./device/rockchip/pascal2/releasetools/pascal2_img_from_target_files
TARGET_CUSTOM_RELEASETOOL := ./device/rockchip/pascal2/releasetools/squisher

#Graphics
BOARD_EGL_CFG := device/rockchip/pascal2/egl.cfg
BOARD_NO_RGBX_8888 := true
USE_OPENGL_RENDERER := true
#TARGET_USES_GL_VENDOR_EXTENSIONS := true

TARGET_DISABLE_TRIPLE_BUFFERING := false
BOARD_USES_HDMI := true


# OMX - for now use soft decoding :(
BOARD_USES_PROPRIETARY_OMX := true

COMMON_GLOBAL_CFLAGS += -DSURFACEFLINGER_FORCE_SCREEN_RELEASE -DNO_RGBX_8888 -DMISSING_GRALLOC_BUFFERS

#HWCOMPOSER
BOARD_USES_HWCOMPOSER := true

#Touch screen
BOARD_USE_LEGACY_TOUCHSCREEN := true

# Misc display settings
#BOARD_USE_SKIA_LCDTEXT := true
#BOARD_HAVE_VPU := true

# Camera Setup
USE_CAMERA_STUB := false
BOARD_CAMERA_USE_MM_HEAP := true
COMMON_GLOBAL_CFLAGS += -DICS_CAMERA_BLOB

#Audio
BOARD_USES_GENERIC_AUDIO := false
BOARD_USES_ALSA_AUDIO := true
#COMMON_GLOBAL_CFLAGS += -DICS_AUDIO_BLOB

# Enable WEBGL in WebKit
ENABLE_WEBGL := true
# For WebKit rendering issue
TARGET_FORCE_CPU_UPLOAD := true

#recovery
TARGET_RECOVERY_INITRC := device/rockchip/pascal2/recovery_init.rc
BOARD_CUSTOM_RECOVERY_KEYMAPPING := ../../device/rockchip/pascal2/recovery_keys.c
BOARD_UMS_LUNFILE := "/sys/class/android_usb/android0/f_mass_storage/lun0/file"
#BOARD_NO_RGBX_8888 := true
BOARD_UMS_2ND_LUNFILE := "/sys/class/android_usb/android0/f_mass_storage/lun1/file"
BOARD_HAS_NO_SELECT_BUTTON := true
TARGET_RECOVERY_PRE_COMMAND := "busybox dd if=/misc.img of=/dev/block/mtd/by-name/misc; sync"

#Vold
TARGET_USE_CUSTOM_LUN_FILE_PATH := "/sys/class/android_usb/android0/f_mass_storage/lun%d/file"
TARGET_USE_CUSTOM_SECOND_LUN_NUM := 1
BOARD_VOLD_MAX_PARTITIONS := 20

# Wifi stuff
BOARD_WIFI_VENDOR := realtek

WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := WEXT
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_rtl

BOARD_WLAN_DEVICE := rtl8192cu
WIFI_DRIVER_MODULE_NAME   := wlan
WIFI_DRIVER_MODULE_PATH   := "/system/lib/modules/wlan.ko"

WIFI_DRIVER_MODULE_ARG    := ""
WIFI_FIRMWARE_LOADER      := ""
WIFI_DRIVER_FW_PATH_STA   := ""
WIFI_DRIVER_FW_PATH_AP    := ""
WIFI_DRIVER_FW_PATH_P2P   := ""
WIFI_DRIVER_FW_PATH_PARAM := ""

TARGET_CUSTOM_WIFI := ../../hardware/realtek/wlan/libhardware_legacy/wifi/wifi_realtek.c

#Bluethoot
BOARD_HAVE_BLUETOOTH := true
#BOARD_HAVE_BLUETOOTH_BCM := true
BOARD_HAVE_BLUETOOTH_CSR := true

# Default value, if not overridden else where.
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR ?= device/rockchip/pascal2/bluetooth

#HDMI
TARGET_HAVE_HDMI_OUT := true
#BOARD_HAVE_HDMI_SUPPORT := true

OUT_DIR := ./out/cm