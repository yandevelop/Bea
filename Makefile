TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = BeReal
ARCHS = arm64 arm64e
FINALPACKAGE = 1
PACKAGE_VERSION = 1.2

export SYSROOT = $(THEOS)/sdks/iPhoneOS15.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Bea

Bea_FILES = Tweak/Tweak.x
Bea_CFLAGS = -fobjc-arc
Bea_LDFLAGS += -ObjC
Bea_FRAMEWORKS = UIKit MapKit

ifeq ($(JAILED), 1)
Bea_CFLAGS += -D JAILED=1
endif

ifeq ($(LEGACY_SUPPORT), 1)
Bea_CFLAGS += -D LEGACY_SUPPORT=1
endif

include $(THEOS_MAKE_PATH)/tweak.mk
