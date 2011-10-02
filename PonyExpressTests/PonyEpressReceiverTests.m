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

- (void)testPortAssignment {
    UInt16 goodPort = 8000;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:goodPort];
    STAssertEquals(goodPort, receiver.port, @"should store port");
}

- (void)testConnectionFlow {
    UInt16 goodPort = 8000;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:goodPort];
    BOOL status = [receiver connect];
    STAssertTrue(status, @"should report successful connection");
    STAssertTrue(receiver.isConnected, @"should report as connected");
    // double connection
    status = [receiver connect];
    STAssertFalse(status, @"should report unsuccessful connection");
    STAssertTrue(receiver.isConnected, @"should report as connected");
    // disconnect
    status = [receiver disconnect];
    STAssertTrue(status, @"should report successful disconnection");
    STAssertFalse(receiver.isConnected, @"should report as disconnected");
    // double disconnect
    status = [receiver disconnect];
    STAssertFalse(status, @"should report unsuccessful disconnection");
    STAssertFalse(receiver.isConnected, @"should report as disconnected");
}

- (void)testConnectingToAPrivledgedPort {
    UInt16 badPort = 80;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:badPort];
    BOOL status = [receiver connect];
    STAssertFalse(status, @"should report unsuccessful connection");
    STAssertFalse(receiver.isConnected, @"should report as disconnected");
}

- (void)testConnectingToAPortInUse {
    // TODO - need to somehow spin up something on port 9999
    UInt16 inUsePort = 9999;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:inUsePort];
    BOOL status = [receiver connect];
    STAssertFalse(status, @"should report unsuccessful connection");
    STAssertFalse(receiver.isConnected, @"should report as disconnected");
}

/*
- (void)testDelegateAssignment {
    UInt16 goodPort = 8000;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:goodPort];
    receiver.delegate = self;
    STAssertEqualObjects(receiver.delegate, self, @"should");
}
*/

// TODO - functional test receiver

@end
