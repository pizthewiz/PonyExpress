//
//  PonyExpressSenderTests.m
//  PonyExpressSenderTests
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "PonyExpressSenderTests.h"
#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "PEOSCSender.h"

@interface PonyExpressSenderTests()
@property (nonatomic, retain) NSString* loopbackHost;
@property (nonatomic) UInt16 unprivledgedPort;
@property (nonatomic) UInt16 privledgedPort;
@end

@implementation PonyExpressSenderTests

@synthesize loopbackHost, unprivledgedPort, privledgedPort;

- (void)setUp {
    [super setUp];

    self.loopbackHost = @"127.0.0.1";

    self.privledgedPort = 80;
    self.unprivledgedPort = 31337;
}

- (void)tearDown {
    // Tear-down code here.

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

- (void)testConnectionToBadHost {
    PEOSCSender* sender = [PEOSCSender senderWithHost:@"log lady" port:self.unprivledgedPort];
    BOOL status = [sender connect];

    // NB - -connect is innaccurate, more akin to begin connecting as the process is async
    STAssertFalse(status, @"should report unsuccessful connection");
    STAssertFalse(sender.isConnected, @"should report as disconnected");
}

- (void)testConnectionFlow {
    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    BOOL status = [sender connect];
    STAssertTrue(status, @"should report successful connection");
    STAssertTrue(sender.isConnected, @"should report as connected");
    // double connection
    status = [sender connect];
    STAssertFalse(status, @"should report unsuccessful connection");
    STAssertTrue(sender.isConnected, @"should report as connected");
    // disconnect
    status = [sender disconnect];
    STAssertTrue(status, @"should report successful disconnection");
    STAssertFalse(sender.isConnected, @"should report as disconnected");
    // double disconnect
    status = [sender disconnect];
    STAssertFalse(status, @"should report unsuccessful disconnection");
    STAssertFalse(sender.isConnected, @"should report as disconnected");
}

- (void)testConnectionOnAPrivledgedPort {
    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.privledgedPort];
    BOOL status = [sender connect];
    STAssertTrue(status, @"should report successful connection");
    STAssertTrue(sender.isConnected, @"should report as connected");

    status = [sender disconnect];
    STAssertTrue(status, @"should report successful disconnection");
    STAssertFalse(sender.isConnected, @"should report as disconnected");
}

- (void)testConnectionOnAnUnprivledgedPort {
    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    BOOL status = [sender connect];
    STAssertTrue(status, @"should report successful connection");
    STAssertTrue(sender.isConnected, @"should report as connected");

    status = [sender disconnect];
    STAssertTrue(status, @"should report successful disconnection");
    STAssertFalse(sender.isConnected, @"should report as disconnected");
}

- (void)testConnectionOnAPortInUse {
    PEOSCSender* sender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    BOOL status = [sender connect];
    STAssertTrue(status, @"should report successful connection");
    STAssertTrue(sender.isConnected, @"should report as connected");

    PEOSCSender* otherSender = [PEOSCSender senderWithHost:self.loopbackHost port:self.unprivledgedPort];
    status = [otherSender connect];
    STAssertTrue(status, @"should report unsuccessful connection");
    STAssertTrue(sender.isConnected, @"should report as disconnected");
}

@end
