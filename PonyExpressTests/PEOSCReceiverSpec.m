//
//  PEOSCReceiverSpec.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 21 Feb 2013.
//  Copyright (c) 2013-2014 Chorded Constructions. All rights reserved.
//

@interface ReceiverDelegate : NSObject <PEOSCReceiverDelegate>
@end
@implementation ReceiverDelegate
- (void)didReceiveMessage:(PEOSCMessage*)message {}
- (void)didReceiveBundle:(PEOSCBundle*)bundle {}
@end

SpecBegin(PEOSCReceiverSpec)

UInt16 reservedPort = 0;
UInt16 priviledgedPort = 99;
UInt16 unpriviledgedPort = 1337;

#pragma mark INITIALIZATION

it(@"should create nil instance when initialized to reserved port", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:reservedPort];
    expect(receiver).to.beNil();
});

it(@"should create non-nil instance from privledged port", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:priviledgedPort];
    expect(receiver).toNot.beNil();
});

it(@"should create non-nil instance from non-nil args", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    expect(receiver).toNot.beNil();
});

#pragma mark - PROPERTIES

it(@"should return init args from properties", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    expect(receiver).toNot.beNil();
    expect(receiver.port).to.equal(unpriviledgedPort);
});

it(@"should return delegate it was assigned", ^{
    ReceiverDelegate* delegate = [[ReceiverDelegate alloc] init];
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    receiver.delegate = delegate;
    expect(receiver.delegate).to.beIdenticalTo(delegate);
});

#pragma mark - BEGIN LISTENING

it(@"should not be listening by default", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    expect(receiver.isListening).to.beFalsy();
});

it(@"should fail to begin listening without a delegate", ^{
});

it(@"should fail to begin listening on priviledged port", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:priviledgedPort];
    NSError* error;
    BOOL status = [receiver beginListening:&error];
    expect(status).to.beFalsy();
    expect(error).toNot.beNil();
    expect(receiver.isListening).to.beFalsy();
});

it(@"should begin listening on unpriviledged port", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    NSError* error;
    BOOL status = [receiver beginListening:&error];
    expect(status).to.beTruthy();
    expect(error).to.beNil();
    expect(receiver.isListening).to.beTruthy();
});

it(@"should not be able to begin listening when already listening", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    [receiver beginListening:nil];
    expect(receiver.isListening).to.beTruthy();
    NSError* error;
    BOOL status = [receiver beginListening:&error];
    expect(status).to.beFalsy();
    expect(error).toNot.beNil();
    expect([error code]).to.equal(PEOSCReceiverAlreadyListeningError);
    expect(receiver.isListening).to.beTruthy();
});

// NB - PEOSCReceiver does not use a socket with SO_REUSEPORT
it(@"should not be able to listen on a port already in use", ^{
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    [receiver beginListening:nil];
    expect(receiver.isListening).to.beTruthy();

    PEOSCReceiver* otherReceiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    NSError* error;
    BOOL status = [otherReceiver beginListening:&error];
    expect(status).to.beFalsy();
    expect(error).toNot.beNil();
    expect(receiver.isListening).to.beTruthy();
});

#pragma mark - STOP LISTENING

it(@"should stop listening when listening", ^AsyncBlock {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    [receiver beginListening:nil];
    [receiver stopListeningWithCompletionHandler:^(BOOL success, NSError* error) {
        expect(success).to.beTruthy();
        expect(error).to.beNil();
        done();
    }];
});

it(@"should fail to stop listening when not listening", ^AsyncBlock {
    PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:unpriviledgedPort];
    [receiver stopListeningWithCompletionHandler:^(BOOL success, NSError* error) {
        expect(success).to.beFalsy();
        expect(error).toNot.beNil();
        expect([error code]).to.equal(PEOSCReceiverNotListeningError);
        done();
    }];
});

SpecEnd
