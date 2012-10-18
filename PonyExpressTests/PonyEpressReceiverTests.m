//
//  PonyEpressReceiverTests.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "PonyEpressReceiverTests.h"
#import "PonyExpressTestHelper.h"
#import "PEOSCReceiver.h"

@interface PonyEpressReceiverTests()
@property (nonatomic) UInt16 unprivledgedPort;
@property (nonatomic) UInt16 privledgedPort;
@end

@implementation PonyEpressReceiverTests

- (void)setUp {
    [super setUp];

    self.privledgedPort = 80;
    self.unprivledgedPort = 31337;
}

- (void)tearDown {
    // TODO - tear down receiver?

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

#pragma mark - LISTEN

- (void)testListeningFlowOnAPrivledgedPort {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.privledgedPort];
    NSError* error;
    BOOL status = [receiver beginListening:&error];
    STAssertFalse(status, @"should report unsuccessful begin listening");
    STAssertNotNil(error, @"should provide error");
    STAssertFalse(receiver.isListening, @"should report as not listening");

    __block BOOL done = NO;
    [receiver stopListeningWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertFalse(success, @"should report unsuccessful stop listening");
        STAssertFalse(receiver.isListening, @"should report as not listening");
        STAssertNotNil(error, @"should provide error");

        done = YES;
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async stop listening failed");
}

- (void)testListeningFlowOnAnUnprivledgedPort {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    NSError* error;
    BOOL status = [receiver beginListening:&error];
    STAssertTrue(status, @"should report successful begin listening");
    STAssertNil(error, @"should not provide error");
    STAssertTrue(receiver.isListening, @"should report as listening");

    __block BOOL done = NO;
    [receiver stopListeningWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertTrue(success, @"should report successful stop listening");
        STAssertFalse(receiver.isListening, @"should report as not listening");
        STAssertNil(error, @"should not provide error");

        done = YES;
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async stop listening failed");
}

// BAD TEST - test doesn't make sense, socket option SO_REUSEPORT enabled, this will NOT fail
- (void)testListenFlowOnAPortInUse {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    __block NSError* error;
    __block BOOL status = [receiver beginListening:&error];
    STAssertTrue(status, @"should report successful begin listening");
    STAssertNil(error, @"should not provide error");
    STAssertTrue(receiver.isListening, @"should report as listening");

    // attempt to connect second
    PEOSCReceiver* otherReceiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    status = [otherReceiver beginListening:&error];
    STAssertFalse(status, @"should report unsuccessful begin listening");
    STAssertNotNil(error, @"should provide error");
    STAssertFalse(otherReceiver.isListening, @"should report as not listening");

    // disconnect first
    __block BOOL done = NO;
    [receiver stopListeningWithCompletionHandler:^(BOOL success, NSError* stopError) {
        STAssertTrue(success, @"should report successful stop listening");
        STAssertFalse(receiver.isListening, @"should report as not listening");
        STAssertNil(stopError, @"should not provide error");

        // re-attempt to connect second
        status = [otherReceiver beginListening:&error];
        STAssertTrue(status, @"should report successful begin listening");
        STAssertNil(error, @"should not provide error");
        STAssertTrue(otherReceiver.isListening, @"should report as listening");

        done = YES;
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async stop listening failed");
}

- (void)testListeningWhileListening {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    NSError* error;
    BOOL status = [receiver beginListening:&error];
    STAssertTrue(status, @"should report successful begin listening");
    STAssertNil(error, @"should not provide error");
    STAssertTrue(receiver.isListening, @"should report as listening");

    status = [receiver beginListening:&error];
    STAssertFalse(status, @"should report unsuccessful begin listening");
    STAssertNotNil(error, @"should provide an error");
    STAssertTrue(receiver.isListening, @"should report as listening");
}

- (void)testStopListeningWhileNotListening {
    __block BOOL done = NO;
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:self.unprivledgedPort];
    [receiver stopListeningWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertFalse(success, @"should report unsuccessful stop listening");
        STAssertFalse(receiver.isListening, @"should report as not listening");
        STAssertNotNil(error, @"should provide error");

        done = YES;
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async stop listening failed");
}

@end
