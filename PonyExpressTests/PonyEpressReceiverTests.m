//
//  PonyEpressReceiverTests.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PonyEpressReceiverTests.h"
#import "PEOSCReceiver.h"

@interface PonyEpressReceiverTests()
@property (nonatomic) UInt16 unprivledgedPort;
@property (nonatomic) UInt16 privledgedPort;
@end

@implementation PonyEpressReceiverTests

@synthesize unprivledgedPort, privledgedPort;

- (void)setUp {
    [super setUp];

    self.privledgedPort = 80;
    self.unprivledgedPort = 31337;
}

- (void)tearDown {
    // Tear-down code here.

    [super tearDown];
}

#pragma mark -

- (void)testCreation {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    STAssertNotNil(receiver, @"should provide class initializer");

    receiver = [[PEOSCReceiver alloc] initWithPort:self.unprivledgedPort];
    STAssertNotNil(receiver, @"should provide alloc/init initializer");
}

- (void)testPortAssignment {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    STAssertEquals(self.unprivledgedPort, receiver.port, @"should store port");
}

/*
- (void)testDelegateAssignment {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(PEOSCReceiverDelegate)];
    receiver.delegate = mockDelegate;
    STAssertEqualObjects(mockDelegate, receiver.delegate, @"should assign proper delegate");
}
*/

#pragma mark - CONNECTION

- (void)testConnectionFlow {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
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

- (void)testConnectionOnAPrivledgedPort {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.privledgedPort];
    BOOL status = [receiver connect];
    STAssertFalse(status, @"should report unsuccessful connection");
    STAssertFalse(receiver.isConnected, @"should report as disconnected");

    status = [receiver disconnect];
    STAssertFalse(status, @"should report unsuccessful disconnection");
    STAssertFalse(receiver.isConnected, @"should report as disconnected");
}

- (void)testConnectionOnAnUnprivledgedPort {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    BOOL status = [receiver connect];
    STAssertTrue(status, @"should report successful connection");
    STAssertTrue(receiver.isConnected, @"should report as connected");

    status = [receiver disconnect];
    STAssertTrue(status, @"should report successful disconnection");
    STAssertFalse(receiver.isConnected, @"should report as disconnected");
}

- (void)testConnectionOnAPortInUse {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    BOOL status = [receiver connect];
    STAssertTrue(status, @"should report successful connection");
    STAssertTrue(receiver.isConnected, @"should report as connected");

    PEOSCReceiver* otherReceiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    status = [otherReceiver connect];
    STAssertFalse(status, @"should report unsuccessful connection");
    STAssertFalse(receiver.isConnected, @"should report as disconnected");

    // disconnect first
    [receiver disconnect];

    // connect second
    status = [otherReceiver connect];
    STAssertTrue(status, @"should report successful connection");
    STAssertTrue(otherReceiver.isConnected, @"should report as connected");
}

@end
