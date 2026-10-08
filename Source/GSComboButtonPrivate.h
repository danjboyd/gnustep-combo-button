/* GSComboButtonPrivate: what NSComboButton's code shares, and its tests.

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

#ifndef _GNUstep_H_GSComboButtonPrivate
#define _GNUstep_H_GSComboButtonPrivate

#import "GSComboButton.h"

#ifndef GS_HAS_COMBO_BUTTON

@interface NSComboButton (GSComboButtonPrivate)

/* Marks the class as this code's: GSComboButtonInstall() looks for it. */
+ (BOOL) _isGSComboButton;

/* The cell that draws the title and image, and that the theme gets as
   the bezel's cell.  Created on demand, kept in step with the button. */
- (NSButtonCell *) _labelCell;

/* The arrow part (split), or the arrow's place after the title
   (unified), in the bounds; NSZeroRect when the button is too narrow. */
- (NSRect) _arrowRect;

/* Where the title and image are drawn: the bounds less the arrow. */
- (NSRect) _titleRect;

/* The part a press at point (in the bounds) goes to. */
- (GSComboButtonPart) _partAtPoint: (NSPoint)point;

/* Whether the main part is drawn pressed, and whether the menu is
   showing (the arrow part drawn pressed). */
- (BOOL) _isMainPartEnabled;
- (BOOL) _isMenuPartEnabled;
- (BOOL) _isMainHighlighted;
- (BOOL) _isMenuShown;
- (void) _setMainHighlighted: (BOOL)flag;
- (void) _setMenuShown: (BOOL)flag;

/* The mouse: a press on a split button's main part, a press on a
   unified button, and showing the menu from the press that opened it. */
- (void) _trackMainPress: (NSEvent *)event;
- (void) _trackUnifiedPress: (NSEvent *)event;
- (void) _showMenuForEvent: (NSEvent *)event;

/* The menu's delegate gets -menuNeedsUpdate: once, and is detached
   while the menu shows (GNUstep's -[NSMenu update] would call it again
   without end if it adds items); then it is put back. */
- (id) _updateMenuForShowing: (NSMenu *)menu;
- (void) _restoreMenu: (NSMenu *)menu delegate: (id)delegate;

@end

/* Where a menu of size opens for a button at buttonRect (both in screen
   coordinates): below it, left edges lined up, or above it when there's
   no room below; moved left or right to stay in visible. */
NSPoint GSComboButtonMenuOrigin(NSRect buttonRect, NSSize size,
                                NSRect visible);

/* GSTheme's default drawing, the methods GSComboButtonInstall() copies
   into GSTheme.  Never instantiated. */
@interface GSComboButtonTheme : GSTheme
@end

#endif /* GS_HAS_COMBO_BUTTON */

#endif /* _GNUstep_H_GSComboButtonPrivate */
