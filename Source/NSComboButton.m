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

#import "GSComboButtonPrivate.h"
#include <math.h>

#ifndef GS_HAS_COMBO_BUTTON

/* How long a unified button's press is held before its menu shows, and
   how far a press moves to show it at once. */
static const NSTimeInterval GSComboButtonHoldDelay = 0.4;
static const CGFloat GSComboButtonDragDistance = 3.0;

/* The gap between the button and its menu. */
static const CGFloat GSComboButtonMenuGap = 2.0;

NSPoint
GSComboButtonMenuOrigin(NSRect buttonRect, NSSize size, NSRect visible)
{
  NSPoint origin = NSMakePoint(NSMinX(buttonRect),
    NSMinY(buttonRect) - GSComboButtonMenuGap - size.height);

  if (origin.y < NSMinY(visible))
    {
      /* No room below: above, or as high as the screen allows. */
      origin.y = MIN(NSMaxY(buttonRect) + GSComboButtonMenuGap,
                     NSMaxY(visible) - size.height);
    }
  if (origin.x + size.width > NSMaxX(visible))
    {
      origin.x = NSMaxX(visible) - size.width;
    }
  if (origin.x < NSMinX(visible))
    {
      origin.x = NSMinX(visible);
    }
  return origin;
}

@implementation NSComboButton

+ (void) initialize
{
  if (self == [NSComboButton class])
    {
      [self setVersion: 1];
      GSComboButtonInstall();
    }
}

+ (Class) cellClass
{
  /* The button keeps its own state, as NSSwitch does; a private cell
     only draws the title. */
  return nil;
}

+ (instancetype) comboButtonWithTitle: (NSString *)title
                                 menu: (NSMenu *)menu
                               target: (id)target
                               action: (SEL)action
{
  return [self comboButtonWithTitle: title
                              image: nil
                               menu: menu
                             target: target
                             action: action];
}

+ (instancetype) comboButtonWithImage: (NSImage *)image
                                 menu: (NSMenu *)menu
                               target: (id)target
                               action: (SEL)action
{
  return [self comboButtonWithTitle: nil
                              image: image
                               menu: menu
                             target: target
                             action: action];
}

+ (instancetype) comboButtonWithTitle: (NSString *)title
                                image: (NSImage *)image
                                 menu: (NSMenu *)menu
                               target: (id)target
                               action: (SEL)action
{
  NSComboButton *button;

  button = AUTORELEASE([[self alloc] initWithFrame: NSZeroRect]);
  [button setTitle: title];
  [button setImage: image];
  [button setMenu: menu];
  [button setTarget: target];
  [button setAction: action];
  [button sizeToFit];
  return button;
}

- (id) initWithFrame: (NSRect)frame
{
  if ((self = [super initWithFrame: frame]) != nil)
    {
      ASSIGN(_title, @"");
      _imageScaling = NSImageScaleProportionallyDown;
      _style = NSComboButtonStyleSplit;
      _enabled = YES;
    }
  return self;
}

- (void) dealloc
{
  DESTROY(_title);
  DESTROY(_image);
  DESTROY(_labelCell);
  [super dealloc];
}


/* The API. */

- (NSString *) title
{
  return _title;
}

- (void) setTitle: (NSString *)title
{
  ASSIGNCOPY(_title, (title != nil ? title : @""));
  [self setNeedsDisplay: YES];
}

- (NSImage *) image
{
  return _image;
}

- (void) setImage: (NSImage *)image
{
  ASSIGN(_image, image);
  [self setNeedsDisplay: YES];
}

- (NSImageScaling) imageScaling
{
  return _imageScaling;
}

- (void) setImageScaling: (NSImageScaling)scaling
{
  _imageScaling = scaling;
  [self setNeedsDisplay: YES];
}

/* The menu is NSResponder's (NSView's context menu), as on macOS. */
- (NSMenu *) menu
{
  return [super menu];
}

- (void) setMenu: (NSMenu *)menu
{
  [super setMenu: menu];
}

- (NSComboButtonStyle) style
{
  return _style;
}

- (void) setStyle: (NSComboButtonStyle)style
{
  _style = style;
  [self setNeedsDisplay: YES];
}


/* NSControl's state, kept here as there is no cell. */

- (id) target
{
  return _target;
}

- (void) setTarget: (id)target
{
  _target = target;
}

- (SEL) action
{
  return _action;
}

- (void) setAction: (SEL)action
{
  _action = action;
}

- (BOOL) isEnabled
{
  return _enabled;
}

- (void) setEnabled: (BOOL)flag
{
  if (_enabled != flag)
    {
      _enabled = flag;
      [self setNeedsDisplay: YES];
    }
}

