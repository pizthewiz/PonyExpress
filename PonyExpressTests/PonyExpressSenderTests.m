//
//  PonyExpressSenderTests.m
//  PonyExpressSenderTests
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PonyExpressSenderTests.h"
#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "PEOSCSender.h"

@implementation PonyExpressSenderTests

- (void)setUp {
    [super setUp];

    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark - SENDER

- (void)testSenderClassMethodCreation {
    NSString* host = @"apple.com";
    UInt16 port = 80;
    PEOSCSender* sender = [PEOSCSender senderWithHost:host port:port];

    STAssertNotNil(sender, @"+senderWithHost:port: should provide a non-nil sender");

    STAssertEqualObjects(host, sender.host, @"+senderWithHost:port: should store proper host");
    STAssertEquals(port, sender.port, @"+senderWithHost:port: should store proper port");
}

- (void)testSenderInstanceMethodCreation {
    NSString* host = @"apple.com";
    UInt16 port = 80;
    PEOSCSender* sender = [[PEOSCSender alloc] initWithHost:host port:port];

    STAssertNotNil(sender, @"-initWithHost:port: should provide a non-nil sender");
    STAssertEqualObjects(host, sender.host, @"-initWithHost:port: should store proper host");
    STAssertEquals(port, sender.port, @"-initWithHost:port: should store proper port");
}

@end
