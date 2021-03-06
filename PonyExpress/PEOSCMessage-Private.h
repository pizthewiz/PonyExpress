//
//  PEOSCMessage-Private.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 02 Sept 2011.
//  Copyright (c) 2011-2014 Chorded Constructions. All rights reserved.
//

#import "PEOSCMessage.h"

@interface PEOSCMessage ()
+ (instancetype)messageWithData:(NSData*)data remoteHost:(NSString*)host remotePort:(uint16_t)port;
- (instancetype)initWithData:(NSData*)data remoteHost:(NSString*)host remotePort:(uint16_t)port;

@property (nonatomic, readwrite, strong) NSString* remoteHost;
@property (nonatomic, readwrite) uint16_t remotePort;

+ (NSString*)_codeForType:(NSString*)type;
+ (NSString*)_typeForCode:(NSString*)type;

- (BOOL)_isValid;
- (BOOL)_isAddressValid;
- (BOOL)_areTypeTagsValid;
- (BOOL)_areArgumentsValidGivenTypeTags;
- (NSString*)_typeTagString;
- (NSData*)_data;
@end