- (NSString *) stringValue
{
  return _title;
}

- (void) setStringValue: (NSString *)string
{
  [self setTitle: string];
}


/* Size. */

- (NSSize) intrinsicContentSize
{
  NSButtonCell *cell = AUTORELEASE([[NSButtonCell alloc] initTextCell: _title]);
  NSSize size;

  /* As big as a rounded push button with the title and image, in the
     theme's font and margins, and the arrow besides. */
  [cell setBezelStyle: NSRoundedBezelStyle];
  [cell setFont: [self font]];
  [cell setImage: _image];
  [cell setImagePosition: [[self _labelCell] imagePosition]];
  size = [cell cellSize];
  size.width += [[GSTheme theme] comboButtonArrowWidth: self];
  return NSMakeSize(ceil(size.width), ceil(size.height));
}

- (NSSize) fittingSize
{
  return [self intrinsicContentSize];
}

- (void) sizeToFit
{
  [self setFrameSize: [self intrinsicContentSize]];
}

- (NSFont *) font
{
  NSFont *font = [super font];

  return (font != nil ? font : [NSFont systemFontOfSize: 0.0]);
}


/* Drawing. */

- (BOOL) isOpaque
{
  return NO;
}

- (void) drawRect: (NSRect)dirtyRect
{
  GSTheme *theme = [GSTheme theme];
  NSRect bounds = [self bounds];
  NSRect arrowRect = [self _arrowRect];
  GSThemeControlState state;

  state = (_enabled ? GSThemeNormalState : GSThemeDisabledState);
  [theme drawComboButtonBezel: self
                        frame: bounds
                         part: GSComboButtonWholePart
                        state: state];
  if (_enabled && _style == NSComboButtonStyleSplit)
    {
      if (_mainHighlighted && [self _isMainPartEnabled])
        {
          [theme drawComboButtonBezel: self
                                frame: bounds
                                 part: GSComboButtonMainPart
                                state: GSThemeHighlightedState];
        }
      if (_menuShown)
        {
          [theme drawComboButtonBezel: self
                                frame: bounds
                                 part: GSComboButtonArrowPart
                                state: GSThemeHighlightedState];
        }
    }
  else if (_enabled && (_mainHighlighted || _menuShown))
    {
      [theme drawComboButtonBezel: self
                            frame: bounds
                             part: GSComboButtonWholePart
                            state: GSThemeHighlightedState];
    }

  {
    /* Inside the bezel's margins, as a button's title is. */
    NSRect titleRect = [self _titleRect];
    GSThemeMargins margins = [theme buttonMarginsForCell: [self _labelCell]
                                                   style: NSRoundedBezelStyle
                                                   state: state];

    /* The same at the divider as at the left edge, so the title stays
       centred in its part. */
    titleRect.origin.x += margins.left;
    titleRect.size.width -= 2.0 * margins.left;
    titleRect.origin.y += ([self isFlipped] ? margins.top : margins.bottom);
    titleRect.size.height -= margins.top + margins.bottom;
    [[self _labelCell] drawInteriorWithFrame: titleRect inView: self];
  }

  if (NSIsEmptyRect(arrowRect) == NO)
    {
      if (_style == NSComboButtonStyleSplit)
        {
          [theme drawComboButtonDivider: self
                                  frame: NSMakeRect(NSMinX(arrowRect),
                                                    NSMinY(bounds), 1.0,
                                                    NSHeight(bounds))
                                  state: state];
        }
      GSThemeControlState arrowState = state;

      if ([self _isMenuPartEnabled] == NO)
        {
          arrowState = GSThemeDisabledState;
        }
      else if (_menuShown)
        {
          arrowState = GSThemeHighlightedState;
        }
      [theme drawComboButtonArrow: self frame: arrowRect state: arrowState];
    }

  if (_enabled && [[self window] firstResponder] == self
      && [[self window] isKeyWindow])
    {
      [theme drawFocusFrame: NSInsetRect(bounds, 2.0, 2.0) view: self];
    }
}


/* Mouse and keyboard. */

- (BOOL) acceptsFirstMouse: (NSEvent *)event
{
  return YES;
}

- (BOOL) acceptsFirstResponder
{
  return _enabled;
}

