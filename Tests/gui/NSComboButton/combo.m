/* combo.m: NSComboButton's API, geometry, action, menu, drawing and
   archiving.  Needs a display (a private Xvfb, no window manager needed);
   skips without one.  The menu's own tracking is modal and isn't run
   here: Examples/ComboDemo shows it.

   Copyright (C) 2026 Daniel Boyd

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
*/

#import "Testing.h"
#import <AppKit/AppKit.h>
#import "GSComboButton.h"
#import "GSComboButtonPrivate.h"
#include <stdlib.h>
#include <math.h>
#include <objc/runtime.h>

/* Counts the actions it gets, and the delegate updates. */
@interface Counter : NSObject
{
@public
  int actions;
  int updates;
  id lastSender;
}
- (void) act: (id)sender;
- (void) menuNeedsUpdate: (NSMenu *)menu;
@end

@implementation Counter
- (void) act: (id)sender
{
  actions++;
  lastSender = sender;
}

/* Fills the menu, as a recent files menu does: adding items marks the
   menu changed, which on GNUstep updates it again. */
- (void) menuNeedsUpdate: (NSMenu *)menu
{
  updates++;
  [menu removeAllItems];
  [menu addItemWithTitle: @"First" action: NULL keyEquivalent: @""];
  [menu addItemWithTitle: @"Second" action: NULL keyEquivalent: @""];
  [menu addItemWithTitle: @"Third" action: NULL keyEquivalent: @""];
  /* Changing an item updates the menu on GNUstep (-itemChanged:). */
  [[menu itemAtIndex: 0] setTarget: self];
}
@end

/* A theme with a wider arrow, to show the button asks the theme. */
@interface WideArrowTheme : GSTheme
@end

@implementation WideArrowTheme
- (CGFloat) comboButtonArrowWidth: (NSComboButton *)button
{
  return 40.0;
}
@end

static NSMenu *
threeItemMenu (void)
{
  NSMenu *menu = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Recent"]);

  [menu addItemWithTitle: @"First" action: NULL keyEquivalent: @""];
  [menu addItemWithTitle: @"Second" action: NULL keyEquivalent: @""];
  [menu addItemWithTitle: @"Third" action: NULL keyEquivalent: @""];
  return menu;
}

static NSEvent *
mouseEvent (NSEventType type, NSPoint location, NSWindow *window)
{
  return [NSEvent mouseEventWithType: type
                            location: location
                       modifierFlags: 0
                           timestamp: 0
                        windowNumber: [window windowNumber]
                             context: nil
                         eventNumber: 0
                          clickCount: 1
                            pressure: 1.0];
}

/* The fraction of pixels in rect (in the bitmap's coordinates, origin at
   the top) darker than half. */
static double
darkFraction (NSBitmapImageRep *rep, NSRect rect)
{
  NSInteger x, y, dark = 0, all = 0;

  for (y = (NSInteger)NSMinY(rect); y < (NSInteger)NSMaxY(rect); y++)
    {
      for (x = (NSInteger)NSMinX(rect); x < (NSInteger)NSMaxX(rect); x++)
        {
          NSColor *c = [[rep colorAtX: x y: y]
                         colorUsingColorSpaceName: NSCalibratedWhiteColorSpace];

          all++;
          if (c != nil && [c alphaComponent] > 0.5 && [c whiteComponent] < 0.5)
            {
              dark++;
            }
        }
    }
  return (all > 0 ? (double)dark / (double)all : 0.0);
}

