TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = BeReal
ARCHS = arm64 arm64e
PACKAGE_VERSION = 1.3.6

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Bea

$(TWEAK_NAME)_FILES = Tweak/$(TWEAK_NAME).x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit MapKit

ifeq ($(JAILED), 1)
$(TWEAK_NAME)_FILES += fishhook/fishhook.c
$(TWEAK_NAME)_CFLAGS += -D JAILED=1
endif

include $(THEOS_MAKE_PATH)/tweak.mk
