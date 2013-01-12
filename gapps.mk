#
# Copyright (C) 2012 joaquim.org
#
# Copy GAPPS
#
#

# use all present proprietary apk
PRODUCT_COPY_FILES += $(shell find device/rockchip/pascal2/proprietary -name '*.apk' \
-printf '%p:system/app/%f ')

# use all present proprietary lib
PRODUCT_COPY_FILES += $(shell find device/rockchip/pascal2/proprietary -name '*.so' \
-printf '%p:system/lib/%f ')

# use all present proprietary jar
PRODUCT_COPY_FILES += $(shell find device/rockchip/pascal2/proprietary -name '*.jar' \
-printf '%p:system/framework/%f ')

# use all present proprietary xml (permissions)
PRODUCT_COPY_FILES += $(shell find device/rockchip/pascal2/proprietary -name '*.xml' \
-printf '%p:system/etc/permissions/%f ')

# use all present ttf
PRODUCT_COPY_FILES += $(shell find device/rockchip/pascal2/proprietary -name '*.ttf' \
-printf '%p:system/fonts/%f ')

PRODUCT_COPY_FILES += \
    device/rockchip/pascal2/proprietary/70-gapps.sh:system/addon.d/70-gapps.sh \
	device/rockchip/pascal2/proprietary/g.prop:system/etc/g.prop
	
#Lang
PRODUCT_COPY_FILES += \
	$(call find-copy-subdir-files,*,device/rockchip/pascal2/proprietary/tts,system/tts)
	
#Lang srec
PRODUCT_COPY_FILES += \
	$(call find-copy-subdir-files,*,device/rockchip/pascal2/proprietary/usr,system/usr)
	
