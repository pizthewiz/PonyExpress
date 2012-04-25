//
//  PEOSCSender.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "PEOSCSender.h"
#import "PonyExpress-Internal.h"
#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "GCDAsyncUdpSocket.h"

NSString* const PEOSCSenderErrorDomain = @"PEOSCSenderErrorDomain";

@interface PEOSCSender()
@property (nonatomic, readwrite, strong) NSString* host;
@property (nonatomic, readwrite) UInt16 port;
@property (nonatomic, strong) GCDAsyncUdpSocket* socket;
@property (nonatomic, readwrite, getter = isConnected) BOOL connected;
@property (nonatomic) NSMutableDictionary* messageCache;
@property (nonatomic) long messageTag;
@property (nonatomic, strong) PEOSCSenderConnectCompletionHandler connectCompletionHandler;
@property (nonatomic, strong) PEOSCSenderDisconnectCompletionHandler disconnectCompletionHandler;
- (void)_setupSocket;
- (void)_tearDownSocket;
@end

@implementation PEOSCSender

@synthesize host = _host, port = _port, socket = _socket, connected = _connected, delegate = _delegate, messageCache = _messageCache, messageTag = _message, connectCompletionHandler = _connectCompletionHandler, disconnectCompletionHandler = _disconnectCompletionHandler;

+ (id)senderWithHost:(NSString*)host port:(UInt16)port {
    PEOSCSender* sender = [[PEOSCSender alloc] initWithHost:host port:port];
    return sender;
}

- (id)initWithHost:(NSString*)host port:(UInt16)port {
    self = [super init];
    if (self) {
        self.host = host;
        self.port = port;

        self.messageCache = [NSMutableDictionary dictionaryWithCapacity:10];

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

- (void)connectWithCompletionHandler:(PEOSCSenderConnectCompletionHandler)handler {
    if (self.isConnected) {
        NSError* error = [NSError errorWithDomain:PEOSCSenderErrorDomain code:PEOSCSenderAlreadyConnectedError userInfo:nil];
        handler(NO, error);
        return;
    }

    self.connectCompletionHandler = handler;

    NSError* error;
    BOOL status = [self.socket connectToHost:self.host onPort:self.port error:&error];
    if (!status) {
        CCErrorLog(@"ERROR - failed to connect to host: %@:%d - %@", self.host, self.port, [error localizedDescription]);
        self.connectCompletionHandler(NO, error);
    }
}

- (void)disconnectWithCompletionHandler:(PEOSCSenderDisconnectCompletionHandler)handler {
    if (!self.isConnected) {
        NSError* error = [NSError errorWithDomain:PEOSCSenderErrorDomain code:PEOSCSenderNotConnectedError userInfo:nil];
        handler(NO, error);
        return;
    }

    self.disconnectCompletionHandler = handler;
    [self.socket close];
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

    // hold onto the message for a spell
    [self.messageCache setObject:message forKey:[NSString stringWithFormat:@"%lu", self.messageTag]];

    [self.socket sendData:messageData withTimeout:-1.0 tag:self.messageTag];
    self.messageTag = self.messageTag+1;
}

#pragma mark - SOCKET DELEGATE

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didConnectToAddress:(NSData*)address {
    CCDebugLogSelector();

    self.connected = YES;
    self.connectCompletionHandler(YES, nil);
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didNotConnect:(NSError*)error {
    CCDebugLogSelector();
    CCErrorLog(@"ERROR - failed to connect to host %@:%d due to %@", self.host, self.port, [error localizedDescription]);
    self.connectCompletionHandler(NO, error);
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didSendDataWithTag:(long)tag {
    CCDebugLogSelector();

    NSString* key = [NSString stringWithFormat:@"%lu", tag];
    PEOSCMessage* message = [self.messageCache objectForKey:key];
    [self.delegate didSendMessage:message];
    [self.messageCache removeObjectForKey:key];
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didNotSendDataWithTag:(long)tag dueToError:(NSError*)error {
    CCDebugLogSelector();
    CCErrorLog(@"ERROR - failed to send data with tag %lu to host %@:%d due to %@", tag, self.host, self.port, [error localizedDescription]);

    NSString* key = [NSString stringWithFormat:@"%lu", tag];
    PEOSCMessage* message = [self.messageCache objectForKey:key];
    [self.delegate didNotSendMessage:message dueToError:error];
    [self.messageCache removeObjectForKey:key];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket*)sock withError:(NSError*)error {
    CCDebugLogSelector();

    self.connected = NO;
    self.disconnectCompletionHandler(YES, error);
}

#pragma mark - PRIVATE
 
 - (void)_setupSocket {
     GCDAsyncUdpSocket* sock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
     self.socket = sock;
}

- (void)_tearDownSocket {
    [self disconnectWithCompletionHandler:^(BOOL success, NSError *error) {
        self.socket.delegate = nil;
        self.socket = nil;
    }];
}

@end
