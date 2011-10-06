//
//  PEOSCReceiver.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEOSCReceiver.h"
#import "PonyExpress-Internal.h"
#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "AsyncUdpSocket.h"

@interface PEOSCReceiver()
@property (nonatomic, readwrite) UInt16 port;
@property (nonatomic, strong) AsyncUdpSocket* socket;
@property (nonatomic, readwrite, getter = isConnected) BOOL connected;
- (void)_setupSocket;
- (void)_tearDownSocket;
@end

@implementation PEOSCReceiver

@synthesize port, socket, connected, delegate;

+ (id)receiverWithPort:(UInt16)port {
    PEOSCReceiver* receiver = [[PEOSCReceiver alloc] initWithPort:port];
    return receiver;
}

- (id)initWithPort:(UInt16)por {
    self = [super init];
    if (self) {
        self.port = por;

        [self _setupSocket];
    }
    return self;
}

- (void)dealloc {
    [self _tearDownSocket];
}

#pragma mark -

- (BOOL)connect {
    if (self.isConnected)
        return NO;

    NSError* error;
    BOOL status = [self.socket bindToPort:self.port error:&error];
    if (!status) {
        CCErrorLog(@"ERROR - failed to bind to port %d with error %@", self.port, [error localizedDescription]);
    }

    [self.socket receiveWithTimeout:-1 tag:0];

    self.connected = status;
    return self.isConnected;
}

- (BOOL)disconnect {
    if (!self.isConnected)
        return NO;

    [self.socket close];

    // receiver is probably going to be dumped, perhaps if AsyncUdpSocket had a weak reference to its delegate…
    self.socket.delegate = nil;

    self.connected = NO;
    return !self.isConnected;
}

#pragma mark - SOCKET DELEGATE

- (BOOL)onUdpSocket:(AsyncUdpSocket*)sock didReceiveData:(NSData*)data withTag:(long)tag fromHost:(NSString*)host port:(UInt16)port {
    CCDebugLogSelector();

    PEOSCMessage* message = [PEOSCMessage messageWithData:data];
    [self.delegate didReceiveMessage:message];

    [self.socket receiveWithTimeout:-1 tag:0];
    return message != nil;
}

- (void)onUdpSocket:(AsyncUdpSocket*)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError*)error {
    CCDebugLogSelector();
}

- (void)onUdpSocketDidClose:(AsyncUdpSocket*)sock {
    CCDebugLogSelector();
}

#pragma mark - PRIVATE

- (void)_setupSocket {
    AsyncUdpSocket* soc = [[AsyncUdpSocket alloc] initWithDelegate:self];
    self.socket = soc;
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
}

- (void)_tearDownSocket {
    [self disconnect];

    self.socket = nil;
}

@end
