//
//  main.m
//  PonyExpress Mac Example
//
//  Created by Jean-Pierre Mouilleseaux on 30 Dec 2012.
//  Copyright (c) 2012-2013 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PonyExpress/PonyExpress.h>

#define PORT_IN 8999
#define PORT_OUT 9000

@interface ReceiverDelegate : NSObject <PEOSCReceiverDelegate>
@end
@implementation ReceiverDelegate
- (void)didReceiveMessage:(PEOSCMessage*)message {
    NSLog(@"received: %@", message);

    // send pong in a bundle bundle
    if ([message.address isEqualToString:@"/ping"]) {
        PEOSCMessage* responseMessage = [PEOSCMessage messageWithAddress:@"/pong" typeTags:@[PEOSCMessageTypeTagTimetag] arguments:@[[NSDate date]]];
        __block PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[responseMessage]];
        PEOSCSender* sender = [PEOSCSender senderWithHost:@"127.0.0.1" port:PORT_OUT];
        [sender sendBundle:bundle handler:^(BOOL success, NSError* error) {
            if (error) {
                NSLog(@"ERROR - failed to send bundle '%@' - %@", bundle, [error localizedDescription]);
                return;
            }
            NSLog(@"sent: %@", bundle);
        }];
    }
}
- (void)didReceiveBundle:(PEOSCBundle*)bundle {
    NSLog(@"received: %@", bundle);
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // setup receiver
        PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:PORT_IN];
        ReceiverDelegate* delegate = [[ReceiverDelegate alloc] init];
        receiver.delegate = delegate;

        NSError* error;
        [receiver beginListening:&error];
        if (error) {
            NSLog(@"ERROR - failed to listen on port %u - %@", PORT_IN, [error localizedDescription]);
            return 1;
        }

        // send ping message
        __block PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/ping" typeTags:@[PEOSCMessageTypeTagTimetag] arguments:@[[NSDate date]]];
        PEOSCSender* sender = [PEOSCSender senderWithHost:@"127.0.0.1" port:PORT_OUT];
        [sender sendMessage:message handler:^(BOOL success, NSError* error) {
            if (error) {
                NSLog(@"ERROR - failed to send message '%@' - %@", message, [error localizedDescription]);
                return;
            }
            NSLog(@"sent: %@", message);
        }];

        dispatch_main();
    }
    return 0;
}