int
main (int argc, char **argv)
{
  CREATE_AUTORELEASE_POOL (pool);

  START_SET ("NSComboButton")
    {
      NSComboButton *button;
      NSComboButton *copy;
      NSWindow *window;
      Counter *counter;
      NSMenu *menu;
      NSImage *image;
      NSRect arrow;
      NSRect title;
      NSSize size;
      NSPoint origin;
      NSBitmapImageRep *rep;
      NSData *data;

      if (getenv ("DISPLAY") == NULL)
        {
          SKIP ("no display")
        }
      NS_DURING
        {
          [NSApplication sharedApplication];
        }
      NS_HANDLER
        {
          SKIP ("no display server")
        }
      NS_ENDHANDLER

      /* Installing. */
      PASS ([NSComboButton respondsToSelector: @selector(_isGSComboButton)],
            "the class is this code's");
      PASS (GSComboButtonInstall (), "installs");
      PASS (GSComboButtonInstall (), "and a second call does nothing more");
      PASS ([[GSTheme theme] respondsToSelector:
               @selector(drawComboButtonBezel:frame:part:state:)]
            && [[GSTheme theme] respondsToSelector:
                  @selector(drawComboButtonArrow:frame:state:)]
            && [[GSTheme theme] respondsToSelector:
                  @selector(comboButtonArrowWidth:)],
            "GSTheme has the default drawing");

      /* Constructors and defaults. */
      counter = AUTORELEASE([Counter new]);
      menu = threeItemMenu ();
      button = [NSComboButton comboButtonWithTitle: @"Open…"
                                              menu: menu
                                            target: counter
                                            action: @selector(act:)];
      PASS_EQUAL ([button title], @"Open…", "the title");
      PASS ([button menu] == menu, "the menu");
      PASS ([button target] == counter && [button action] == @selector(act:),
            "the target and action");
      PASS ([button style] == NSComboButtonStyleSplit, "split by default");
      PASS ([button imageScaling] == NSImageScaleProportionallyDown,
            "scaled proportionally down by default");
      PASS ([button image] == nil, "no image");
      PASS ([button isEnabled], "enabled");
      size = [button frame].size;
      PASS (size.width > [[button _labelCell] cellSize].width + 23.0
            && size.height > 0.0,
            "sized to fit the title and the arrow (%gx%g)",
            size.width, size.height);
      PASS (NSEqualSizes ([button intrinsicContentSize], size)
            && NSEqualSizes ([button fittingSize], size),
            "its intrinsic and fitting size");

      [button setTitle: nil];
      PASS_EQUAL ([button title], @"", "a nil title is an empty one");
      [button setTitle: @"Open…"];

      image = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize (16, 16)]);
      PASS ([[NSComboButton comboButtonWithImage: image menu: menu
                                          target: nil action: NULL] image]
            == image,
            "comboButtonWithImage: shows the image");
      PASS ([[[NSComboButton comboButtonWithImage: image menu: menu
                                           target: nil action: NULL]
               _labelCell] imagePosition] == NSImageOnly,
            "an image alone, with no title");
      PASS ([[[NSComboButton comboButtonWithTitle: @"Copy" image: image
                                             menu: menu target: nil
                                           action: NULL]
               _labelCell] imagePosition] == NSImageLeft,
            "an image before the title");

      /* The parts. */
      [button setFrame: NSMakeRect (20, 20, 150, 32)];
      arrow = [button _arrowRect];
      title = [button _titleRect];
      PASS (NSEqualRects (arrow, NSMakeRect (126, 0, 24, 32)),
            "split: the arrow part at the right, 24 wide");
      PASS (NSEqualRects (title, NSMakeRect (0, 0, 126, 32)),
            "the title in the rest");
      PASS ([button _partAtPoint: NSMakePoint (140, 16)] == GSComboButtonArrowPart
            && [button _partAtPoint: NSMakePoint (40, 16)] == GSComboButtonMainPart,
            "a press goes to the part it's on");
      [button setStyle: NSComboButtonStyleUnified];
      PASS (NSWidth ([button _arrowRect]) == 18.0
            && [button _partAtPoint: NSMakePoint (140, 16)] == GSComboButtonMainPart,
            "unified: an 18 wide arrow, and one part");
      [button setStyle: NSComboButtonStyleSplit];
      [button setFrameSize: NSMakeSize (40, 32)];
      PASS (NSIsEmptyRect ([button _arrowRect]),
            "no arrow where the title wouldn't fit");
      [button setFrame: NSMakeRect (20, 20, 150, 32)];

      /* The theme decides the arrow's width. */
      {
        GSTheme *old = RETAIN([GSTheme theme]);
        GSTheme *wide = AUTORELEASE([[WideArrowTheme alloc] initWithBundle: nil]);

        [GSTheme setTheme: wide];
        PASS (NSWidth ([button _arrowRect]) == 40.0,
              "a theme's -comboButtonArrowWidth: wins over the default");
        [GSTheme setTheme: old];
        RELEASE(old);
        PASS (NSWidth ([button _arrowRect]) == 24.0,
              "and the default again with the theme before it");
      }

      /* The action. */
      [button performClick: nil];
      PASS (counter->actions == 1 && counter->lastSender == button,
            "-performClick: sends the action, from the button");
      [button setEnabled: NO];
      [button performClick: nil];
      PASS (counter->actions == 1, "but not when disabled");
      [button setEnabled: YES];

      window = [[NSWindow alloc] initWithContentRect: NSMakeRect (100, 100, 300, 120)
                                           styleMask: NSTitledWindowMask
                                             backing: NSBackingStoreBuffered
                                               defer: NO];
      [[window contentView] addSubview: button];
      [window orderFront: nil];
      {
        NSPoint inside = [button convertPoint: NSMakePoint (40, 16) toView: nil];
        NSPoint outside = [button convertPoint: NSMakePoint (40, 200) toView: nil];

        /* A press tracks until its release, which comes from the queue. */
        [NSApp postEvent: mouseEvent (NSLeftMouseUp, inside, window) atStart: NO];
        [button mouseDown: mouseEvent (NSLeftMouseDown, inside, window)];
        PASS (counter->actions == 2 && [button _isMainHighlighted] == NO,
              "a click on the title part sends the action");

        [NSApp postEvent: mouseEvent (NSLeftMouseUp, outside, window) atStart: NO];
        [button mouseDown: mouseEvent (NSLeftMouseDown, inside, window)];
        PASS (counter->actions == 2,
              "released off the button, it doesn't");

        [button setStyle: NSComboButtonStyleUnified];
        [NSApp postEvent: mouseEvent (NSLeftMouseUp, inside, window) atStart: NO];
        [button mouseDown: mouseEvent (NSLeftMouseDown, inside, window)];
        PASS (counter->actions == 3,
              "unified: a quick click sends the action");
        [button setStyle: NSComboButtonStyleSplit];

        [button setEnabled: NO];
        [button mouseDown: mouseEvent (NSLeftMouseDown, inside, window)];
        PASS (counter->actions == 3 && [button _isMainHighlighted] == NO,
              "disabled, a press does nothing (and doesn't wait for a release)");
        [button setEnabled: YES];
      }

      /* As AppKit's: the arrow part needs menu items, a split button's
         title part an action; a unified button without an action shows its
         menu on the press; and the button has no context menu. */
      {
        NSComboButton *b = [NSComboButton comboButtonWithTitle: @"T"
                                                          menu: AUTORELEASE([[NSMenu alloc] initWithTitle: @"Empty"])
                                                        target: counter
                                                        action: @selector(act:)];
        int before = counter->actions;

        PASS ([b _isMainPartEnabled] && [b _isMenuPartEnabled] == NO,
              "an empty menu disables the arrow part only");
        [b setMenu: threeItemMenu ()];
        PASS ([b _isMenuPartEnabled], "items enable it");
        [b setAction: NULL];
        PASS ([b _isMainPartEnabled] == NO && [[b _labelCell] isEnabled] == NO,
              "split, without an action: the title part is disabled, and drawn so");
        [b performClick: nil];
        PASS (counter->actions == before, "and -performClick: does nothing");
        [b setStyle: NSComboButtonStyleUnified];
        PASS ([b _isMainPartEnabled],
              "unified, without an action: one part, which shows the menu");
        PASS ([b menuForEvent: mouseEvent (NSRightMouseDown, NSMakePoint (5, 5), nil)] == nil
              && [b menu] != nil,
              "no context menu, though it has a menu");
        [b setEnabled: NO];
        PASS ([b _isMainPartEnabled] == NO && [b _isMenuPartEnabled] == NO,
              "disabled, neither part");
      }

      /* The menu: its delegate fills it once each time it shows. */
      [menu setDelegate: (id)counter];
      {
        id detached = [button _updateMenuForShowing: menu];

        PASS (detached == counter && [menu delegate] == nil,
              "the delegate is detached while the menu shows");
        [menu displayTransient];
        [menu closeTransient];
        [button _restoreMenu: menu delegate: detached];
      }
      PASS (counter->updates == 1 && [menu numberOfItems] == 3,
            "it fills the menu once, as on macOS (%d times)", counter->updates);
      PASS ([menu delegate] == (id)counter, "and is put back after");

      /* Where the menu opens. */
      origin = GSComboButtonMenuOrigin (NSMakeRect (100, 500, 150, 32),
                                        NSMakeSize (200, 120),
                                        NSMakeRect (0, 0, 1000, 800));
      PASS (NSEqualPoints (origin, NSMakePoint (100, 378)),
            "below the button, the left edges lined up");
      origin = GSComboButtonMenuOrigin (NSMakeRect (100, 50, 150, 32),
                                        NSMakeSize (200, 120),
                                        NSMakeRect (0, 0, 1000, 800));
      PASS (NSEqualPoints (origin, NSMakePoint (100, 84)),
            "above it when there's no room below");
      origin = GSComboButtonMenuOrigin (NSMakeRect (900, 500, 150, 32),
                                        NSMakeSize (200, 120),
                                        NSMakeRect (0, 0, 1000, 800));
      PASS (origin.x == 800.0, "moved left to stay on the screen");

      /* The drawing: the theme's arrow and divider are on it. */
      {
        NSComboButton *drawn = [NSComboButton comboButtonWithTitle: @"Open"
                                                              menu: nil
                                                            target: nil
                                                            action: NULL];

        NSImage *canvas;

        /* Drawn into an image, the way the window would draw it. */
        [drawn setFrame: NSMakeRect (0, 0, 150, 32)];
        canvas = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize (150, 32)]);
        [canvas lockFocus];
        [[NSColor windowBackgroundColor] set];
        NSRectFill (NSMakeRect (0, 0, 150, 32));
        [drawn drawRect: [drawn bounds]];
        [canvas unlockFocus];
        rep = [NSBitmapImageRep imageRepWithData: [canvas TIFFRepresentation]];
      }
      PASS (rep != nil
            && darkFraction (rep, NSMakeRect (126 + 6, 10, 10, 12)) > 0.05,
            "the arrow is drawn in the arrow part");
      {
        NSColor *divider = [[rep colorAtX: 126 y: 16]
                             colorUsingColorSpaceName: NSCalibratedWhiteColorSpace];
        NSColor *beside = [[rep colorAtX: 122 y: 16]
                            colorUsingColorSpaceName: NSCalibratedWhiteColorSpace];

        PASS (fabs ([divider whiteComponent] - [beside whiteComponent]) > 0.05,
              "and the divider before it (%g beside %g)",
              [divider whiteComponent], [beside whiteComponent]);
      }

      /* Archiving (with a menu of plain items: the delegate made the
         test's Counter a target, and it can't be archived). */
      [button setMenu: threeItemMenu ()];
      [button setImage: image];
      [button setStyle: NSComboButtonStyleUnified];
      [button setImageScaling: NSImageScaleNone];
      NS_DURING
        {
          data = [NSKeyedArchiver archivedDataWithRootObject: button];
        }
      NS_HANDLER
        {
          NSLog (@"keyed archiving: %@", localException);
          data = nil;
        }
      NS_ENDHANDLER
      copy = [NSKeyedUnarchiver unarchiveObjectWithData: data];
      PASS ([copy isKindOfClass: [NSComboButton class]], "keyed: a combo button");
      PASS_EQUAL ([copy title], [button title], "keyed: the title");
      PASS ([copy style] == NSComboButtonStyleUnified, "keyed: the style");
      PASS ([copy imageScaling] == NSImageScaleNone, "keyed: the image scaling");
      PASS ([copy image] != nil, "keyed: the image");
      PASS (sel_isEqual ([copy action], @selector(act:)), "keyed: the action");
      PASS ([copy isEnabled], "keyed: enabled");
      PASS ([[copy menu] numberOfItems] == 3, "keyed: the menu");
      data = [NSArchiver archivedDataWithRootObject: button];
      copy = [NSUnarchiver unarchiveObjectWithData: data];
      PASS ([copy isKindOfClass: [NSComboButton class]], "non-keyed: a combo button");
      PASS_EQUAL ([copy title], [button title], "non-keyed: the title");
      PASS ([copy style] == NSComboButtonStyleUnified
            && [copy imageScaling] == NSImageScaleNone,
            "non-keyed: the style and image scaling");
      PASS (sel_isEqual ([copy action], @selector(act:)), "non-keyed: the action");
      PASS ([[copy menu] numberOfItems] == 3, "non-keyed: the menu");

      [window orderOut: nil];
      RELEASE(window);
    }
  END_SET ("NSComboButton")

  DESTROY (pool);
  return 0;
}
