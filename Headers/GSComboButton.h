/** <title>GSComboButton</title>

   <abstract>NSComboButton for GNUstep, and the GSTheme methods that
   draw it.</abstract>

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

/* Upstream, this header's parts go to: the class to
   AppKit/NSComboButton.h as it is, and the GSTheme methods and
   GSComboButtonPart to GNUstepGUI/GSTheme.h.  GSComboButtonInstall()
   stays an extension of this copy only. */

#ifndef _GNUstep_H_GSComboButton
#define _GNUstep_H_GSComboButton

#import <AppKit/AppKit.h>
#import <GNUstepGUI/GSTheme.h>

/* GSCB_EXPORT declares this code's public functions.  The code is
   compiled into the theme or app that uses it, never into a DLL of its
   own, so GS_EXPORT (dllimport on Windows outside GNUstep's own
   libraries) is wrong here.  In libs-gui these become APPKIT_EXPORT. */
#ifndef GSCB_EXPORT
#  define GSCB_EXPORT extern
#endif

#import "AppKit/NSComboButton.h"

#ifndef GS_HAS_COMBO_BUTTON

/**
 * The parts of a combo button the theme draws.
 * <deflist>
 * <term>GSComboButtonWholePart</term>
 * <desc>The whole button: its bezel in the button's own state
 * (normal or disabled).</desc>
 * <term>GSComboButtonMainPart</term>
 * <desc>A split button's title part, drawn over the whole while it is
 * pressed.</desc>
 * <term>GSComboButtonArrowPart</term>
 * <desc>A split button's arrow part, drawn over the whole while its
 * menu is open.</desc>
 * </deflist>
 */
typedef NS_ENUM(NSInteger, GSComboButtonPart)
{
  GSComboButtonWholePart = 0,
  GSComboButtonMainPart = 1,
  GSComboButtonArrowPart = 2
};

/**
 * The theme's drawing of NSComboButton.  GSTheme has a plain default for
 * each method, in system colours (the bezel is the theme's own button
 * bezel); a theme overrides the ones it draws differently.
 */
@interface GSTheme (GSComboButton)

/**
 * Returns the width of the arrow part: a split button's part at the
 * right, or for a unified button the space the arrow takes after the
 * title.  The default is 24 for split, 18 for unified.
 */
- (CGFloat) comboButtonArrowWidth: (NSComboButton *)button;

/**
 * Draws the bezel of part of button in frame, which is always the whole
 * button's bounds: a part's bezel is the whole bezel clipped to the
 * part, so the corners match.  The default draws the theme's button
 * bezel (-drawButton:in:view:style:state:) for a rounded push button.
 */
- (void) drawComboButtonBezel: (NSComboButton *)button
                        frame: (NSRect)frame
                         part: (GSComboButtonPart)part
                        state: (GSThemeControlState)state;

/**
 * Draws the line between a split button's parts, in frame (a one point
 * wide rectangle the height of the button).  The default draws the
 * control's shadow colour, inset a quarter of the height at each end.
 */
- (void) drawComboButtonDivider: (NSComboButton *)button
                          frame: (NSRect)frame
                          state: (GSThemeControlState)state;

/**
 * Draws the arrow (a downward chevron) centred in frame, the arrow
 * part.  The default draws it in the control's text colour, dimmed when
 * disabled.
 */
- (void) drawComboButtonArrow: (NSComboButton *)button
                        frame: (NSRect)frame
                        state: (GSThemeControlState)state;

@end

#if	defined(__cplusplus)
extern "C" {
#endif

/**
 * Adds GSTheme's default drawing for NSComboButton where GSTheme has
 * none.  NSComboButton calls it itself the first time the class is
 * used, so neither apps nor themes need to.  Returns NO, doing nothing,
 * when the NSComboButton class in the process isn't this code's (libs-gui
 * has its own, or another copy of this code was loaded first).
 */
GSCB_EXPORT BOOL GSComboButtonInstall(void);

#if	defined(__cplusplus)
}
#endif

#endif	/* GS_HAS_COMBO_BUTTON */

#endif	/* _GNUstep_H_GSComboButton */
