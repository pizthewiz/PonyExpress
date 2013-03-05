//
//  PEOSCSenderSpec.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 21 Feb 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

SpecBegin(PEOSCSenderSpec)

NSString* loopbackHost = @"127.0.0.1";
UInt16 reservedPort = 0;
UInt16 priviledgedPort = 88;
UInt16 unpriviledgedPort = 1337;

NSString* address = @"/oscillator/3/frequency";
NSArray* tags = @[PEOSCMessageTypeTagFloat];
NSArray* args = @[@440.0];

#pragma mark INITIALIZATION

it(@"should create nil instance from nil host", ^{
    PEOSCSender* sender = [PEOSCSender senderWithHost:nil port:unpriviledgedPort];
    expect(sender).to.beNil();
});

it(@"should create nil instance from reserved port", ^{
    PEOSCSender* sender = [PEOSCSender senderWithHost:nil port:reservedPort];
    expect(sender).to.beNil();
});

it(@"should create non-nil instance from non-nil args", ^{
    PEOSCSender* sender = [PEOSCSender senderWithHost:loopbackHost port:unpriviledgedPort];
    expect(sender).toNot.beNil();
});

#pragma mark - PROPERTIES

it(@"should return init args from properties", ^{
    PEOSCSender* sender = [PEOSCSender senderWithHost:loopbackHost port:unpriviledgedPort];
    expect(sender.host).to.beIdenticalTo(loopbackHost);
    expect(sender.port).to.equal(unpriviledgedPort);
});

#pragma mark - SENDING

it(@"should fail to send bad message", ^AsyncBlock {
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:nil typeTags:nil arguments:nil];
    PEOSCSender* sender = [PEOSCSender senderWithHost:loopbackHost port:unpriviledgedPort];
    [sender sendMessage:message handler:^(BOOL success, NSError* error) {
        expect(success).to.beFalsy();
        expect(error).toNot.beNil();
        expect([error code]).to.equal(PEOSCSenderOtherError);
        done();
    }];
});

describe(@"with good source message", ^{
    __block PEOSCMessage* sourceMessage;
    beforeAll(^{ sourceMessage = [PEOSCMessage messageWithAddress:address typeTags:tags arguments:args]; });

    it(@"should send to unpriviledged port", ^AsyncBlock {
        PEOSCSender* sender = [PEOSCSender senderWithHost:loopbackHost port:unpriviledgedPort];
        [sender sendMessage:sourceMessage handler:^(BOOL success, NSError* error) {
            expect(success).to.beTruthy();
            expect(error).to.beNil();
            done();
        }];
    });
    it(@"should send to priviledged port", ^AsyncBlock {
        PEOSCSender* sender = [PEOSCSender senderWithHost:loopbackHost port:priviledgedPort];
        [sender sendMessage:sourceMessage handler:^(BOOL success, NSError* error) {
            expect(success).to.beTruthy();
            expect(error).to.beNil();
            done();
        }];
    });
});

it(@"should send type-less message", ^AsyncBlock {
    PEOSCMessage* message = [PEOSCMessage messageWithAddress:address typeTags:nil arguments:nil];
    PEOSCSender* sender = [PEOSCSender senderWithHost:loopbackHost port:unpriviledgedPort];
    [sender sendMessage:message handler:^(BOOL success, NSError* error) {
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        done();
    }];
});

SpecEnd
