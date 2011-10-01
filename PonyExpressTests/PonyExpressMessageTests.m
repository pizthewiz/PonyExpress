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

@interface PonyExpressMessageTests()
@property (nonatomic, strong) NSArray* allTypes;
@property (nonatomic, strong) NSArray* allArgs;
@property (nonatomic, strong) NSArray* legitTypes;
@property (nonatomic, strong) NSArray* legitArgs;
@property (nonatomic, strong) NSString* legitAddress;
@property (nonatomic, strong) NSString* badAddress;
@end

@implementation PonyExpressMessageTests

@synthesize allTypes, allArgs, legitTypes, legitArgs, legitAddress, badAddress;

- (void)setUp {
    [super setUp];

    self.allTypes = [NSArray arrayWithObjects:PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagBlob, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse, PEOSCMessageTypeTagTimetag, nil];
    // TODO - set proper NTP TIME when available
    self.allArgs = [NSArray arrayWithObjects:[NSNumber numberWithInt:13], [NSNumber numberWithFloat:(100./3.)], @"STRING", [NSData data], @"NTPTIME-UNIMPLEMENTED", nil];

    self.legitTypes = [NSArray arrayWithObjects:PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagBlob, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse, nil];
    self.legitArgs = [NSArray arrayWithObjects:[NSNumber numberWithInt:13], [NSNumber numberWithFloat:(100./3.)], @"STRING", [NSData data], nil];

    self.legitAddress = @"/oscillator/3/frequency";
    self.badAddress = @"bad/address";
}

- (void)tearDown {
    // Tear-down code here.

    [super tearDown];
}

#pragma mark -

- (void)testClassMethodCreation {
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/oscillator/3/configuration" typeTags:self.allTypes arguments:self.allArgs];
    STAssertNotNil(message, @"should provide a non-nil message");
}

- (void)testInstanceMethodCreation {
    PEOSCMessage* message = [[PEOSCMessage alloc] initWithAddress:@"/oscillator/3/configuration" typeTags:self.allTypes arguments:self.allArgs];
    STAssertNotNil(message, @"should provide a non-nil message");
}

- (void)testCreationFromData {
    PEOSCMessage* m = [[PEOSCMessage alloc] initWithAddress:self.legitAddress typeTags:self.legitTypes arguments:self.legitArgs];
    NSData* data = [m _data];

    PEOSCMessage* message = [PEOSCMessage messageWithData:data];
    STAssertNotNil(message, @"should create message from valid data");
    STAssertEqualObjects(message.address, m.address, @"should restore address");
    STAssertEqualObjects(message.typeTags, m.typeTags, @"should restore type tags");
    STAssertEqualObjects(message.arguments, m.arguments, @"should restore arguments");
}

- (void)testCreationFromBadData {
    PEOSCMessage* message = [PEOSCMessage messageWithData:[NSData data]];
    STAssertNil(message, @"should create message from valid data");
}

- (void)testCreationArguments {
    NSString* address = @"/oscillator/3/frequency";
    NSArray* typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagInteger, nil];
    NSArray* arguments = [NSArray arrayWithObjects:[NSNumber numberWithInt:440], nil];
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:typeTags arguments:arguments];
    STAssertEqualObjects(message.address, address, @"should store proper address");
    STAssertEqualObjects(message.typeTags, typeTags, @"should store proper type tags");
    STAssertEqualObjects(message.arguments, arguments, @"should store proper arguments");
}

- (void)testAddressValidity {
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:self.legitAddress typeTags:nil arguments:nil];
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"/?/b/*c";
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"/oscillator/*/frequency";
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"/oscillator/[1-4]/frequency";
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"/oscillator/[1234]/frequency";
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"/oscillator/[!5-6]/frequency";
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"/oscillator/[!56]/frequency";
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"/oscillator/3/frequency!";
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");

    message.address = @"/oscillator/{1,3,5,7}/frequency";
    STAssertTrue([message _isAddressValid], @"should consider legit address valid");


    message.address = @"oscillator/666";
    STAssertFalse([message _isAddressValid], @"should require address to begin with backslash");

    message.address = @"/super oscillator/666";
    STAssertFalse([message _isAddressValid], @"should disallow spaces");

    message.address = @"/oscillator/3,9/frequency";
    STAssertFalse([message _isAddressValid], @"should disallow comma when not in curly brace list");

    message.address = @"/oscillator/op-1/frequency";
    STAssertFalse([message _isAddressValid], @"should disallow dash when not in bracket range");

    message.address = @"/oscillator/{3-9}/frequency";
    STAssertFalse([message _isAddressValid], @"should not allow dash within curly brace list");

    message.address = @"/oscillator/{3,9/frequency";
    STAssertFalse([message _isAddressValid], @"should require closing curly brace in list");

    message.address = @"/oscillator/[3,9]/frequency";
    STAssertFalse([message _isAddressValid], @"should not allow comma in square bracket range");

    message.address = @"/oscillator/[3-9/frequency";
    STAssertFalse([message _isAddressValid], @"should require closing square bracket in range");

    message.address = @"/oscillator/{[3-9],13}/frequency";
    STAssertFalse([message _isAddressValid], @"should not allow nested range within list");

    message.address = @"/oscillator/{{3,4},13}/frequency";
    STAssertFalse([message _isAddressValid], @"should not allow nested lists");

    message.address = @"/oscillator/[[3-4]-13]/frequency";
    STAssertFalse([message _isAddressValid], @"should not allow nested ranges");
}

