//
//  PEOSCBundle.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 24 Mar 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEOSCMessage.h"

@interface PEOSCBundle : NSObject
+ (instancetype)bundleWithMessages:(NSArray*)messages;
- (instancetype)initWithMessages:(NSArray*)messages;

@property (nonatomic, strong) NSArray* messages;
@end
