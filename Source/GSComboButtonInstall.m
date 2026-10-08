/** <title>GSComboButtonInstall</title>

   <abstract>Adds GSTheme's default drawing of NSComboButton.</abstract>

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

/* Upstream this file goes away: libs-gui's GSTheme has the methods. */

#import "GSComboButtonPrivate.h"
#include <stdlib.h>

#ifndef GS_HAS_COMBO_BUTTON
#include <objc/runtime.h>

static BOOL installed = NO;

/* Adds donor's methods to target where target has none of that name:
   donor is a subclass of target written only to hold them. */
static void
GSComboButtonAddMissingMethods(Class donor, Class target)
{
  unsigned int count = 0;
  unsigned int i;
  Method *methods = class_copyMethodList(donor, &count);

  for (i = 0; i < count; i++)
    {
      SEL selector = method_getName(methods[i]);

      if (class_getInstanceMethod(target, selector) == NULL)
        {
          class_addMethod(target, selector,
                          method_getImplementation(methods[i]),
                          method_getTypeEncoding(methods[i]));
        }
    }
  free(methods);
}
#endif /* GS_HAS_COMBO_BUTTON */

BOOL
GSComboButtonInstall(void)
{
#ifdef GS_HAS_COMBO_BUTTON
  return NO;
#else /* not GS_HAS_COMBO_BUTTON */
  Class button = NSClassFromString(@"NSComboButton");

  if (installed)
    {
      return YES;
    }
  /* libs-gui's own class (or another copy's, loaded first, which
     installs its own drawing) keeps the name: nothing to do. */
  if (button == Nil
      || [button respondsToSelector: @selector(_isGSComboButton)] == NO)
    {
      return NO;
    }
  installed = YES;
  GSComboButtonAddMissingMethods([GSComboButtonTheme class], [GSTheme class]);
  return YES;
#endif /* GS_HAS_COMBO_BUTTON */
}
