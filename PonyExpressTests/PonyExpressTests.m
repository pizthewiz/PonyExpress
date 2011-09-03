//
//  PonyExpressTests.m
//  PonyExpressTests
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PonyExpressTests.h"
#import "PEMessage.h"
#import "PEMessage-Private.h"
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

#pragma mark - MESSAGE

- (void)testMessageClassMethodCreation {
    PEMessage* message = [PEMessage messageWithAddress:@"/fake" typeTags:[NSArray array] arguments:[NSArray array]];    
    STAssertNotNil(message, @"should provide a non-nil message");
}

- (void)testMessageInstanceMethodCreation {
    PEMessage* message = [[PEMessage alloc] initWithAddress:@"/fake" typeTags:[NSArray array] arguments:[NSArray array]];
    STAssertNotNil(message, @"should provide a non-nil message");
}

- (void)testMessageCreationArguments {
    NSString* address = @"/rather/fake";
    NSArray* typeTags = [NSArray arrayWithObjects:PEMessageTypeTagInteger, nil];
    NSArray* arguments = [NSArray arrayWithObjects:[NSNumber numberWithInt:13], nil];
    PEMessage* message = [[PEMessage alloc] initWithAddress:address typeTags:typeTags arguments:arguments];
    STAssertEqualObjects(message.address, address, @"should store proper address");
    STAssertEqualObjects(message.typeTags, typeTags, @"should store proper type tags");
    STAssertEqualObjects(message.arguments, arguments, @"should store proper arguments");
}

- (void)testMessageValidTagTypeString {
    NSString* address = @"/rather/fake";
    NSArray* typeTags = [NSArray arrayWithObjects:PEMessageTypeTagInteger, PEMessageTypeTagFloat, PEMessageTypeTagString, PEMessageTypeTagBlob, PEMessageTypeTagTrue, PEMessageTypeTagFalse, PEMessageTypeTagNull, PEMessageTypeTagImpulse, PEMessageTypeTagTimetag, nil];
    PEMessage* message = [[PEMessage alloc] initWithAddress:address typeTags:typeTags arguments:nil];
    STAssertEqualObjects([message _typeTagString], @",ifsbTFNIt", @"should generate proper type tag string");
}

- (void)testMessageInalidTagTypeString {
    NSString* address = @"/rather/fake";
    NSArray* typeTags = [NSArray array];
    PEMessage* message = [[PEMessage alloc] initWithAddress:address typeTags:typeTags arguments:nil];
    STAssertNil([message _typeTagString], @"should catch empty type tag string");

    message = [[PEMessage alloc] initWithAddress:address typeTags:nil arguments:nil];
    STAssertNil([message _typeTagString], @"should catch empty type tag string");

    typeTags = [NSArray arrayWithObjects:[NSNumber numberWithInt:13], nil];
    message = [[PEMessage alloc] initWithAddress:address typeTags:typeTags arguments:nil];
    STAssertNil([message _typeTagString], @"should catch invalid type tag string");
}

#pragma mark - SENDER

- (void)testSenderClassMethodCreation {
    NSString* host = @"apple.com";
    NSUInteger port = 80;
    PESender* sender = [PESender senderWithHost:host port:port];

    STAssertNotNil(sender, @"+senderWithHost:port: should provide a non-nil sender");

    STAssertEqualObjects(host, sender.host, @"+senderWithHost:port: should store proper host");
    STAssertEquals(port, sender.port, @"+senderWithHost:port: should store proper port");
}

- (void)testSenderInstanceMethodCreation {
    NSString* host = @"apple.com";
    NSUInteger port = 80;
    PESender* sender = [[PESender alloc] initWithHost:host port:port];

    STAssertNotNil(sender, @"-initWithHost:port: should provide a non-nil sender");
    STAssertEqualObjects(host, sender.host, @"-initWithHost:port: should store proper host");
    STAssertEquals(port, sender.port, @"-initWithHost:port: should store proper port");
}

@end
