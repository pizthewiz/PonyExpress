//
//  PEOSCReceiver.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 30 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import "PEOSCReceiver.h"
#import "PonyExpress-Internal.h"
#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "GCDAsyncUdpSocket.h"

@interface PEOSCReceiver()
@property (nonatomic, readwrite) UInt16 port;
@property (nonatomic, strong) GCDAsyncUdpSocket* socket;
@property (nonatomic, readwrite, getter = isListening) BOOL listening;
- (void)_setupSocket;
- (void)_tearDownSocket;
@end

@implementation PEOSCReceiver

@synthesize port, socket, listening, delegate;

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

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: INADDR_ANY:%d>", NSStringFromClass([self class]), self.port];
}

#pragma mark -

- (BOOL)beginListening {
    if (self.isListening)
        return NO;

    NSError* error;
    BOOL status = [self.socket bindToPort:self.port error:&error];
    if (!status) {
        CCErrorLog(@"ERROR - failed to bind to port %d with error %@", self.port, [error localizedDescription]);
        return NO;
    }
    status = [self.socket beginReceiving:&error];
    if (!status) {
        CCErrorLog(@"ERROR - failed to begin receiving on socket with error %@", [error localizedDescription]);
        return NO;
    }

    self.listening = YES;
    return self.isListening;
}

- (BOOL)stopListening {
    if (!self.isListening)
        return NO;

    // receiver is probably going to be dumped, perhaps if AsyncUdpSocket had a weak reference to its delegate…
    self.socket.delegate = nil;

    [self.socket close];

    // FIXME - not actually disconnected until messaged with -udpSocketDidClose:withError:
    self.listening = NO;
    return !self.isListening;
}

#pragma mark - SOCKET DELEGATE

- (void)udpSocket:(GCDAsyncUdpSocket*)sock didReceiveData:(NSData*)data fromAddress:(NSData*)address withFilterContext:(id)filterContext {
    CCDebugLogSelector();

    PEOSCMessage* message = [PEOSCMessage messageWithData:data];
    [self.delegate didReceiveMessage:message];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket*)sock withError:(NSError*)error {
    CCDebugLogSelector();

    self.listening = NO;
    // TODO - notify delegate
}

#pragma mark - PRIVATE

- (void)_setupSocket {
    GCDAsyncUdpSocket* sock = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.socket = sock;
}

- (void)_tearDownSocket {
    [self stopListening];

    self.socket = nil;
}

@end