- (void)testTypeTagStringCorrectnessAndValidity {
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:self.legitAddress typeTags:self.allTypes arguments:self.allArgs];
    STAssertEqualObjects([message _typeTagString], @",ifsbTFNIt", @"should generate proper type tag string");
    STAssertTrue([message _areTypeTagsValid], @"should report string from legit type tag list as valid");

    message.typeTags = [NSArray array];
    STAssertNil([message _typeTagString], @"should catch empty type tag list");
    STAssertFalse([message _areTypeTagsValid], @"should report string from empty type tag list as invalid");

    message = [PEOSCMessage messageWithAddress:self.legitAddress typeTags:nil arguments:nil];
    STAssertNil([message _typeTagString], @"should catch nil type tag list");
    STAssertFalse([message _areTypeTagsValid], @"should report string from nil type tag list as invalid");

    message.typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagImpulse, [NSNumber numberWithInt:13], nil];
    STAssertNil([message _typeTagString], @"should not generate a type tag string when the list contains a bad element");
    STAssertFalse([message _areTypeTagsValid], @"should report string from bad type tag list as invalid");
}

- (void)testTypesForArguments {
    STAssertTrue([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagInteger], @"should report the Integer type as requiring an argument ");
    STAssertTrue([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagFloat], @"should report the Float type as requiring an argument ");
    STAssertTrue([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagString], @"should report the String type as requiring an argument ");
    STAssertTrue([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagBlob], @"should report the Blob type as requiring an argument ");
    STAssertFalse([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagTrue], @"should report the True type as requiring an argument ");
    STAssertFalse([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagFalse], @"should report the False type as requiring an argument ");
    STAssertFalse([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagNull], @"should report the Null type as requiring an argument ");
    STAssertFalse([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagImpulse], @"should report the Impulse type as requiring an argument ");    
    STAssertTrue([PEOSCMessage argumentRequiredByType:PEOSCMessageTypeTagTimetag], @"should report the Timetag type as requiring an argument ");    
}

- (void)testArgumentValidity {
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:self.legitAddress typeTags:self.allTypes arguments:self.allArgs];
    STAssertTrue([message _areArgumentsValidGivenTypeTags], @"should treat identify valid arguments as valid");

    message.arguments = nil;
    STAssertFalse([message _areArgumentsValidGivenTypeTags], @"should treat identify nil arguments as invalid for valid types");

    message.arguments = [NSArray array];
    STAssertFalse([message _areArgumentsValidGivenTypeTags], @"should treat identify enmpty arguments as invalid for valid types");

    message.typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagImpulse, nil];
    message.arguments = self.allArgs;
    STAssertFalse([message _areArgumentsValidGivenTypeTags], @"should treat identify mismatching arguments to type tags as invalid");
}

- (void)testDataEnumerator {
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:self.legitAddress typeTags:self.allTypes arguments:self.allArgs];
    [message enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL *stop) {
        if ([PEOSCMessage argumentRequiredByType:type])
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

- (void)testGoodMessageGeneration {
    PEOSCMessage* m = [[PEOSCMessage alloc] initWithAddress:self.legitAddress typeTags:self.legitTypes arguments:self.legitArgs];
    NSData* data = [m _data];
    STAssertNotNil(data, @"should generate valid data");
    // TODO - compare to expected length?
}

- (void)testBadMessageGeneration {
    PEOSCMessage* m = [[PEOSCMessage alloc] initWithAddress:self.badAddress typeTags:self.legitTypes arguments:self.legitArgs];
    NSData* data = [m _data];
    STAssertNil(data, @"should not generate data for bad message");
}

@end
