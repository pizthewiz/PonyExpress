//
//  PEOSCBundle-Private.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 24 Mar 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCBundle.h"

@interface PEOSCBundle ()
+ (instancetype)bundleWithData:(NSData*)data;
- (instancetype)initWithData:(NSData*)data;

+ (BOOL)_dataIsLikelyBundle:(NSData*)data;
- (BOOL)_isValid;
- (BOOL)_areElementsValid;
- (NSData*)_data;
@end
