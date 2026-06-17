ARCHS = arm64
TARGET = iphone:clang:16.5:14.0
THEOS_DEVICE_IP = 0.0.0.0

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = MeowRa1n

MeowRa1n_FILES = main.m AppDelegate.m RootViewController.m JailbreakEngine.m
MeowRa1n_FRAMEWORKS = UIKit Foundation CoreGraphics
MeowRa1n_CODESIGN_FLAGS = -Sentitlements.plist
MeowRa1n_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/application.mk