- (void) mouseDown: (NSEvent *)event
{
  NSPoint point;

  if (_enabled == NO)
    {
      return;
    }
  point = [self convertPoint: [event locationInWindow] fromView: nil];
  if (_style == NSComboButtonStyleSplit
      && [self _partAtPoint: point] == GSComboButtonArrowPart)
    {
      if ([self _isMenuPartEnabled])
        {
          [self _showMenuForEvent: event];
        }
    }
  else if (_style == NSComboButtonStyleUnified)
    {
      if (_action == NULL)
        {
          /* As AppKit's: with no action, the menu shows on the press. */
          if ([self _isMenuPartEnabled])
            {
              [self _showMenuForEvent: event];
            }
        }
      else
        {
          [self _trackUnifiedPress: event];
        }
    }
  else if ([self _isMainPartEnabled])
    {
      [self _trackMainPress: event];
    }
}

- (void) keyDown: (NSEvent *)event
{
  NSString *characters = [event charactersIgnoringModifiers];

  if (_enabled && [characters isEqualToString: @" "])
    {
      [self performClick: self];
      return;
    }
  [super keyDown: event];
}

- (void) performClick: (id)sender
{
  if ([self _isMainPartEnabled] == NO || _action == NULL)
    {
      return;
    }
  /* A brief press of the main part, as a button's. */
  [self _setMainHighlighted: YES];
  [self _setMainHighlighted: NO];
  [self sendAction: _action to: _target];
}


/* As AppKit's, the button has no context menu: its menu is the arrow's. */
- (NSMenu *) menuForEvent: (NSEvent *)event
{
  return nil;
}


/* Accessibility. */

- (BOOL) isAccessibilityElement
{
  return YES;
}

- (NSString *) accessibilityRole
{
  return NSAccessibilityButtonRole;
}

- (NSString *) accessibilityLabel
{
  return _title;
}


/* NSCoding. */

- (void) encodeWithCoder: (NSCoder *)coder
{
  [super encodeWithCoder: coder];
  if ([coder allowsKeyedCoding])
    {
      [coder encodeObject: _title forKey: @"NSComboButtonTitle"];
      if (_image != nil)
        {
          [coder encodeObject: _image forKey: @"NSComboButtonImage"];
        }
      [coder encodeInteger: _imageScaling forKey: @"NSComboButtonImageScaling"];
      [coder encodeInteger: _style forKey: @"NSComboButtonStyle"];
      if ([self menu] != nil)
        {
          [coder encodeObject: [self menu] forKey: @"NSComboButtonMenu"];
        }
      if (_action != NULL)
        {
          [coder encodeObject: NSStringFromSelector(_action)
                       forKey: @"NSControlAction"];
        }
      if (_target != nil)
        {
          [coder encodeConditionalObject: _target forKey: @"NSControlTarget"];
        }
      /* NSControl encodes NSEnabled, from -isEnabled. */
    }
  else
    {
      NSInteger value;

      [coder encodeObject: _title];
      [coder encodeObject: _image];
      value = _imageScaling;
      [coder encodeValueOfObjCType: @encode(NSInteger) at: &value];
      value = _style;
      [coder encodeValueOfObjCType: @encode(NSInteger) at: &value];
      [coder encodeObject: [self menu]];
      [coder encodeValueOfObjCType: @encode(SEL) at: &_action];
      [coder encodeConditionalObject: _target];
      [coder encodeValueOfObjCType: @encode(BOOL) at: &_enabled];
    }
}

- (id) initWithCoder: (NSCoder *)coder
{
  if ((self = [super initWithCoder: coder]) == nil)
    {
      return nil;
    }
  ASSIGN(_title, @"");
  _imageScaling = NSImageScaleProportionallyDown;
  _style = NSComboButtonStyleSplit;
  _enabled = YES;
  if ([coder allowsKeyedCoding])
    {
      if ([coder containsValueForKey: @"NSComboButtonTitle"])
        {
          [self setTitle: [coder decodeObjectForKey: @"NSComboButtonTitle"]];
        }
      if ([coder containsValueForKey: @"NSComboButtonImage"])
        {
          ASSIGN(_image, [coder decodeObjectForKey: @"NSComboButtonImage"]);
        }
      if ([coder containsValueForKey: @"NSComboButtonImageScaling"])
        {
          _imageScaling = [coder decodeIntegerForKey: @"NSComboButtonImageScaling"];
        }
      if ([coder containsValueForKey: @"NSComboButtonStyle"])
        {
          _style = [coder decodeIntegerForKey: @"NSComboButtonStyle"];
        }
      if ([coder containsValueForKey: @"NSComboButtonMenu"])
        {
          [self setMenu: [coder decodeObjectForKey: @"NSComboButtonMenu"]];
        }
      if ([coder containsValueForKey: @"NSControlAction"])
        {
          NSString *name = [coder decodeObjectForKey: @"NSControlAction"];

          _action = (name != nil ? NSSelectorFromString(name) : NULL);
        }
      if ([coder containsValueForKey: @"NSControlTarget"])
        {
          _target = [coder decodeObjectForKey: @"NSControlTarget"];
        }
      if ([coder containsValueForKey: @"NSEnabled"])
        {
          _enabled = [coder decodeBoolForKey: @"NSEnabled"];
        }
    }
  else
    {
      NSInteger value;

      [self setTitle: [coder decodeObject]];
      ASSIGN(_image, [coder decodeObject]);
      [coder decodeValueOfObjCType: @encode(NSInteger) at: &value];
      _imageScaling = value;
      [coder decodeValueOfObjCType: @encode(NSInteger) at: &value];
      _style = value;
      [self setMenu: [coder decodeObject]];
      [coder decodeValueOfObjCType: @encode(SEL) at: &_action];
      _target = [coder decodeObject];
      [coder decodeValueOfObjCType: @encode(BOOL) at: &_enabled];
    }
  return self;
}

