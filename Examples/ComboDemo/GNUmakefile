# ComboDemo: NSComboButton's styles and states, under the current theme.
#
#   make -C Examples/ComboDemo && openapp Examples/ComboDemo/ComboDemo.app

include $(GNUSTEP_MAKEFILES)/common.make

GSCOMBOBUTTON_DIR = ../..
include $(GSCOMBOBUTTON_DIR)/GSComboButton.make

APP_NAME = ComboDemo
ComboDemo_OBJC_FILES = main.m $(GSCOMBOBUTTON_OBJC_FILES)
ADDITIONAL_INCLUDE_DIRS += $(GSCOMBOBUTTON_INCLUDE_DIRS) -I$(GSCOMBOBUTTON_DIR)/Source
ADDITIONAL_OBJCFLAGS += -Wall

include $(GNUSTEP_MAKEFILES)/application.make
