//
//  PonyExpressMessageTests.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 7 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PonyExpressMessageTests.h"
#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"

@implementation PonyExpressMessageTests

- (void)testMessageClassMethodCreation {
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/fake" typeTags:[NSArray array] arguments:[NSArray array]];    
    STAssertNotNil(message, @"should provide a non-nil message");
}

- (void)testMessageInstanceMethodCreation {
    PEOSCMessage* message = [[PEOSCMessage alloc] initWithAddress:@"/fake" typeTags:[NSArray array] arguments:[NSArray array]];
    STAssertNotNil(message, @"should provide a non-nil message");
}

- (void)testMessageCreationArguments {
    NSString* address = @"/some/thing";
    NSArray* typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagInteger, nil];
    NSArray* arguments = [NSArray arrayWithObjects:[NSNumber numberWithInt:13], nil];
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:typeTags arguments:arguments];
    STAssertEqualObjects(message.address, address, @"should store proper address");
    STAssertEqualObjects(message.typeTags, typeTags, @"should store proper type tags");
    STAssertEqualObjects(message.arguments, arguments, @"should store proper arguments");
}

- (void)testMessageAddressValidity {
    NSString* address = @"/some/thing";
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:nil arguments:nil];
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"really/not/valid";
    STAssertFalse([message _isAddressValid], @"should consider illigitimate address invalid");
}

- (void)testMessageTypeTagStringCorrectnessAndValidity {
    NSString* address = @"/some/thing";
    NSArray* typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagBlob, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse, PEOSCMessageTypeTagTimetag, nil];
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:typeTags arguments:nil];
    STAssertEqualObjects([message _typeTagString], @",ifsbTFNIt", @"should generate proper type tag string");
    STAssertTrue([message _areTypeTagsValid], @"should report string from legit type tag list as valid");

    message.typeTags = [NSArray array];
    STAssertNil([message _typeTagString], @"should catch empty type tag list");
    STAssertFalse([message _areTypeTagsValid], @"should report string from empty type tag list as invalid");

    message = [PEOSCMessage messageWithAddress:address typeTags:nil arguments:nil];
    STAssertNil([message _typeTagString], @"should catch nil type tag list");
    STAssertFalse([message _areTypeTagsValid], @"should report string from nil type tag list as invalid");

    message.typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagImpulse, [NSNumber numberWithInt:13], nil];
    STAssertNil([message _typeTagString], @"should not generate a type tag string when the list contains a bad element");
    STAssertFalse([message _areTypeTagsValid], @"should report string from bad type tag list as invalid");
}

- (void)testMessageTypesForArguments {
    STAssertTrue([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagInteger], @"should report the Integer type as requiring an argument ");
    STAssertTrue([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagFloat], @"should report the Float type as requiring an argument ");
    STAssertTrue([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagString], @"should report the String type as requiring an argument ");
    STAssertTrue([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagBlob], @"should report the Blob type as requiring an argument ");
    STAssertFalse([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagTrue], @"should report the True type as requiring an argument ");
    STAssertFalse([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagFalse], @"should report the False type as requiring an argument ");
    STAssertFalse([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagNull], @"should report the Null type as requiring an argument ");
    STAssertFalse([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagImpulse], @"should report the Impulse type as requiring an argument ");    
    STAssertTrue([PEOSCMessage typeRequiresArgument:PEOSCMessageTypeTagTimetag], @"should report the Timetag type as requiring an argument ");    
}

- (void)testMessageArgumentValidity {
    NSString* address = @"/some/thing";
    NSArray* typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagBlob, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse, PEOSCMessageTypeTagTimetag, nil];
    NSArray* arguments = [NSArray arrayWithObjects:[NSNumber numberWithInt:13], [NSNumber numberWithFloat:(100./3.)], @"STRING", [NSData data], @"NTP TIME", nil];
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:typeTags arguments:arguments];
    STAssertTrue([message _areArgumentsValidGivenTypeTags], @"should treat identify valid arguemtns as valid");

    message.arguments = nil;
    STAssertFalse([message _areArgumentsValidGivenTypeTags], @"should treat identify nil arguemtns as invalid for valid types");

    message.arguments = [NSArray array];
    STAssertFalse([message _areArgumentsValidGivenTypeTags], @"should treat identify enmpty arguemtns as invalid for valid types");

    message.typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagImpulse, nil];
    message.arguments = arguments;
    STAssertFalse([message _areArgumentsValidGivenTypeTags], @"should treat identify mismatching arguments to type tags as invalid");
}

- (void)testMessageDataEnumerator {
    NSString* address = @"/some/thing";
    NSArray* typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagBlob, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse, PEOSCMessageTypeTagTimetag, nil];
    NSArray* arguments = [NSArray arrayWithObjects:[NSNumber numberWithInt:13], [NSNumber numberWithFloat:(100./3.)], @"STRING", [NSData data], @"NTP TIME", nil];
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:typeTags arguments:arguments];
    [message enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL *stop) {
        if ([PEOSCMessage typeRequiresArgument:type])
            STAssertNotNil(argument, @"should provide argument for type %@", type);
        else
            STAssertNil(argument, @"should NOT provide argument for type %@", type);
    }];

    __block NSUInteger iterations = 0;
    [message enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL *stop) {
        if ([type isEqualToString:PEOSCMessageTypeTagTrue])
            *stop = YES;
        iterations++;
    }];
    STAssertTrue(iterations == 5, @"should allow enumeration to be stopped");
}

@end
