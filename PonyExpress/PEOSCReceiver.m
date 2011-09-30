//
//  PEOSCReceiver.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEOSCReceiver.h"
#import "PEOSCMessage.h"

@interface PEOSCReceiver()
@property (nonatomic, readwrite) UInt16 port;
@end

@implementation PEOSCReceiver

@synthesize port;

+ (id)receiverWithPort:(UInt16)port {
    PEOSCReceiver* receiver = [[PEOSCReceiver alloc] initWithPort:port];
    return receiver;
}

- (id)initWithPort:(UInt16)por {
    self = [super init];
    if (self) {
        self.port = por;

//        [self _setupSocket];
    }
    return self;
}

@end
