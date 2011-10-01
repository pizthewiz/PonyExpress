//
//  PEOSCMessage-Private.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEOSCMessage.h"

@interface PEOSCMessage()
+ (id)messageWithData:(NSData*)data;
- (id)initWithData:(NSData*)data;

+ (NSString*)_codeForType:(NSString*)type;
+ (NSString*)_typeForCode:(NSString*)type;

- (BOOL)_isAddressValid;
- (BOOL)_areTypeTagsValid;
- (BOOL)_areArgumentsValidGivenTypeTags;
- (NSString*)_typeTagString;
- (NSData*)_data;
@end
