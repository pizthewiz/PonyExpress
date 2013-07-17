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
// NB - timeTag is always treated as immediate
+ (instancetype)bundleWithElements:(NSArray*)elements;
- (instancetype)initWithElements:(NSArray*)elements;

@property (nonatomic, strong) NSArray* elements; // could be a mix of messages and bundles
@end