@end


@implementation NSComboButton (GSComboButtonPrivate)

/* As AppKit's: a split button's title part is disabled without an
   action, and the arrow part without menu items. */
- (BOOL) _isMainPartEnabled
{
  return _enabled && (_style == NSComboButtonStyleUnified || _action != NULL);
}

- (BOOL) _isMenuPartEnabled
{
  return _enabled && [[self menu] numberOfItems] > 0;
}

+ (BOOL) _isGSComboButton
{
  return YES;
}

- (NSButtonCell *) _labelCell
{
  NSCellImagePosition position;

  if (_labelCell == nil)
    {
      _labelCell = [[NSButtonCell alloc] initTextCell: @""];
      [_labelCell setBordered: NO];
      [_labelCell setBezelStyle: NSRoundedBezelStyle];
    }
  if (_image == nil)
    {
      position = NSNoImage;
    }
  else if ([_title length] == 0)
    {
      position = NSImageOnly;
    }
  else
    {
      position = NSImageLeft;
    }
  [_labelCell setTitle: _title];
  [_labelCell setImage: _image];
  [_labelCell setImagePosition: position];
  [_labelCell setImageScaling: _imageScaling];
  [_labelCell setFont: [self font]];
  [_labelCell setEnabled: [self _isMainPartEnabled]];
  [_labelCell setHighlighted: _mainHighlighted];
  return _labelCell;
}

- (NSRect) _arrowRect
{
  NSRect bounds = [self bounds];
  CGFloat width = [[GSTheme theme] comboButtonArrowWidth: self];

  if (width <= 0.0 || NSWidth(bounds) <= width * 2.0)
    {
      return NSZeroRect;
    }
  return NSMakeRect(NSMaxX(bounds) - width, NSMinY(bounds),
                    width, NSHeight(bounds));
}

- (NSRect) _titleRect
{
  NSRect bounds = [self bounds];
  NSRect arrowRect = [self _arrowRect];

  if (NSIsEmptyRect(arrowRect) == NO)
    {
      bounds.size.width = NSMinX(arrowRect) - NSMinX(bounds);
    }
  return bounds;
}

- (GSComboButtonPart) _partAtPoint: (NSPoint)point
{
  NSRect arrowRect = [self _arrowRect];

  if (_style == NSComboButtonStyleSplit
      && NSMouseInRect(point, arrowRect, [self isFlipped]))
    {
      return GSComboButtonArrowPart;
    }
  return GSComboButtonMainPart;
}

- (BOOL) _isMainHighlighted
{
  return _mainHighlighted;
}

- (BOOL) _isMenuShown
{
  return _menuShown;
}

- (void) _setMainHighlighted: (BOOL)flag
{
  if (_mainHighlighted != flag)
    {
      _mainHighlighted = flag;
      [self setNeedsDisplay: YES];
      [self displayIfNeeded];
    }
}

- (void) _setMenuShown: (BOOL)flag
{
  if (_menuShown != flag)
    {
      _menuShown = flag;
      [self setNeedsDisplay: YES];
      [self displayIfNeeded];
    }
}

/* The delegate's -menuNeedsUpdate: once, as on macOS.  GNUstep's
   -[NSMenu update] calls it before its recursion check, and changing an
   item (-itemChanged:, from -[NSMenuItem setTarget:] and the like) calls
   -update, so a delegate that fills the menu there is called again
   without end.  So the delegate is detached before it is called, and
   stays detached while the menu shows (-displayTransient updates the
   menu too).  Returns it, for -_restoreMenu:delegate:, or nil. */
