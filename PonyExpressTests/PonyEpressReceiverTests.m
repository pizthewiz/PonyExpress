//
//  PonyEpressReceiverTests.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PonyEpressReceiverTests.h"
#import "PEOSCReceiver.h"

@implementation PonyEpressReceiverTests

- (void)setUp {
    [super setUp];

    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.

    [super tearDown];
}

#pragma mark -

- (void)testCreation {
    UInt16 port = 31337;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:port];
    STAssertNotNil(receiver, @"should provide class initializer");

    receiver = [[PEOSCReceiver alloc] initWithPort:port];
    STAssertNotNil(receiver, @"should provide alloc/init initializer");
}

- (void)testPortStorage {
    UInt16 goodPort = 8000;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:goodPort];
    STAssertEquals(goodPort, receiver.port, @"should store port");
}

- (void)testPrivledgedPort {
    UInt16 badPort = 80;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:badPort];
    STAssertNil(receiver, @"should not create receiver with privledged port");
    // TODO - probably cannot test until connect
}

- (void)testPortInUse {
    UInt16 inUsePort = 8888;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:inUsePort];
    STAssertNil(receiver, @"should not create receiver on in use port");
    // TODO - probably cannot test until connect
}

@end
