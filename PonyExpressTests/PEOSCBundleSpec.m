//
//  PEOSCBundleSpec.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 09 Jul 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCBundle-Private.h"

SpecBegin(PEOSCBundle)

__block NSArray* messages = nil;

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
    PEOSCBundle* bundle = [PEOSCBundle bundleWithMessages:nil];
    expect(bundle).notTo.beNil();
});

#pragma mark - PROPERTIES

it(@"should return init args from properties", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithMessages:messages];
    expect(bundle.messages).to.beIdenticalTo(messages);
});

#pragma mark - DATA

it(@"should produce nil data when messages contain an invalid message", ^{
    expect(NO).to.beTruthy();
});

it(@"should produce data when message-less", ^{
    PEOSCBundle* bundle = [PEOSCBundle bundleWithMessages:nil];
    NSData* data = [bundle _data];
    expect(data).notTo.beNil();
});

it(@"should not create a bundle instance from bad data", ^{
    NSData* data = [@"XYZZY" dataUsingEncoding:NSASCIIStringEncoding];
    PEOSCBundle* bundle = [PEOSCBundle bundleWithData:data];
    expect(bundle).to.beNil();
});

describe(@"with valid source messages", ^{
    __block PEOSCBundle* sourceBundle;
    beforeAll(^{ sourceBundle = [PEOSCBundle bundleWithMessages:messages]; });

    it(@"should create non-nil data", ^{
        NSData* data = [sourceBundle _data];
        expect(data).toNot.beNil();
    });

    it(@"should create non-nil, equal bundle", ^{
        NSData* data = [sourceBundle _data];
        PEOSCBundle* bundle = [PEOSCBundle bundleWithData:data];
        expect(bundle).toNot.beNil();
        expect(bundle.messages).to.equal(sourceBundle.messages);
        expect(bundle).to.equal(sourceBundle);
    });
});

SpecEnd
