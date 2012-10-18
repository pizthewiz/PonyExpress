//
//  PEOSCSender.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEOSCMessage.h"

extern NSString* const PEOSCSenderErrorDomain;

typedef enum PEOSCSenderError : NSInteger {
    PEOSCSenderNoError = 0,
    PEOSCSenderAlreadyConnectedError,
    PEOSCSenderNotConnectedError,
    PEOSCSenderOtherError,
} PEOSCSenderError;

typedef void(^PEOSCSenderConnectCompletionHandler)(BOOL success, NSError* error);
typedef void(^PEOSCSenderDisconnectCompletionHandler)(BOOL success, NSError* error);

@protocol PEOSCSenderDelegate
- (void)didSendMessage:(PEOSCMessage*)message;
- (void)didNotSendMessage:(PEOSCMessage*)message dueToError:(NSError*)error;
@end

@interface PEOSCSender : NSObject
+ (id)senderWithHost:(NSString*)host port:(UInt16)port;
- (id)initWithHost:(NSString*)host port:(UInt16)port;

@property (nonatomic, readonly, strong) NSString* host;
@property (nonatomic, readonly) UInt16 port;
@property (nonatomic, readonly, getter = isConnected) BOOL connected;
@property (nonatomic, weak) id <PEOSCSenderDelegate> delegate;

- (void)connectWithCompletionHandler:(PEOSCSenderConnectCompletionHandler)handler;
- (void)disconnectWithCompletionHandler:(PEOSCSenderDisconnectCompletionHandler)handler;

- (void)sendMessage:(PEOSCMessage*)message;
@end
