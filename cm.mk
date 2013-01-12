## Specify phone tech before including full_phone
#$(call inherit-product, vendor/cm/config/gsm.mk)

# Release name
PRODUCT_RELEASE_NAME := Pascal2

# Inherit some common CM stuff. 
# Changed to not get the proprietary stuff
$(call inherit-product, vendor/cm/config/common_full_tablet_wifionly.mk)

# Inherit device configuration
$(call inherit-product, device/rockchip/pascal2/full_pascal2.mk)

#Animation
#PRODUCT_COPY_FILES += \
#        device/rockchip/pascal2/bootanimation.zip:system/media/bootanimation.zip


## Device identifier. This must come after all inclusions
# Set those variables here to overwrite the inherited values.
PRODUCT_DEVICE := pascal2
PRODUCT_NAME := cm_pascal2
PRODUCT_BRAND := Pascal2
PRODUCT_MODEL := BQ Pascal 2
PRODUCT_MANUFACTURER := Mundo Reader
