TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = BeReal
ARCHS = arm64 arm64e
PACKAGE_VERSION = 1.3.6
DEBUG=1

THEOS_PACKAGE_SCHEME = rootless
THEOS_DEVICE_IP = 192.168.178.29

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Bea

$(TWEAK_NAME)_FILES = $(shell find Tweak -name '*.xm')
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -std=c++11 -Wno-module-import-in-extern-c
$(TWEAK_NAME)_FRAMEWORKS = UIKit MapKit

ifeq ($(JAILED), 1)
$(TWEAK_NAME)_FILES += fishhook/fishhook.c
$(TWEAK_NAME)_CFLAGS += -D JAILED=1
endif

include $(THEOS_MAKE_PATH)/tweak.mk
