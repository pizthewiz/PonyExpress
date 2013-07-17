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

__block NSArray* messages;
__block PEOSCMessage* message;

beforeAll(^{
    NSMutableArray* list = [NSMutableArray array];
    // D5 in Drop D
    [list addObject:[PEOSCMessage messageWithAddress:@"/osc/1/freq" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@73.42]]];
    [list addObject:[PEOSCMessage messageWithAddress:@"/osc/2/freq" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@110.0]]];
    [list addObject:[PEOSCMessage messageWithAddress:@"/osc/3/freq" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@146.83]]];
    messages = list;

    message = [PEOSCMessage messageWithAddress:@"/osc/1/amp" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@33.33]];
});

#pragma mark INITIALIZATION

it(@"should create non-nil instance from nil args", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:nil];
    expect(bundle).notTo.beNil();
});

#pragma mark - PROPERTIES

it(@"should return init args from properties", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:messages];
    expect(bundle.elements).to.beIdenticalTo(messages);
});

#pragma mark - ELEMENTS

it(@"should report elements as invalid when containing bad element", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[message, @"XYZZY", @31337]];
    expect([bundle _areElementsValid]).to.beFalsy();

    // TODO - check other forms of "bad"
});

it(@"should report elements as invalid when subbundle contains bad element", ^{
    PEOSCBundle* innerBundle = [PEOSCBundle bundleWithElements:@[message, @"XYZZY", @31337]];
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[innerBundle]];
    expect([bundle _areElementsValid]).to.beTruthy();

    // TODO - check other forms of "bad"
});

it(@"should report as valid when elements nil", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:nil];
    expect([bundle _areElementsValid]).to.beTruthy();
});

it(@"should report as valid when elements empty", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[]];
    expect([bundle _areElementsValid]).to.beTruthy();
});

it(@"should report as valid when elements contains messages", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:messages];
    expect([bundle _areElementsValid]).to.beTruthy();
});

it(@"should report as valid when elements contains bundle", ^{
    PEOSCBundle* innerBundle = [PEOSCBundle bundleWithElements:nil];
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[innerBundle]];
    expect([bundle _areElementsValid]).to.beTruthy();
});

it(@"should report as valid when elements contains bundle and messages", ^{
    NSMutableArray* elements = [NSMutableArray arrayWithArray:messages];
    PEOSCBundle* innerBundle = [PEOSCBundle bundleWithElements:@[message]];
    [elements addObject:innerBundle];
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:elements];
    expect([bundle _areElementsValid]).to.beTruthy();
});

#pragma mark - DATA

it(@"should produce nil data when containing a bad element", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[@"XYZZY", @31337]];
    expect([bundle _data]).to.beNil();
});

it(@"should produce data when without elements", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:nil];
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

describe(@"with valid source elements", ^{
    __block PEOSCBundle* sourceBundle;
    beforeAll(^{ sourceBundle = [PEOSCBundle bundleWithElements:messages]; });

    it(@"should create non-nil data", ^{
        NSData* data = [sourceBundle _data];
        expect(data).toNot.beNil();
    });

    it(@"should create non-nil, equal bundle", ^{
        NSData* data = [sourceBundle _data];
        PEOSCBundle* bundle = [PEOSCBundle bundleWithData:data];
        expect(bundle).toNot.beNil();
        expect(bundle.elements).to.equal(sourceBundle.elements);
        expect(bundle).to.equal(sourceBundle);
    });
});

SpecEnd
