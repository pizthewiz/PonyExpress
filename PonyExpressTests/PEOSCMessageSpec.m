//
//  PEOSCMessageSpec.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 26 Dec 2012.
//  Copyright (c) 2012-2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCMessage-Private.h"
#import "PEOSCUtilities.h"

SpecBegin(PEOSCMessage)

NSString* address = @"/oscillator/3/frequency";
NSArray* tags = @[PEOSCMessageTypeTagFloat];
NSArray* args = @[@440.0];
NSArray* allTags = @[PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagBlob, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse, PEOSCMessageTypeTagTimetag];
NSArray* allArgs = @[@13, @33.3F, @"STRING", [@"One-Eyed Jacks" dataUsingEncoding:NSASCIIStringEncoding], [NSDate date]];

#pragma mark INITIALIZATION

it(@"should create non-nil instance from nil args", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:nil typeTags:nil arguments:nil];
    expect(message).notTo.beNil();
});

#pragma mark - PROPERTIES

it(@"should return init args from properties", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:allTags arguments:allArgs];
    expect(message.address).to.beIdenticalTo(address);
    expect(message.typeTags).to.beIdenticalTo(allTags);
    expect(message.arguments).to.beIdenticalTo(allArgs);
});

// TODO - remoteHost and remotePort?

#pragma mark - ADDRESS

it(@"should report bad addresses as invalid", ^{
    // TODO - expand and link to OSC spec
    NSArray* addresses = @[@"", @" ", @" /osc", @"oscillator/666", @"/super oscillator/666", @"/oscillator/3,9/frequency", @"/oscillator/op-1/frequency", @"/oscillator/{3-9}/frequency", @"/oscillator/{3,9/frequency", @"/oscillator/[3,9]/frequency", @"/oscillator/[3-9/frequency", @"/oscillator/{[3-9],13}/frequency", @"/oscillator/{{3,4},13}/frequency", @"/oscillator/[[3-4]-13]/frequency"];
    for (NSString* badAddress in addresses) {
        PEOSCMessage* message = [PEOSCMessage messageWithAddress:badAddress typeTags:nil arguments:nil];
        expect([message _isAddressValid]).to.beFalsy();
        expect([message _isValid]).to.beFalsy();
    }
});
it(@"should report legit addresses as valid", ^{
    // TODO - expand and link to OSC spec
    NSArray* addresses = @[@"/?/b/*c", @"/oscillator/*/frequency", @"/oscillator/[1-4]/frequency", @"/oscillator/[1234]/frequency", @"/oscillator/[!5-6]/frequency", @"/oscillator/[!56]/frequency", @"/oscillator/3/frequency!", @"/oscillator/{1,3,5,7}/frequency"];
    for (NSString* goodAddress in addresses) {
        PEOSCMessage* message = [PEOSCMessage messageWithAddress:goodAddress typeTags:nil arguments:nil];
        expect([message _isAddressValid]).to.beTruthy();
        expect([message _isValid]).to.beTruthy();
    }
});

#pragma mark - TYPE TAGS

it(@"should report type tags as invalid when containing unknown type tags", ^{
    NSArray* tags = @[PEOSCMessageTypeTagBlob, @"BANANAS", PEOSCMessageTypeTagInteger];
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:nil typeTags:tags arguments:nil];
    expect([message _areTypeTagsValid]).to.beFalsy();
    expect([message _isValid]).to.beFalsy();
});
it(@"should report type tags as valid when containing all known type tags", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:allTags arguments:allArgs];
    expect([message _areTypeTagsValid]).to.beTruthy();
    expect([message _typeTagString]).to.equal(@",ifsbTFNIt");
    expect([message _isValid]).to.beTruthy();
});
it(@"should report type tags as valid when nil", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:nil arguments:nil];
    expect([message _areTypeTagsValid]).to.beTruthy();
    expect([message _typeTagString]).to.equal(@",");
    expect([message _isValid]).to.beTruthy();
});

#pragma mark - ARGUMENTS

