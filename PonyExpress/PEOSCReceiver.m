//
//  PEOSCReceiver.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "PEOSCReceiver.h"
#import "PonyExpress-Internal.h"
#import "PEOSCMessage-Private.h"
#import "GCDAsyncUdpSocket.h"

NSString* const PEOSCReceiverErrorDomain = @"PEOSCReceiverErrorDomain";

@interface PEOSCReceiver ()
@property (nonatomic, readwrite) UInt16 port;
@property (nonatomic, strong) GCDAsyncUdpSocket* socket;
@property (nonatomic, readwrite, getter = isListening) BOOL listening;
@property (nonatomic, strong) PEOSCReceiverCompletionHandler stopListeningCompletionHandler;
@end

@implementation PEOSCReceiver

+ (instancetype)receiverWithPort:(UInt16)port {
    PEOSCReceiver* receiver = [[PEOSCReceiver alloc] initWithPort:port];
    return receiver;
}

- (instancetype)initWithPort:(UInt16)port {
    self = [super init];
    if (self) {
        self.port = port;

        [self _setupSocket];
    }
    return self;
}

- (void)dealloc {
    [self _tearDownSocket];
}

#pragma mark -

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: INADDR_ANY:%d>", NSStringFromClass([self class]), self.port];
}

#pragma mark -

- (BOOL)beginListening:(NSError**)error {
    if (self.isListening) {
        if (error) {
            *error = [NSError errorWithDomain:PEOSCReceiverErrorDomain code:PEOSCReceiverAlreadyListeningError userInfo:nil];
        }
        return NO;
    }

    BOOL status = [self.socket bindToPort:self.port error:error];
    if (!status) {
        CCErrorLog(@"ERROR - failed to bind to port %d with error %@", self.port, [*error localizedDescription]);
        return NO;
    }
    status = [self.socket beginReceiving:error];
    if (!status) {
        CCErrorLog(@"ERROR - failed to begin receiving on socket with error %@", [*error localizedDescription]);
        return NO;
    }

    self.listening = YES;
    return YES;
}

- (void)stopListeningWithCompletionHandler:(PEOSCReceiverCompletionHandler)handler {
    if (!self.isListening) {
        NSError* error = [NSError errorWithDomain:PEOSCReceiverErrorDomain code:PEOSCReceiverNotListeningError userInfo:nil];
        handler(NO, error);
        return;
    }

    self.stopListeningCompletionHandler = handler;

    [self.socket close];
}

#pragma mark - SOCKET DELEGATE

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didReceiveData:(NSData*)data fromAddress:(NSData*)address withFilterContext:(id)filterContext {
    CCDebugLogSelector();

    // TODO - in a multicast situation, it is possible to receive the same data twice, once via IPv4 and again via IPv6

    PEOSCMessage* message = [PEOSCMessage messageWithData:data];
    if (message) {
        [self.delegate didReceiveMessage:message];
    }
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket*)sock withError:(NSError*)error {
    CCDebugLogSelector();

    self.listening = NO;
    self.stopListeningCompletionHandler(YES, error);
}

#pragma mark - PRIVATE

- (void)_setupSocket {
    self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)_tearDownSocket {
    [self stopListeningWithCompletionHandler:^(BOOL success, NSError* error) {
        self.socket.delegate = nil;
        self.socket = nil;
    }];
}

@end
