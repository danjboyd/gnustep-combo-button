/** <title>NSComboButton</title>

   <abstract>A button with an attached menu.</abstract>

   Copyright (C) 2026 Daniel Boyd

   Author: Daniel Boyd <danieljboyd@icloud.com>
   Date: 2026

   This file is part of the GNUstep GUI Library.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the
   Free Software Foundation, 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.
*/

#ifndef _NSComboButton_h_GNUSTEP_GUI_INCLUDE
#define _NSComboButton_h_GNUSTEP_GUI_INCLUDE

#import <AppKit/NSControl.h>
#import <AppKit/NSImageCell.h>

/* libs-gui defines GS_HAS_COMBO_BUTTON once it has NSComboButton itself;
   this copy then declares nothing. */
#ifndef GS_HAS_COMBO_BUTTON

/* gnustep-base before 1.30 doesn't define it. */
#ifndef MAC_OS_VERSION_13_0
#  define MAC_OS_VERSION_13_0 130000
#endif

#if OS_API_VERSION(MAC_OS_VERSION_13_0, GS_API_LATEST)

#if	defined(__cplusplus)
extern "C" {
#endif

@class NSButtonCell;
@class NSImage;
@class NSMenu;
@class NSString;

/**
 * How an NSComboButton offers its action and its menu.
 * <deflist>
 * <term>NSComboButtonStyleSplit</term>
 * <desc>Two parts: a click on the title sends the action, a press on
 * the arrow at the right shows the menu.  The default.</desc>
 * <term>NSComboButtonStyleUnified</term>
 * <desc>One part: a click sends the action; a press held a moment, or
 * dragged, shows the menu.</desc>
 * </deflist>
 */
typedef NS_ENUM(NSInteger, NSComboButtonStyle)
{
  NSComboButtonStyleSplit = 0,
  NSComboButtonStyleUnified = 1
};

/**
 * <p>A button with an attached menu: a click performs its action, and
 * its menu offers related choices (macOS 13's NSComboButton).</p>
 * <p>The current theme draws it (see GSTheme's
 * -drawComboButtonBezel:frame:part:state: and the methods with it),
 * the bezel as one of the theme's buttons.  Before the menu shows,
 * the menu's delegate gets -menuNeedsUpdate:.  Like AppKit's, the
 * button has no key equivalent: a subclass that wants one overrides
 * -performKeyEquivalent:.</p>
 */
APPKIT_EXPORT_CLASS
@interface NSComboButton : NSControl
{
  NSString *_title;
  NSImage *_image;
  NSImageScaling _imageScaling;
  NSComboButtonStyle _style;
  id _target;
  SEL _action;
  BOOL _enabled;
  BOOL _mainHighlighted;
  BOOL _menuShown;
  NSButtonCell *_labelCell;
}

/**
 * Returns a split combo button with the given title, menu, target and
 * action.
 */
+ (instancetype) comboButtonWithTitle: (NSString *)title
                                 menu: (NSMenu *)menu
                               target: (id)target
                               action: (SEL)action;

/**
 * Returns a split combo button showing image, with the given menu,
 * target and action.
 */
+ (instancetype) comboButtonWithImage: (NSImage *)image
                                 menu: (NSMenu *)menu
                               target: (id)target
                               action: (SEL)action;

/**
 * Returns a split combo button showing image before title, with the
 * given menu, target and action.
 */
+ (instancetype) comboButtonWithTitle: (NSString *)title
                                image: (NSImage *)image
                                 menu: (NSMenu *)menu
                               target: (id)target
                               action: (SEL)action;

/**
 * Returns the title (an empty string when there is none).
 */
- (NSString *) title;

/**
 * Sets the title shown on the button (on its main part when split).
 */
- (void) setTitle: (NSString *)title;

/**
 * Returns the image shown before the title, or nil.
 */
- (NSImage *) image;

/**
 * Sets the image shown before the title.
 */
- (void) setImage: (NSImage *)image;

/**
 * Returns how the image is scaled to fit
 * (NSImageScaleProportionallyDown by default).
 */
- (NSImageScaling) imageScaling;

/**
 * Sets how the image is scaled to fit.
 */
- (void) setImageScaling: (NSImageScaling)scaling;

/**
 * Returns the menu the button shows, or nil.
 */
- (NSMenu *) menu;

/**
 * Sets the menu the button shows.  The menu's delegate, if it has one,
 * gets -menuNeedsUpdate: each time before the menu shows.
 */
- (void) setMenu: (NSMenu *)menu;

/**
 * Returns the style (NSComboButtonStyleSplit by default).
 */
- (NSComboButtonStyle) style;

/**
 * Sets the style.
 */
- (void) setStyle: (NSComboButtonStyle)style;

/**
 * Returns the size the button needs: the title and image in the
 * control's font, with the theme's button margins, and the arrow.
 * NSView declares this on macOS; GNUstep's NSView does not yet.
 */
- (NSSize) fittingSize;

@end

#if	defined(__cplusplus)
}
#endif

#endif	/* OS_API_VERSION */

#endif	/* GS_HAS_COMBO_BUTTON */

#endif	/* _NSComboButton_h_GNUSTEP_GUI_INCLUDE */
