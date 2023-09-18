TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = BeReal
ARCHS = arm64
FINALPACKAGE = 1
PACKAGE_VERSION = 1.3.2

THEOS_PACKAGE_SCHEME = rootless

export SYSROOT = $(THEOS)/sdks/iPhoneOS15.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Bea

$(TWEAK_NAME)_FILES = Tweak/Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit MapKit

ifeq ($(LEGACY_SUPPORT), 1)
$(TWEAK_NAME)_CFLAGS += -D LEGACY_SUPPORT=1
endif

ifeq ($(JAILED), 1)
$(TWEAK_NAME)_CFLAGS += -D JAILED=1
endif

ifeq ($(NOLOGO), 1)
$(TWEAK_NAME)_CFLAGS += -D NOLOGO=1
endif

include $(THEOS_MAKE_PATH)/tweak.mk
