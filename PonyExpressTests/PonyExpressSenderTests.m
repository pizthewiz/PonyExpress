//
//  PonyExpressSenderTests.m
//  PonyExpressSenderTests
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "PonyExpressSenderTests.h"
//#import "PonyExpressTestHelper.h"
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

// TODO - sending

@end