- (id) _updateMenuForShowing: (NSMenu *)menu
{
  id delegate = [menu delegate];

  if ([delegate respondsToSelector: @selector(menuNeedsUpdate:)] == NO)
    {
      return nil;
    }
  RETAIN(delegate);
  [menu setDelegate: nil];
  [delegate menuNeedsUpdate: menu];
  return AUTORELEASE(delegate);
}

- (void) _restoreMenu: (NSMenu *)menu delegate: (id)delegate
{
  if (delegate != nil)
    {
      [menu setDelegate: delegate];
    }
}

/* A press on a split button's main part: pressed while the pointer is
   on it, and the action sent when it is released there. */
- (void) _trackMainPress: (NSEvent *)event
{
  NSRect mainRect = [self _titleRect];
  BOOL inside = YES;

  [self _setMainHighlighted: YES];
  while (YES)
    {
      NSEvent *next;
      NSPoint point;

      next = [NSApp nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask
                                untilDate: [NSDate distantFuture]
                                   inMode: NSEventTrackingRunLoopMode
                                  dequeue: YES];
      point = [self convertPoint: [next locationInWindow] fromView: nil];
      inside = NSMouseInRect(point, mainRect, [self isFlipped]);
      if ([next type] == NSLeftMouseUp)
        {
          break;
        }
      [self _setMainHighlighted: inside];
    }
  [self _setMainHighlighted: NO];
  if (inside)
    {
      [self sendAction: _action to: _target];
    }
}

/* A press on a unified button: released soon, the action; held, or
   dragged, the menu. */
- (void) _trackUnifiedPress: (NSEvent *)event
{
  NSPoint start = [event locationInWindow];
  NSDate *until;
  BOOL inside = YES;

  until = ([self _isMenuPartEnabled]
           ? [NSDate dateWithTimeIntervalSinceNow: GSComboButtonHoldDelay]
           : [NSDate distantFuture]);
  [self _setMainHighlighted: YES];
  while (YES)
    {
      NSEvent *next;
      NSPoint location;

      next = [NSApp nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask
                                untilDate: until
                                   inMode: NSEventTrackingRunLoopMode
                                  dequeue: YES];
      if (next == nil)
        {
          /* Held: the menu. */
          [self _setMainHighlighted: NO];
          [self _showMenuForEvent: event];
          return;
        }
      location = [next locationInWindow];
      inside = NSMouseInRect([self convertPoint: location fromView: nil],
                             [self bounds], [self isFlipped]);
      if ([next type] == NSLeftMouseUp)
        {
          break;
        }
      if ([self _isMenuPartEnabled]
          && hypot(location.x - start.x, location.y - start.y)
             >= GSComboButtonDragDistance)
        {
          [self _setMainHighlighted: NO];
          [self _showMenuForEvent: event];
          return;
        }
      [self _setMainHighlighted: inside];
    }
  [self _setMainHighlighted: NO];
  if (inside)
    {
      [self sendAction: _action to: _target];
    }
}

/* Shows the menu below the button (above when there's no room) and
   tracks it from the press that opened it: released over an item, that
   item; released elsewhere, the menu stays open for a click.  The menu
   is shown as -[GSTheme rightMouseDisplay:forEvent:] shows a context
   menu, at a place of the button's: -popUpMenuPositioningItem:atLocation:
   inView: puts nothing on screen in NSWindows95InterfaceStyle, and a
   context menu opens at a point, so it can't keep clear of the button. */
- (void) _showMenuForEvent: (NSEvent *)event
{
  NSMenu *menu = [self menu];
  id delegate;
  NSMenuView *menuView;
  NSWindow *menuWindow;
  NSScreen *screen;
  NSRect buttonRect;

  if (menu == nil || [self window] == nil)
    {
      return;
    }
  menuView = (NSMenuView *)[menu menuRepresentation];
  if ([menuView isKindOfClass: [NSMenuView class]] == NO
      || [menuView isHorizontal])
    {
      return;
    }
  RETAIN(menu);
  [self _setMenuShown: YES];
  buttonRect = [[self window] convertRectToScreen:
                 [self convertRect: [self bounds] toView: nil]];
  delegate = [self _updateMenuForShowing: menu];
  [menu displayTransient];
  menuWindow = [menuView window];
  screen = [[self window] screen];
  if (screen == nil)
    {
      screen = [NSScreen mainScreen];
    }
  [menuWindow setFrameOrigin:
    GSComboButtonMenuOrigin(buttonRect, [menuWindow frame].size,
                            [screen visibleFrame])];
  [menuView mouseDown: event];
  [menu closeTransient];
  [self _restoreMenu: menu delegate: delegate];
  [self _setMenuShown: NO];
  RELEASE(menu);
}

@end

#endif /* GS_HAS_COMBO_BUTTON */
