# GSComboButton.make: compiles NSComboButton into a theme (or an app).
#
# In a theme's (or app's) GNUmakefile, after including common.make:
#
#   GSCOMBOBUTTON_DIR = path/to/gnustep-combo-button
#   include $(GSCOMBOBUTTON_DIR)/GSComboButton.make
#   MyTheme_OBJC_FILES += $(GSCOMBOBUTTON_OBJC_FILES)
#   ADDITIONAL_INCLUDE_DIRS += $(GSCOMBOBUTTON_INCLUDE_DIRS)
#
# Nothing needs calling: NSComboButton installs GSTheme's default drawing
# the first time it is used.
#
# GSCOMBOBUTTON_DIR must be a relative path (objects go to
# ./obj/<target>.obj/<source path>), and the += lines must come before
# bundle.make / application.make is included, or these sources aren't
# built.

GSCOMBOBUTTON_DIR ?= .

GSCOMBOBUTTON_OBJC_FILES = \
  $(GSCOMBOBUTTON_DIR)/Source/NSComboButton.m \
  $(GSCOMBOBUTTON_DIR)/Source/GSComboButtonTheme.m \
  $(GSCOMBOBUTTON_DIR)/Source/GSComboButtonInstall.m

GSCOMBOBUTTON_INCLUDE_DIRS = -I$(GSCOMBOBUTTON_DIR)/Headers
