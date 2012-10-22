//
//  PEOSCSender.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "PEOSCSender.h"
#import "PonyExpress-Internal.h"
#import "PEOSCMessage-Private.h"
#import "GCDAsyncUdpSocket.h"

NSString* const PEOSCSenderErrorDomain = @"PEOSCSenderErrorDomain";

@interface PEOSCSender ()
@property (nonatomic, readwrite, strong) NSString* host;
@property (nonatomic, readwrite) UInt16 port;
@property (nonatomic, strong) GCDAsyncUdpSocket* socket;
@property (nonatomic) NSMutableDictionary* messageCache;
@property (nonatomic) long messageTag;
@end

@implementation PEOSCSender

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

- (void)sendMessage:(PEOSCMessage*)message {
    NSData* messageData = [message _data];
    if (!messageData) {
        CCErrorLog(@"ERROR - failed to send message: %@", message);
        return;
    }

    // hold onto the message for a spell
    [self.messageCache setObject:message forKey:[NSString stringWithFormat:@"%lu", self.messageTag]];

    [self.socket sendData:messageData toHost:self.host port:self.port withTimeout:-1.0 tag:self.messageTag];
    self.messageTag = self.messageTag+1;
}

#pragma mark - SOCKET DELEGATE

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didConnectToAddress:(NSData*)address {
    CCDebugLogSelector();
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didNotConnect:(NSError*)error {
    CCDebugLogSelector();
    CCErrorLog(@"ERROR - failed to connect to host %@:%d due to %@", self.host, self.port, [error localizedDescription]);
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didSendDataWithTag:(long)tag {
    CCDebugLogSelector();

    NSString* key = [NSString stringWithFormat:@"%lu", tag];
    PEOSCMessage* message = self.messageCache[key];
    [self.delegate didSendMessage:message];
    [self.messageCache removeObjectForKey:key];
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didNotSendDataWithTag:(long)tag dueToError:(NSError*)error {
    CCDebugLogSelector();
    CCErrorLog(@"ERROR - failed to send data with tag %lu to host %@:%d due to %@", tag, self.host, self.port, [error localizedDescription]);

    NSString* key = [NSString stringWithFormat:@"%lu", tag];
    PEOSCMessage* message = self.messageCache[key];
    [self.delegate didNotSendMessage:message dueToError:error];
    [self.messageCache removeObjectForKey:key];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket*)sock withError:(NSError*)error {
    CCDebugLogSelector();
}

#pragma mark - PRIVATE
 
 - (void)_setupSocket {
     self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)_tearDownSocket {
    self.socket.delegate = nil;
    self.socket = nil;
}

@end
