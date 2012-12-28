//
//  PEOSCMessageSpec.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 26 Dec 2012.
//  Copyright (c) 2012 Chorded Constructions. All rights reserved.
//

SpecBegin(PEOSCMessage)

describe(@"instance", ^{
	it(@"should initialize with nil values", ^{
        PEOSCMessage* message = [PEOSCMessage messageWithAddress:nil typeTags:nil arguments:nil];
		expect(message).notTo.beNil();
	});
});

SpecEnd
