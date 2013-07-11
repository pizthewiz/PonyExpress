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
// NB - for bundles to send, when the timeTag is nil, it will default to immediate
//  for bundles received, the timeTag is ignored and treated as immediate
+ (instancetype)bundleWithElements:(NSArray*)elements timeTag:(NSDate*)timeTag;
- (instancetype)initWithElements:(NSArray*)elements timeTag:(NSDate*)timeTag;

@property (nonatomic, strong) NSArray* elements; // could be a mix of messages and bundles
@property (nonatomic, strong) NSDate* timeTag;
@end
