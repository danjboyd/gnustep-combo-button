/* ComboDemo: NSComboButton's styles and states, under the current theme.

   Copyright (C) 2026 Daniel Boyd

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.
*/

#import <AppKit/AppKit.h>
#import "GSComboButton.h"

@interface Demo : NSObject
{
  NSTextField *status;
  NSInteger refreshes;
}
- (void) run;
@end

@implementation Demo

- (NSMenu *) recentMenu
{
  NSMenu *menu = AUTORELEASE([[NSMenu alloc] initWithTitle: @"Recent"]);

  [menu setDelegate: (id)self];
  return menu;
}

/* Built afresh each time the menu shows, as an app's recent files are. */
- (void) menuNeedsUpdate: (NSMenu *)menu
{
  NSArray *names = [NSArray arrayWithObjects: @"Screenshot 1.png",
    @"Screenshot 2.png", @"Diagram.png", nil];
  NSUInteger i;

  refreshes++;
  [menu removeAllItems];
  for (i = 0; i < [names count]; i++)
    {
      NSMenuItem *item = (NSMenuItem *)[menu addItemWithTitle: [names objectAtIndex: i]
                                         action: @selector(chose:)
                                  keyEquivalent: @""];
      [item setTarget: self];
    }
  [menu addItem: [NSMenuItem separatorItem]];
  [[menu addItemWithTitle: @"Clear Menu" action: @selector(chose:)
            keyEquivalent: @""] setTarget: self];
}

- (void) chose: (id)sender
{
  [status setStringValue: [NSString stringWithFormat:
    @"Menu: %@ (updated %ld times)", [sender title], (long)refreshes]];
}

- (void) acted: (id)sender
{
  [status setStringValue: [NSString stringWithFormat:
    @"Action: %@ (%@)", [sender title],
    [(NSComboButton *)sender style] == NSComboButtonStyleSplit ? @"split" : @"unified"]];
}

/* Two overlapping sheets, 16 points: an icon of the kind toolbars use. */
- (NSImage *) copyImage
{
  NSImage *image = AUTORELEASE([[NSImage alloc] initWithSize: NSMakeSize (16, 16)]);

  [image lockFocus];
  [[NSColor controlTextColor] set];
  NSFrameRectWithWidth (NSMakeRect (5, 1, 10, 11), 1.5);
  NSFrameRectWithWidth (NSMakeRect (1, 5, 10, 10), 1.5);
  [image unlockFocus];
  return image;
}

- (NSComboButton *) addButton: (NSComboButton *)button
                           at: (NSPoint)origin
                         view: (NSView *)view
{
  [button setFrameOrigin: origin];
  [view addSubview: button];
  return button;
}

- (void) run
{
  NSWindow *window;
  NSView *view;
  NSComboButton *button;
  NSImage *image = [self copyImage];

  window = [[NSWindow alloc] initWithContentRect: NSMakeRect (200, 200, 420, 260)
                                       styleMask: NSTitledWindowMask | NSClosableWindowMask
                                         backing: NSBackingStoreBuffered
                                           defer: NO];
  [window setTitle: @"ComboDemo"];
  view = [window contentView];

  [self addButton: [NSComboButton comboButtonWithTitle: @"Open…"
                                                  menu: [self recentMenu]
                                                target: self
                                                action: @selector(acted:)]
               at: NSMakePoint (20, 200) view: view];

  button = [NSComboButton comboButtonWithTitle: @"Copy"
                                         image: image
                                          menu: [self recentMenu]
                                        target: self
                                        action: @selector(acted:)];
  [self addButton: button at: NSMakePoint (180, 200) view: view];

  button = [NSComboButton comboButtonWithTitle: @"Unified"
                                          menu: [self recentMenu]
                                        target: self
                                        action: @selector(acted:)];
  [button setStyle: NSComboButtonStyleUnified];
  [button sizeToFit];
  [self addButton: button at: NSMakePoint (20, 150) view: view];

  button = [NSComboButton comboButtonWithTitle: @"Disabled"
                                          menu: [self recentMenu]
                                        target: self
                                        action: @selector(acted:)];
  [button setEnabled: NO];
  [self addButton: button at: NSMakePoint (180, 150) view: view];

  status = [[NSTextField alloc] initWithFrame: NSMakeRect (20, 20, 380, 24)];
  [status setEditable: NO];
  [status setBordered: NO];
  [status setDrawsBackground: NO];
  [status setStringValue: @"Click a title, or press an arrow."];
  [view addSubview: status];

  [window makeKeyAndOrderFront: nil];
}

@end

int
main (int argc, const char **argv)
{
  CREATE_AUTORELEASE_POOL (pool);
  Demo *demo;

  [NSApplication sharedApplication];
  demo = [Demo new];
  [demo run];
  [NSApp run];
  RELEASE (demo);
  DESTROY (pool);
  return 0;
}
