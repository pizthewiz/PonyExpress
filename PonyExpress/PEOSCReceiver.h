//
//  PEOSCReceiver.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PEOSCMessage;

@protocol PEOSCReceiverDelegate
- (void)didReceiveMessage:(PEOSCMessage*)message;
@end

@interface PEOSCReceiver : NSObject
+ (id)receiverWithPort:(UInt16)port;
- (id)initWithPort:(UInt16)port;

@property (nonatomic, readonly) UInt16 port;
@property (nonatomic, weak) id <PEOSCReceiverDelegate> delegate;
@property (nonatomic, readonly, getter = isConnected) BOOL connected;

- (BOOL)connect;
- (BOOL)disconnect;
@end
