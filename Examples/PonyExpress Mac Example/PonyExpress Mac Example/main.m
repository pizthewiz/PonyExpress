//
//  main.m
//  PonyExpress Mac Example
//
//  Created by Jean-Pierre Mouilleseaux on 30 Dec 2012.
//  Copyright (c) 2012 Chorded Constructions. All rights reserved.
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

    // send a pong
    if ([message.address isEqualToString:@"/ping"]) {
        __block PEOSCMessage* responseMessage = [PEOSCMessage messageWithAddress:@"/pong" typeTags:@[PEOSCMessageTypeTagTimetag] arguments:@[[NSDate date]]];
        PEOSCSender* sender = [PEOSCSender senderWithHost:@"127.0.0.1" port:PORT_OUT];
        [sender sendMessage:responseMessage handler:^(BOOL success, NSError* error) {
            if (error) {
                NSLog(@"ERROR - failed to send message '%@' - %@", responseMessage, [error localizedDescription]);
                return;
            }
            NSLog(@"sent: %@", responseMessage);
        }];
    }
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
        }

        // send a ping
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

