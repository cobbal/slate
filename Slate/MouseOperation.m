//
//  MouseOperation.m
//  Slate
//
//  Created by Jigish Patel on 10/5/12.
//  Copyright 2011 Jigish Patel. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see http://www.gnu.org/licenses

#import "SlateLogger.h"
#import "ExpressionPoint.h"
#import "StringTokenizer.h"
#import "Constants.h"
#import "JSController.h"
#import <WebKit/WebKit.h>
#import "JSOperation.h"
#import "MouseOperation.h"

@implementation MouseOperation

@synthesize dest;
@synthesize monitor;
@synthesize screenId;

- (id)init {
  self = [super init];
  if (self) {
    [self setDest:[[ExpressionPoint alloc] initWithX:@"" y:@""]];
    [self setMonitor:REF_CURRENT_SCREEN];
    [self setScreenId:-1];
  }
  return self;
}

- (id)initWithDest:(NSString *)dest monitor:(NSString *)mon {
  self = [super init];
  if (self) {
    NSArray *destTokens = [dest componentsSeparatedByString:SEMICOLON];
    if ([destTokens count] == 2) {
      [self setDest:[[ExpressionPoint alloc] initWithX:destTokens[0] y:destTokens[1]]];
    } else {
      destTokens = [dest componentsSeparatedByString:COMMA];
      if ([destTokens count] == 2) {
        [self setDest:[[ExpressionPoint alloc] initWithX:destTokens[0] y:destTokens[1]]];
      } else {
        return nil;
      }
    }
    [self setMonitor:mon];
    [self setScreenId:-1];
  }
  return self;
}

- (id)initWithDestEP:(ExpressionPoint *)dest1 screenId:(NSString *)screen {
  self = [super init];
  if (self) {
    [self setDest:dest];
    [self setMonitor:nil];
    [self setScreenId:screenId];
  }
  return self;
}


- (BOOL)doOperation {
  SlateLogger(@"----------------- Begin Mouse Operation -----------------");
  ScreenWrapper *sw = [[ScreenWrapper alloc] init];
  BOOL success = [self doOperationWithAccessibilityWrapper:nil screenWrapper:sw];
  SlateLogger(@"-----------------  End Mouse Operation  -----------------");
  return success;
}

- (BOOL) doOperationWithAccessibilityWrapper:(AccessibilityWrapper *)aw screenWrapper:(ScreenWrapper *)sw {
  BOOL success = NO;
  [self evalOptionsWithAccessibilityWrapper:aw screenWrapper:sw];
  NSPoint cTopLeft = [aw getCurrentTopLeft];
  NSSize cSize = [aw getCurrentSize];
  NSRect cWindowRect = NSMakeRect(cTopLeft.x, cTopLeft.y, cSize.width, cSize.height);
  NSPoint p = [self getDestWithCurrentWindowRect:cWindowRect screenWrapper:sw];
  success = (CGWarpMouseCursorPosition(p) == kCGErrorSuccess) && success;
  return success;
}

- (NSPoint)getDestWithCurrentWindowRect:(NSRect)cWindowRect screenWrapper:(ScreenWrapper *)sw {
  // If monitor does not exist send back the same origin
  if (monitor != nil) {
    [self setScreenId:[sw getScreenId:monitor windowRect:cWindowRect]];
  }
  if (![sw screenExists:[self screenId]]) return cWindowRect.origin;
  NSDictionary *values = [sw getScreenAndWindowValues:screenId window:cWindowRect newSize:cWindowRect.size];
  return [dest getPointWithDict:values];
}

- (BOOL)testOperation {
  return YES;
}

- (NSArray *)requiredOptions {
  return @[OPT_X, OPT_Y];
}

- (void)parseOption:(NSString *)name value:(id)val {
  // all options should be strings
  if (val == nil) { return; }
  NSString *value = nil;
  if ([val isKindOfClass:[NSString class]]) {
    value = val;
  } else if ([val isKindOfClass:[NSNumber class]]) {
    value = [val stringValue];
  } else {
    @throw([NSException exceptionWithName:[NSString stringWithFormat:@"Invalid %@", name]
                                   reason:[NSString stringWithFormat:@"Invalid %@ '%@'", name, val]
                                 userInfo:nil]);
    return;
  }

  [[self options] setValue:value forKey:name];
  if ([name isEqualToString:OPT_X]) {
    [[self dest] setX:value];
  } else if ([name isEqualToString:OPT_Y]) {
    [[self dest] setY:value];
  } else if ([name isEqualToString:OPT_SCREEN]) {
    [self setMonitor:value];
  }
}

+ (id)mouseOperation {
  return [[MouseOperation alloc] init];
}

+ (id)mouseOperationFromString:(NSString *)mouseOperation {
  // mouse <dest> <optional:monitor>

  NSMutableArray *tokens = [[NSMutableArray alloc] initWithCapacity:10];
  [StringTokenizer tokenize:mouseOperation into:tokens];

  if ([tokens count] < 2) {
    SlateLogger(@"ERROR: Invalid Parameters '%@'", moveOperation);
    @throw([NSException exceptionWithName:@"Invalid Parameters"
                                   reason:[NSString stringWithFormat:
                                           @"Invalid Parameters in '%@'. "
                                           @"Mouse operations require the following format: "
                                           @"'mouse topLeftX;topLeftY [optional:screenNumber]'",
                                           mouseOperation]
                                 userInfo:nil]);
  }

  Operation *op = nil;
  op = [[MouseOperation alloc]
          initWithDest:tokens[1]
          monitor:([tokens count] >= 3 ? tokens[2] : REF_CURRENT_SCREEN)];
  return op;
}

@end
