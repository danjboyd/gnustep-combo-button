# Builds NSComboButton as a library, the demo, and runs the tests.
# Themes and apps don't use this: they compile the sources in through
# GSComboButton.make.

include $(GNUSTEP_MAKEFILES)/common.make

GSCOMBOBUTTON_DIR = .
include GSComboButton.make

LIBRARY_NAME = libGSComboButton
libGSComboButton_OBJC_FILES = $(GSCOMBOBUTTON_OBJC_FILES)
libGSComboButton_HEADER_FILES_DIR = Headers
libGSComboButton_HEADER_FILES = GSComboButton.h AppKit/NSComboButton.h
libGSComboButton_LIBRARIES_DEPEND_UPON = -lgnustep-gui $(FND_LIBS) $(OBJC_LIBS)
ADDITIONAL_INCLUDE_DIRS += $(GSCOMBOBUTTON_INCLUDE_DIRS)
ADDITIONAL_OBJCFLAGS += -Wall

include $(GNUSTEP_MAKEFILES)/library.make

combodemo: all
	$(MAKE) -C Examples/ComboDemo

# The tests need a display (a private Xvfb; DISPLAY must be set, and no
# window manager is needed). They run with empty user defaults.
check:: all
	cd Tests && LD_LIBRARY_PATH=$(CURDIR)/obj:$$LD_LIBRARY_PATH \
	  gnustep-tests gui/NSComboButton
