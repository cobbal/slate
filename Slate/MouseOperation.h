//
//  MouseOperation.h
//  Slate
//
//  Created by Andrew Cobb on 07/27/19
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

#import "Operation.h"

@class ExpressionPoint;

@interface MouseOperation : Operation {
    ExpressionPoint *dest;
}

@property ExpressionPoint *dest;
@property NSString *monitor;
@property NSInteger screenId;

- (id)initWithDest:(ExpressionPoint *)dest monitor:(NSString*)mon;
- (id)initWithDestEP:(ExpressionPoint *)dest screenId:(NSString*)screen;

+ (id) mouseOperation;
+ (id) mouseOperationFromString:(NSString *)mouseOperation;

@end
