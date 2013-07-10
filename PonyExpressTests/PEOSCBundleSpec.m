//
//  PEOSCBundleSpec.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 09 Jul 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCBundle-Private.h"
#import "PEOSCUtilities.h"

SpecBegin(PEOSCBundle)

__block NSArray* messages = nil;
NSDate* timeTag = [NSDate date];

beforeAll(^{
    NSMutableArray* list = [NSMutableArray array];
    // D5 in Drop D
    [list addObject:[PEOSCMessage messageWithAddress:@"/osc/1/freq" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@73.42]]];
    [list addObject:[PEOSCMessage messageWithAddress:@"/osc/2/freq" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@110.0]]];
    [list addObject:[PEOSCMessage messageWithAddress:@"/osc/3/freq" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@146.83]]];
    messages = list;
});

#pragma mark INITIALIZATION

it(@"should create non-nil instance from nil args", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:nil timeTag:nil];
    expect(bundle).notTo.beNil();
});

#pragma mark - PROPERTIES

it(@"should return init args from properties", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:messages timeTag:timeTag];
    expect(bundle.elements).to.beIdenticalTo(messages);
    expect(bundle.timeTag).to.beIdenticalTo(timeTag);
});

#pragma mark - ELEMENTS

it(@"should report elements as invalid when containing bad element", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[@"XYZZY", @31337] timeTag:nil];
    expect([bundle _areElementsValid]).to.beFalsy();

    // TODO - more complex nested one
});

it(@"should report empty elements as valid", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:nil timeTag:nil];
    expect([bundle _areElementsValid]).to.beTruthy();
});

it(@"should report legit elements as valid", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:messages timeTag:nil];
    expect([bundle _areElementsValid]).to.beTruthy();

    // TODO - more complex nested one
});

#pragma mark - DATA

it(@"should produce nil data when elements contain an invalid message", ^{
    expect(NO).to.beTruthy();
});

it(@"should produce data when without elements and time tag", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:nil timeTag:nil];
    NSData* data = [bundle _data];
    expect(data).notTo.beNil();
});

it(@"should not create a bundle instance from bad data", ^{
    NSData* data = [@"XYZZY" dataUsingEncoding:NSASCIIStringEncoding];
    PEOSCBundle* bundle = [PEOSCBundle bundleWithData:data];
    expect(bundle).to.beNil();

    // TODO - more complex examples
    //  #bundle 100000000
    //  #bundle LEGIT# BADMESSAGE
    //  #bundle LEGIT# BADBUNDLE
});

describe(@"with valid source elements and timeTag", ^{
    __block PEOSCBundle* sourceBundle;
    beforeAll(^{ sourceBundle = [PEOSCBundle bundleWithElements:messages timeTag:timeTag]; });

    it(@"should create non-nil data", ^{
        NSData* data = [sourceBundle _data];
        expect(data).toNot.beNil();
    });

    it(@"should create non-nil, equal bundle", ^{
        NSData* data = [sourceBundle _data];
        PEOSCBundle* bundle = [PEOSCBundle bundleWithData:data];
        expect(bundle).toNot.beNil();
        expect(bundle.elements).to.equal(sourceBundle.elements);
        expect(bundle.timeTag).to.equal(sourceBundle.timeTag);
        expect(bundle).to.equal(sourceBundle);
    });
});

describe(@"bundle with a nil time tag", ^{
    __block PEOSCBundle* sourceBundle;
    beforeAll(^{ sourceBundle = [PEOSCBundle bundleWithElements:nil timeTag:nil]; });

    it(@"should create non-nil data", ^{
        NSData* data = [sourceBundle _data];
        expect(data).toNot.beNil();
    });

    it(@"should create bundle with the immediate time tag", ^{
        NSData* data = [sourceBundle _data];
        PEOSCBundle* bundle = [PEOSCBundle bundleWithData:data];
        expect(bundle).toNot.beNil();
        expect(bundle.elements).toNot.beNil();
        expect(bundle.timeTag).toNot.beNil();
        expect([bundle.timeTag NTPTimestamp]).to.equal(NTPTimestampImmediate);
    });
});

SpecEnd
