TARGET := iphone:clang:latest:15.0
INSTALL_TARGET_PROCESSES = BeReal
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless
THEOS_DEVICE_IP = 192.168.102.61

export SYSROOT = $(THEOS)/sdks/iPhoneOS15.5.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Bea

Bea_FILES = Tweak.x
Bea_CFLAGS = -fobjc-arc
Bea_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