it(@"should report unknown argument type as invalid", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:@[PEOSCMessageTypeTagString] arguments:@[@[]]];
    expect([message _areArgumentsValidGivenTypeTags]).to.beFalsy();
    expect([message _isValid]).to.beFalsy();
});
it(@"should report argument without type as invalid", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:nil arguments:@[@440.0]];
    expect([message _areArgumentsValidGivenTypeTags]).to.beFalsy();
    expect([message _isValid]).to.beFalsy();
});
it(@"should report mismatched argument for type as invalid", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:@[PEOSCMessageTypeTagString] arguments:@[@440.0]];
    expect([message _areArgumentsValidGivenTypeTags]).to.beFalsy();
    expect([message _isValid]).to.beFalsy();
});
it(@"should report argument for argless-type as invalid", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:@[PEOSCMessageTypeTagImpulse] arguments:@[@440.0]];
    expect([message _areArgumentsValidGivenTypeTags]).to.beFalsy();
    expect([message _isValid]).to.beFalsy();
});
it(@"should report missing argument for given types as invalid", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:@[PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagFloat] arguments:@[@440.0]];
    expect([message _areArgumentsValidGivenTypeTags]).to.beFalsy();
    expect([message _isValid]).to.beFalsy();
});
it(@"should report extra argument for given types as invalid", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@440.0, @880.0]];
    expect([message _areArgumentsValidGivenTypeTags]).to.beFalsy();
    expect([message _isValid]).to.beFalsy();
});
it(@"should report good arguments for types as valid", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:allTags arguments:allArgs];
    expect([message _areArgumentsValidGivenTypeTags]).to.beTruthy();
    expect([message _isValid]).to.beTruthy();
});

#pragma mark - ENUMERATOR

it(@"should provide arguments only for required types via data enumerator", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:allTags arguments:allArgs];
    [message enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL* stop) {
        if ([PEOSCMessage argumentRequiredByType:type]) {
            expect(argument).toNot.beNil();
        } else {
            expect(argument).to.beNil();
        }
    }];
});

#pragma mark - DATA

it(@"should produce nil data for invalid message", ^{
    // bad address
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:nil typeTags:nil arguments:nil];
    expect([message _isValid]).to.beFalsy();
    expect([message _data]).to.beNil();

    // bad typeTags
    message = [PEOSCMessage messageWithAddress:address typeTags:@[@"BANANAS"] arguments:nil];
    expect([message _isValid]).to.beFalsy();
    expect([message _data]).to.beNil();

    // bad arguments given typeTags
    message = [PEOSCMessage messageWithAddress:address typeTags:@[PEOSCMessageTypeTagFloat] arguments:nil];
    expect([message _isValid]).to.beFalsy();
    expect([message _data]).to.beNil();
});

it(@"should produce non-nil data for valid message", ^{
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:tags arguments:args];
    expect([message _isValid]).to.beTruthy();
    expect([message _data]).toNot.beNil();
});

it(@"should not create a message instance from bad data", ^{
    NSData* data = [@"XYZZY" dataUsingEncoding:NSASCIIStringEncoding];
    PEOSCMessage* message = [PEOSCMessage messageWithData:data];
    expect(message).to.beNil();
});

describe(@"with valid simple source message", ^{
    __block PEOSCMessage* sourceMessage;
    beforeAll(^{ sourceMessage = [PEOSCMessage messageWithAddress:address typeTags:tags arguments:args]; });

    it(@"should create non-nil data", ^{
        NSData* data = [sourceMessage _data];
        expect(data).toNot.beNil();
    });
    it(@"should create non-nil, equal message", ^{
        NSData* data = [sourceMessage _data];
        PEOSCMessage* message = [PEOSCMessage messageWithData:data];
        expect(message).toNot.beNil();
        expect(message.address).to.equal(sourceMessage.address);
        expect(message.typeTags).to.equal(sourceMessage.typeTags);
        expect(message.arguments).to.equal(sourceMessage.arguments);
        expect(message).to.equal(sourceMessage);
    });
});
describe(@"with valid complex source message", ^{
    __block PEOSCMessage* sourceMessage;
    beforeAll(^{ sourceMessage = [PEOSCMessage messageWithAddress:address typeTags:allTags arguments:allArgs]; });

    it(@"should create non-nil data", ^{
        NSData* data = [sourceMessage _data];
        expect(data).toNot.beNil();
    });
    it(@"should create non-nil, equal message", ^{
        NSData* data = [sourceMessage _data];
        PEOSCMessage* message = [PEOSCMessage messageWithData:data];
        expect(message).toNot.beNil();
        expect(message.address).to.equal(sourceMessage.address);
        expect(message.typeTags).to.equal(sourceMessage.typeTags);
        // NB - potential failure due to NSDate/TimeTag not being perfectly symmetrical
        expect(message.arguments).to.equal(sourceMessage.arguments);
        expect(message).to.equal(sourceMessage);
    });
});

it(@"should create message instance from message with immediate time tag data", ^{
    PEOSCMessage* sourceMessage = [PEOSCMessage messageWithAddress:address typeTags:@[PEOSCMessageTypeTagTimetag] arguments:@[[NSDate OSCImmediate]]];
    NSData* data = [sourceMessage _data];
    PEOSCMessage* message = [PEOSCMessage messageWithData:data];
    expect(message).toNot.beNil();
    expect(message.typeTags).to.equal(sourceMessage.typeTags);
    expect(message.arguments).to.equal(sourceMessage.arguments);
    expect(message.arguments[0]).to.beIdenticalTo([NSDate OSCImmediate]);
});

SpecEnd
