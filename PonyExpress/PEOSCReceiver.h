//
//  PEOSCReceiver.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEOSCMessage.h"
#import "PEOSCBundle.h"

extern NSString* const PEOSCReceiverErrorDomain;

typedef enum PEOSCReceiverError : NSInteger {
    PEOSCReceiverNoError = 0,
    PEOSCReceiverAlreadyListeningError,
    PEOSCReceiverNotListeningError,
    PEOSCReceiverOtherError,
} PEOSCReceiverError;

typedef void(^PEOSCReceiverCompletionHandler)(BOOL success, NSError* error);

@protocol PEOSCReceiverDelegate
- (void)didReceiveMessage:(PEOSCMessage*)message;
- (void)didReceiveBundle:(PEOSCBundle*)bundle;
@end

@interface PEOSCReceiver : NSObject
+ (instancetype)receiverWithPort:(UInt16)port;
- (instancetype)initWithPort:(UInt16)port;

@property (nonatomic, readonly) UInt16 port;
@property (nonatomic, weak) id <PEOSCReceiverDelegate> delegate;
@property (nonatomic, readonly, getter = isListening) BOOL listening;

- (BOOL)beginListening:(NSError**)error;
- (void)stopListeningWithCompletionHandler:(PEOSCReceiverCompletionHandler)handler;
@end
