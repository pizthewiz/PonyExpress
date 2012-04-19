//
//  PEOSCReceiver.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PEOSCReceiverStopListeningCompletionHandler)(BOOL success, NSError* error);

@class PEOSCMessage;

@protocol PEOSCReceiverDelegate
- (void)didReceiveMessage:(PEOSCMessage*)message;
@end

@interface PEOSCReceiver : NSObject
+ (id)receiverWithPort:(UInt16)port;
- (id)initWithPort:(UInt16)port;

@property (nonatomic, readonly) UInt16 port;
@property (nonatomic, weak) id <PEOSCReceiverDelegate> delegate;
@property (nonatomic, readonly, getter = isListening) BOOL listening;

- (BOOL)beginListening;
- (void)stopListeningWithCompletionHandler:(PEOSCReceiverStopListeningCompletionHandler)handler;
@end
