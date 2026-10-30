#
# Copyright (C) 2016 The CyanogenMod Project
#               2017-2019 The LineageOS Project
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

TARGET_GENERATED_BOOTANIMATION := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION/bootanimation.zip
$(TARGET_GENERATED_BOOTANIMATION): INTERMEDIATES := $(TARGET_OUT_INTERMEDIATES)/BOOTANIMATION
$(TARGET_GENERATED_BOOTANIMATION): $(SOONG_ZIP)
	@echo "Building bootanimation.zip"
	@rm -rf $(dir $@)
	@mkdir -p $(dir $@)
	$(hide) tar xfp vendor/yaap/bootanimation/bootanimation.tar -C $(INTERMEDIATES)
	$(hide) if [ $(TARGET_SCREEN_HEIGHT) -lt $(TARGET_SCREEN_WIDTH) ]; then \
	    IMAGEWIDTH=$(TARGET_SCREEN_HEIGHT); \
	else \
	    IMAGEWIDTH=$(TARGET_SCREEN_WIDTH); \
	fi; \
	for part_cnt in 0 1 2 3 4; do \
	    mkdir -p $(INTERMEDIATES)/part$$part_cnt; \
	done; \
	if [ "$$IMAGEWIDTH" -le 720 ] || [ "$(TARGET_BOOTANIMATION_HALF_RES)" = "true" ]; then \
	    SCALEWIDTH=$$IMAGEWIDTH; \
	    if [ "$(TARGET_BOOTANIMATION_HALF_RES)" = "true" ] && [ "$$IMAGEWIDTH" -gt 720 ]; then \
	        SCALEWIDTH=$$(expr $$IMAGEWIDTH / 2); \
	    fi; \
	    SCALEHEIGHT=$$(expr $$SCALEWIDTH \* 1920 / 1080); \
	    RESOLUTION="$${SCALEWIDTH}x$${SCALEHEIGHT}"; \
	    echo "Device 720p terdeteksi: Downscaling ke $$RESOLUTION dan mengompresi warna (250 colors)..."; \
	    MOGRIFY="prebuilts/tools-lineage/${HOST_OS}-x86/bin/mogrify"; \
	    if [ ! -f "$$MOGRIFY" ]; then MOGRIFY="mogrify"; fi; \
	    $$MOGRIFY -resize $$RESOLUTION -colors 250 $(INTERMEDIATES)/*/*.png; \
	    echo "$$SCALEWIDTH $$SCALEHEIGHT 60" > $(INTERMEDIATES)/desc.txt; \
	else \
	    echo "Device 1080p+ terdeteksi: Menggunakan resolusi asli 1080x1920 tanpa kompresi kualitas..."; \
	    echo "1080 1920 60" > $(INTERMEDIATES)/desc.txt; \
	fi; \
	cat vendor/yaap/bootanimation/desc.txt >> $(INTERMEDIATES)/desc.txt
	$(hide) $(SOONG_ZIP) -L 0 -o $(TARGET_GENERATED_BOOTANIMATION) -C $(INTERMEDIATES) -D $(INTERMEDIATES)

ifeq ($(TARGET_BOOTANIMATION),)
    TARGET_BOOTANIMATION := $(TARGET_GENERATED_BOOTANIMATION)
endif

include $(CLEAR_VARS)
LOCAL_MODULE := bootanimation.zip
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_OUT_PRODUCT)/media

include $(BUILD_SYSTEM)/base_rules.mk

$(LOCAL_BUILT_MODULE): $(TARGET_BOOTANIMATION)
	@cp $(TARGET_BOOTANIMATION) $@

include $(CLEAR_VARS)

BOOTANIMATION_SYMLINK := $(TARGET_OUT_PRODUCT)/media/bootanimation-dark.zip
$(BOOTANIMATION_SYMLINK): $(LOCAL_INSTALLED_MODULE)
	@mkdir -p $(dir $@)
	$(hide) ln -sf bootanimation.zip $@

ALL_DEFAULT_INSTALLED_MODULES += $(BOOTANIMATION_SYMLINK)