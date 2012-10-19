//
//  PonyExpressSenderTests.m
//  PonyExpressSenderTests
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "PonyExpressSenderTests.h"
#import "PonyExpressTestHelper.h"
#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "PEOSCSender.h"

@interface PonyExpressSenderTests()
@property (nonatomic, strong) NSString* loopbackHost;
@property (nonatomic) UInt16 unprivledgedPort;
@property (nonatomic) UInt16 privledgedPort;
@end

@implementation PonyExpressSenderTests

- (void)setUp {
    [super setUp];

    self.loopbackHost = @"127.0.0.1";

    self.privledgedPort = 80;
    self.unprivledgedPort = 31337;
}

- (void)tearDown {
    // TODO - senders should disconnect?

    [super tearDown];
}

#pragma mark -

- (void)testCreation {
    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    STAssertNotNil(sender, @"should provide instance from class initializer");

    sender = [[PEOSCSender alloc] initWithHost:self.loopbackHost port:self.unprivledgedPort];
    STAssertNotNil(sender, @"should provide instance from default initializer");
}

- (void)testHostAndPortAssignment {
    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    STAssertEqualObjects(self.loopbackHost, sender.host, @"should store proper host");
    STAssertEquals(self.unprivledgedPort, sender.port, @"should store port");
}

- (void)testDelegateAssignment {
    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    id mockDelegate = [OCMockObject mockForProtocol:@protocol(PEOSCSenderDelegate)];
    sender.delegate = mockDelegate;
    STAssertEqualObjects(mockDelegate, sender.delegate, @"should assign proper delegate");
}

#pragma mark - CONNECTION

- (void)testConnectionToGoodHost {
    __block BOOL done = NO;

    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    [sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertTrue(success, @"should report successful connection");
        STAssertTrue(sender.isConnected, @"should report as connected");
        STAssertNil(error, @"should not provide error");

        done = YES;
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async connect failed");
}

// BAD TEST - a bad host usually does not error out until later on, this will NOT fail
- (void)testConnectionToBadHost {
    __block BOOL done = NO;

    PEOSCSender* sender = [PEOSCSender senderWithHost:@"log lady" port:self.unprivledgedPort];
    [sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertFalse(success, @"should report unsuccessful connection");
        STAssertFalse(sender.isConnected, @"should report as disconnected");
        STAssertNotNil(error, @"should provide error");

        done = YES;
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async connect failed");
}

- (void)testConnectionFlowOnAPrivledgedPort {
    __block BOOL done = NO;

    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.privledgedPort];
    [sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertTrue(success, @"should report successful connection");
        STAssertTrue(sender.isConnected, @"should report as connected");
        STAssertNil(error, @"should not have an error");

        [sender disconnectWithCompletionHandler:^(BOOL success, NSError* error) {
            STAssertTrue(success, @"should report successful disconnection");
            STAssertFalse(sender.isConnected, @"should report as disconnected");
            STAssertNil(error, @"should not have an error");

            done = YES;
        }];
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async connect / disconnect failed");
}

- (void)testConnectionFlowOnAnUnprivledgedPort {
    __block BOOL done = NO;

    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    [sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertTrue(success, @"should report successful connection");
        STAssertTrue(sender.isConnected, @"should report as connected");
        STAssertNil(error, @"should not have an error");

        [sender disconnectWithCompletionHandler:^(BOOL success, NSError* error) {
            STAssertTrue(success, @"should report successful disconnection");
            STAssertFalse(sender.isConnected, @"should report as disconnected");
            STAssertNil(error, @"should not have an error");

            done = YES;
        }];
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async connect / disconnect failed");
}

- (void)testConnectionToAConnectedPort {
    __block BOOL done = NO;

    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    [sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertTrue(success, @"should report successful connection");
        STAssertTrue(sender.isConnected, @"should report as connected");
        STAssertNil(error, @"should not have an error");

        // NB - multiple connections to host:port is allowed
        PEOSCSender* otherSender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
        [otherSender connectWithCompletionHandler:^(BOOL success, NSError* error) {
            STAssertTrue(success, @"should report successful connection");
            STAssertTrue(otherSender.isConnected, @"should report as connected");
            STAssertNil(error, @"should not have an error");

            done = YES;
        }];
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async connect / connect failed");
}

- (void)testConnectWhileConnected {
    __block BOOL done = NO;

    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    [sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertTrue(success, @"should report successful connection");
        STAssertTrue(sender.isConnected, @"should report as connected");
        STAssertNil(error, @"should not have an error");

        // double connect attempt
        [sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
            STAssertFalse(success, @"should report unsuccessful connection");
            STAssertNotNil(error, @"should have an error");
            STAssertEquals(error.code, PEOSCSenderAlreadyConnectedError, @"should provide already connected error");
            STAssertTrue(sender.isConnected, @"should report as connected");

            done = YES;
        }];
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async connect failed");
}

- (void)testDisconnectWhileDisconnected {
    __block BOOL done = NO;

    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    [sender disconnectWithCompletionHandler:^(BOOL success, NSError* error) {
        STAssertFalse(success, @"should report unsuccessful disconnection");
        STAssertNotNil(error, @"should have an error");
        STAssertEquals(error.code, PEOSCSenderNotConnectedError, @"should provide not connected error");
        STAssertFalse(sender.isConnected, @"should report as disconnected");

        done = YES;
    }];

    STAssertTrue(WaitFor(^BOOL { return done; }), @"async disconnect failed");
}

@end
