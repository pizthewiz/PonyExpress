//
//  PEOSCBundle-Private.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 24 Mar 2013.
//  Copyright (c) 2013-2014 Chorded Constructions. All rights reserved.
//

#import "PEOSCBundle.h"

@interface PEOSCBundle ()
+ (instancetype)bundleWithData:(NSData*)data remoteHost:(NSString*)host remotePort:(uint16_t)port;
- (instancetype)initWithData:(NSData*)data remoteHost:(NSString*)host remotePort:(uint16_t)port;

@property (nonatomic, readwrite, strong) NSString* remoteHost;
@property (nonatomic, readwrite) uint16_t remotePort;

+ (BOOL)_dataIsLikelyBundle:(NSData*)data;
- (BOOL)_isValid;
- (BOOL)_areElementsValid;
- (NSData*)_data;
@end
