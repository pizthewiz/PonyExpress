//
//  PonyEpressReceiverTests.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
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

- (void)testDelegateAssignment {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(PEOSCReceiverDelegate)];
    receiver.delegate = mockDelegate;
    STAssertEqualObjects(mockDelegate, receiver.delegate, @"should assign proper delegate");
}

#pragma mark - CONNECTION

- (void)testConnectionFlow {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    BOOL status = [receiver beginListening];
    STAssertTrue(status, @"should report begin listening");
    STAssertTrue(receiver.isListening, @"should report as listening");
    // double connection
    status = [receiver beginListening];
    STAssertFalse(status, @"should report unsuccessful begin listening");
    STAssertTrue(receiver.isListening, @"should report as listening");
    // disconnect
    status = [receiver stopListening];
    STAssertTrue(status, @"should report successful stop listening");
    STAssertFalse(receiver.isListening, @"should report as not listening");
    // double disconnect
    status = [receiver stopListening];
    STAssertFalse(status, @"should report unsuccessful stop listening");
    STAssertFalse(receiver.isListening, @"should report as not listening");
}

- (void)testConnectionOnAPrivledgedPort {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.privledgedPort];
    BOOL status = [receiver beginListening];
    STAssertFalse(status, @"should report unsuccessful begin listening");
    STAssertFalse(receiver.isListening, @"should report as not listening");

    status = [receiver stopListening];
    STAssertFalse(status, @"should report unsuccessful stop listening");
    STAssertFalse(receiver.isListening, @"should report as not listening");
}

- (void)testConnectionOnAnUnprivledgedPort {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    BOOL status = [receiver beginListening];
    STAssertTrue(status, @"should report successful begin listening");
    STAssertTrue(receiver.isListening, @"should report as listening");

    status = [receiver stopListening];
    STAssertTrue(status, @"should report successful stop listening");
    STAssertFalse(receiver.isListening, @"should report as not listening");
}

// TODO - multicast vs unicast makes a difference here
- (void)testConnectionOnAPortInUse {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    BOOL status = [receiver beginListening];
    STAssertTrue(status, @"should report successful begin listening");
    STAssertTrue(receiver.isListening, @"should report as listening");

    PEOSCReceiver* otherReceiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    status = [otherReceiver beginListening];
    STAssertFalse(status, @"should report unsuccessful begin listening");
    STAssertFalse(receiver.isListening, @"should report as not listening");

    // disconnect first
    [receiver stopListening];

    // connect second
    status = [otherReceiver beginListening];
    STAssertTrue(status, @"should report successful begin listening");
    STAssertTrue(otherReceiver.isListening, @"should report as listening");
}

@end
