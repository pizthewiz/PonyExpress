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

@interface PEOSCSender()
@property (nonatomic, readwrite, retain) NSString* host;
@property (nonatomic, readwrite) UInt16 port;
@property (nonatomic, retain) AsyncUdpSocket* socket;
- (BOOL)_setupSocket;
- (BOOL)_tearDownSocket;
@end

@implementation PEOSCSender

@synthesize socket, host, port;

+ (id)senderWithHost:(NSString*)host port:(UInt16)port {
    PEOSCSender* sender = [[PEOSCSender alloc] initWithHost:host port:port];
    return [sender autorelease];
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

    [super dealloc];
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

    BOOL status = [self.socket sendData:messageData withTimeout:0 tag:13];
    if (!status) {
        CCWarningLog(@"WARNING - failed to send message: %@ to %@:%@", message, self.host, self.port);
    }
}

#pragma mark - SOCKET DELEGATE

- (void)onUdpSocketDidClose:(AsyncUdpSocket*)sock {
    CCDebugLogSelector();
}

- (void)onUdpSocket:(AsyncUdpSocket*)sock didSendDataWithTag:(long)tag {
    CCDebugLogSelector();
}

- (void)onUdpSocket:(AsyncUdpSocket*)sock didNotSendDataWithTag:(long)tag dueToError:(NSError*)error {
    CCDebugLogSelector();
}

#pragma mark - PRIVATE
 
 - (BOOL)_setupSocket {
     AsyncUdpSocket* soc = [[AsyncUdpSocket alloc] initWithDelegate:self];
     self.socket = soc;
     [soc release];

     NSError* error = nil;
     BOOL status = [self.socket connectToHost:self.host onPort:self.port error:&error];
     if (!status) {
         CCErrorLog(@"ERROR - failed to connect to host: %@:%d - %@", self.host, self.port, [error localizedDescription]);
         return NO;
     }

     return YES;
}

- (BOOL)_tearDownSocket {
    [self.socket close];

    return YES;
}

@end
