//
//  PEOSCSender.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEOSCSender.h"
#import "PonyExpress-Internal.h"
#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "GCDAsyncUdpSocket.h"

@interface PEOSCSender()
@property (nonatomic, readwrite, strong) NSString* host;
@property (nonatomic, readwrite) UInt16 port;
@property (nonatomic, strong) GCDAsyncUdpSocket* socket;
@property (nonatomic, readwrite, getter = isConnected) BOOL connected;
- (void)_setupSocket;
- (void)_tearDownSocket;
@end

@implementation PEOSCSender

@synthesize host, port, socket, connected;

+ (id)senderWithHost:(NSString*)host port:(UInt16)port {
    PEOSCSender* sender = [[PEOSCSender alloc] initWithHost:host port:port];
    return sender;
}

- (id)initWithHost:(NSString*)hos port:(UInt16)por {
    self = [super init];
    if (self) {
        self.host = hos;
        self.port = por;

        [self _setupSocket];
    }
    return self;
}

- (void)dealloc {
    [self _tearDownSocket];
}

#pragma mark -

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %@:%d>", NSStringFromClass([self class]), self.host, self.port];
}

#pragma mark -

- (BOOL)connect {
    if (self.isConnected)
        return NO;

    NSError* error;
    BOOL status = [self.socket connectToHost:self.host onPort:self.port error:&error];
    if (!status) {
        CCErrorLog(@"ERROR - failed to connect to host: %@:%d - %@", self.host, self.port, [error localizedDescription]);
    }

    // FIXME - not actually connected until messaged with -udpSocket:didConnectToAddress:
    self.connected = YES;//self.socket.isConnected;
    return self.isConnected;
}

- (BOOL)disconnect {
    if (!self.isConnected)
        return NO;

    // sender is probably going to be dumped, perhaps if AsyncUdpSocket had a weak reference to its delegate…
    self.socket.delegate = nil;

    [self.socket close];

    // FIXME - not actually disconnected until messaged with -udpSocketDidClose:withError:
    self.connected = NO;//self.socket.isConnected;
    return !self.isConnected;
}

- (void)sendMessage:(PEOSCMessage*)message {
    if (!self.isConnected) {
        CCErrorLog(@"ERROR - cannot send message when disconnected");
        return;
    }

    NSData* messageData = [message _data];
    if (!messageData) {
        CCErrorLog(@"ERROR - failed to send message: %@", message);
        return;
    }

    // TODO - actually add a tag
    [self.socket sendData:messageData withTimeout:-1.0 tag:13];
}

#pragma mark - SOCKET DELEGATE

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didConnectToAddress:(NSData*)address {
    CCDebugLogSelector();

    self.connected = YES;
    // TODO - notify delegate
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didNotConnect:(NSError*)error {
    CCDebugLogSelector();
    CCErrorLog(@"ERROR - failed to connect to host %@:%d due to %@", self.host, self.port, [error localizedDescription]);
    // TODO - notify delegate
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didSendDataWithTag:(long)tag {
    CCDebugLogSelector();
    // TODO - notify delegate
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didNotSendDataWithTag:(long)tag dueToError:(NSError*)error {
    CCDebugLogSelector();
    CCErrorLog(@"ERROR - failed to send data to host %@:%d due to %@", self.host, self.port, [error localizedDescription]);
    // TODO - notify delegate
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket*)sock withError:(NSError*)error {
    CCDebugLogSelector();

    self.connected = NO;
    // TODO - notify delegate
}

#pragma mark - PRIVATE
 
 - (void)_setupSocket {
     GCDAsyncUdpSocket* sock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
     self.socket = sock;
}

- (void)_tearDownSocket {
    [self disconnect];

    self.socket = nil;
}

@end
