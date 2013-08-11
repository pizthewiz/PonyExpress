//
//  PEOSCSender.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 02 Sept 2011.
//  Copyright (c) 2011-2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCSender.h"
#import "PonyExpress-Internal.h"
#import "PEOSCMessage-Private.h"
#import "PEOSCBundle-Private.h"
#import "GCDAsyncUdpSocket.h"

NSString* const PEOSCSenderErrorDomain = @"PEOSCSenderErrorDomain";

@interface PEOSCSender ()
@property (nonatomic, readwrite, strong) NSString* host;
@property (nonatomic, readwrite) UInt16 port;
@property (nonatomic, strong) GCDAsyncUdpSocket* socket;
@property (nonatomic, strong) NSMutableDictionary* callbackMap;
@property (nonatomic) long tag;
@end

@implementation PEOSCSender

+ (instancetype)senderWithHost:(NSString*)host port:(UInt16)port {
    PEOSCSender* sender = [[PEOSCSender alloc] initWithHost:host port:port];
    return sender;
}

- (instancetype)initWithHost:(NSString*)host port:(UInt16)port {
    if (!host || port == 0) {
        return nil;
    }

    self = [super init];
    if (self) {
        self.host = host;
        self.port = port;

        self.callbackMap = [NSMutableDictionary dictionaryWithCapacity:13];

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

- (void)sendMessage:(PEOSCMessage*)message handler:(PEOSCSenderCompletionHandler)handler {
    NSData* data = [message _data];
    if (!data) {
        CCErrorLog(@"ERROR - failed to generate message data: %@", message);
        NSError* error = [NSError errorWithDomain:PEOSCSenderErrorDomain code:PEOSCSenderOtherError userInfo:nil];
        handler(NO, error);
        return;
    }

    // hold onto callback
    if (handler) {
        (self.callbackMap)[[NSString stringWithFormat:@"%lu", self.tag]] = handler;
    }

    [self.socket sendData:data toHost:self.host port:self.port withTimeout:-1.0 tag:self.tag];
    // TODO - catch overflow
    self.tag++;
}

- (void)sendBundle:(PEOSCBundle*)bundle handler:(PEOSCSenderCompletionHandler)handler {
    NSData* data = [bundle _data];
    if (!data) {
        CCErrorLog(@"ERROR - failed to generate bundle data: %@", bundle);
        NSError* error = [NSError errorWithDomain:PEOSCSenderErrorDomain code:PEOSCSenderOtherError userInfo:nil];
        handler(NO, error);
        return;
    }

    // hold onto callback
    if (handler) {
        (self.callbackMap)[[NSString stringWithFormat:@"%lu", self.tag]] = handler;
    }

    [self.socket sendData:data toHost:self.host port:self.port withTimeout:-1.0 tag:self.tag];
    // TODO - catch overflow
    self.tag++;
}

#pragma mark - SOCKET DELEGATE

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didSendDataWithTag:(long)tag {
    CCDebugLogSelector();

    NSString* key = [NSString stringWithFormat:@"%lu", tag];
    void(^handler)(BOOL success, NSError* error) = (self.callbackMap)[key];
    if (handler) {
        handler(YES, nil);
    }

    [self.callbackMap removeObjectForKey:key];
}

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didNotSendDataWithTag:(long)tag dueToError:(NSError*)error {
    CCDebugLogSelector();
    CCErrorLog(@"ERROR - failed to send data with tag %lu to %@:%d due to %@", tag, self.host, self.port, [error localizedDescription]);

    NSString* key = [NSString stringWithFormat:@"%lu", tag];
    void(^handler)(BOOL success, NSError* error) = (self.callbackMap)[key];
    if (handler) {
        handler(NO, error);
    }

    [self.callbackMap removeObjectForKey:key];
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
