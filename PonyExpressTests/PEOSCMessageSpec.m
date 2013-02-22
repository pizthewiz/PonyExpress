//
//  PEOSCMessageSpec.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 26 Dec 2012.
//  Copyright (c) 2012-2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCMessage-Private.h"

SpecBegin(PEOSCMessage)

describe(@"with nil args at initialization", ^{
    __block PEOSCMessage* message;
    beforeAll(^{ message = [PEOSCMessage messageWithAddress:nil typeTags:nil arguments:nil]; });

    it(@"should create non-nil instance", ^{
        PEOSCMessage* message = [PEOSCMessage messageWithAddress:nil typeTags:nil arguments:nil];
        expect(message).notTo.beNil();
    });

    // address
	it(@"should have nil address property", ^{
        expect(message.address).to.beNil();
	});
	it(@"should report invalid address", ^{
        expect([message _isAddressValid]).to.beFalsy();
	});
    // type tags
	it(@"should have nil type tags property", ^{
        expect(message.typeTags).to.beNil();
	});
	it(@"should have proper empty type tag string component", ^{
        expect([message _typeTagString]).notTo.beNil();
        expect([message _typeTagString]).to.equal(@",");
	});
	it(@"should report valid type tags", ^{
        expect([message _areTypeTagsValid]).to.beTruthy();
	});
    // arguments
	it(@"should have nil arguments property", ^{
        expect(message.arguments).to.beNil();
	});
	it(@"should report valid arguments given type tags", ^{
        expect([message _areArgumentsValidGivenTypeTags]).to.beTruthy();
	});
});

it(@"should not create a message instance from bad data", ^{
    NSData* data = [@"XYZZY" dataUsingEncoding:NSASCIIStringEncoding];
    PEOSCMessage* message = [PEOSCMessage messageWithData:data];
    expect(message).to.beNil();
});

SpecEnd
