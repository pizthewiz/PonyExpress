//
//  PEOSCSender.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 02 Sept 2011.
//  Copyright (c) 2011-2013 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEOSCMessage.h"
#import "PEOSCBundle.h"

extern NSString* const PEOSCSenderErrorDomain;

typedef enum PEOSCSenderError : NSInteger {
    PEOSCSenderNoError = 0,
    PEOSCSenderOtherError,
} PEOSCSenderError;

typedef void(^PEOSCSenderCompletionHandler)(BOOL success, NSError* error);

@interface PEOSCSender : NSObject
+ (instancetype)senderWithHost:(NSString*)host port:(UInt16)port;
- (instancetype)initWithHost:(NSString*)host port:(UInt16)port;

@property (nonatomic, readonly, strong) NSString* host;
@property (nonatomic, readonly) UInt16 port;

- (void)sendMessage:(PEOSCMessage*)message handler:(PEOSCSenderCompletionHandler)handler;
- (void)sendBundle:(PEOSCBundle*)bundle handler:(PEOSCSenderCompletionHandler)handler;
@end
