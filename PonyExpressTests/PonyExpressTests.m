//
//  PonyExpressTests.m
//  PonyExpressTests
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PonyExpressTests.h"
#import "PESender.h"

@implementation PonyExpressTests

- (void)setUp {
    [super setUp];

    // Set-up code here.
}

- (void)tearDown {
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark -

- (void)testClassMethodCreation {
    NSString* host = @"apple.com";
    NSUInteger port = 80;
    PESender* sender = [PESender senderWithHost:host port:port];

    STAssertNotNil(sender, @"+senderWithHost:port: should provide a non-nil sender");

    STAssertEqualObjects(host, sender.host, @"+senderWithHost:port: should store proper host");
    STAssertEquals(port, sender.port, @"+senderWithHost:port: should store proper port");
}

- (void)testInstanceMethodCreation {
    NSString* host = @"apple.com";
    NSUInteger port = 80;
    PESender* sender = [[PESender alloc] initWithHost:host port:port];

    STAssertNotNil(sender, @"-initWithHost:port: should provide a non-nil sender");
    STAssertEqualObjects(host, sender.host, @"-initWithHost:port: should store proper host");
    STAssertEquals(port, sender.port, @"-initWithHost:port: should store proper port");
}

@end
