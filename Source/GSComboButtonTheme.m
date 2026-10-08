/** <title>GSComboButtonTheme</title>

   <abstract>GSTheme's plain drawing of NSComboButton, the default a
   theme overrides.</abstract>

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

/* GSTheme's combo button methods.  Upstream they go into a GSTheme
   category in libs-gui (GSThemeDrawing.m) as they are.  Here they are
   written in GSComboButtonTheme, a subclass of GSTheme that is never
   instantiated: GSComboButtonInstall() copies its methods into GSTheme
   where GSTheme has none, so a theme's overrides win, as they would
   over GSTheme's own.  For that reason none of them may use super. */

#import "GSComboButtonPrivate.h"

#ifndef GS_HAS_COMBO_BUTTON

@implementation GSComboButtonTheme

- (CGFloat) comboButtonArrowWidth: (NSComboButton *)button
{
  return ([button style] == NSComboButtonStyleUnified ? 18.0 : 24.0);
}

- (void) drawComboButtonBezel: (NSComboButton *)button
                        frame: (NSRect)frame
                         part: (GSComboButtonPart)part
                        state: (GSThemeControlState)state
{
  NSRect clip = frame;
  CGFloat arrowWidth = [self comboButtonArrowWidth: button];

  if (part == GSComboButtonMainPart)
    {
      clip.size.width = MAX(0.0, NSWidth(frame) - arrowWidth);
    }
  else if (part == GSComboButtonArrowPart)
    {
      clip.origin.x = NSMaxX(frame) - arrowWidth;
      clip.size.width = arrowWidth;
    }
  /* A part is the whole bezel clipped, so its corners are the whole's. */
  [NSGraphicsContext saveGraphicsState];
  NSRectClip(clip);
  [self drawButton: frame
                in: [button _labelCell]
              view: button
             style: NSRoundedBezelStyle
             state: state];
  [NSGraphicsContext restoreGraphicsState];
}

- (void) drawComboButtonDivider: (NSComboButton *)button
                          frame: (NSRect)frame
                          state: (GSThemeControlState)state
{
  CGFloat inset = floor(NSHeight(frame) / 4.0);

  [[NSColor controlShadowColor] set];
  NSRectFill(NSMakeRect(NSMinX(frame), NSMinY(frame) + inset,
                        1.0, MAX(0.0, NSHeight(frame) - 2.0 * inset)));
}

- (void) drawComboButtonArrow: (NSComboButton *)button
                        frame: (NSRect)frame
                        state: (GSThemeControlState)state
{
  NSBezierPath *path = [NSBezierPath bezierPath];
  /* Off the bezel's rounded end, which takes the last few points. */
  CGFloat x = floor(NSMinX(frame) + (NSWidth(frame) - 4.0) / 2.0) + 0.5;
  CGFloat y = floor(NSMidY(frame));
  /* The chevron's point is at the bottom: lower on screen. */
  CGFloat down = ([button isFlipped] ? 2.0 : -2.0);
  NSColor *color = (state == GSThemeDisabledState
                    ? [NSColor disabledControlTextColor]
                    : [NSColor controlTextColor]);

  [path moveToPoint: NSMakePoint(x - 4.0, y - down)];
  [path lineToPoint: NSMakePoint(x, y + down)];
  [path lineToPoint: NSMakePoint(x + 4.0, y - down)];
  [path setLineWidth: 1.5];
  [path setLineCapStyle: NSRoundLineCapStyle];
  [path setLineJoinStyle: NSRoundLineJoinStyle];
  [color set];
  [path stroke];
}

@end

#endif /* GS_HAS_COMBO_BUTTON */
