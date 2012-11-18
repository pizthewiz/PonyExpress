//
//  main.m
//  OrphanExample
//
//  Created by Jean-Pierre Mouilleseaux on 3 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PonyExpress/PonyExpress.h>

@interface ReceiverDelegate : NSObject <PEOSCReceiverDelegate>
@end
@implementation ReceiverDelegate
- (void)didReceiveMessage:(PEOSCMessage*)message {
    NSLog(@"delegate received: %@", message);
}
@end

int main (int argc, const char* argv[]) {
    @autoreleasepool {
        NSArray* typeTags = @[PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagBlob, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse];
        NSArray* arguments = @[@13, @33.3F, @"STRING", [@"One Eyed Jacks" dataUsingEncoding:NSASCIIStringEncoding]];
        __block PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/oscillator/4/frequency" typeTags:typeTags arguments:arguments];
        NSLog(@"message to send: %@", message);

        PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:7777];
        ReceiverDelegate* rd = [[ReceiverDelegate alloc] init];
        receiver.delegate = rd;
        NSLog(@"receiver: %@", receiver);

        NSError* error;
        BOOL status = [receiver beginListening:&error];
        if (!status) {
            NSLog(@"ERROR - receiver failed to begin listneing: %@ due to - %@", receiver, [error localizedDescription]);
            return 1;
        }

        // 0.0.0.0 all local interfaces
        // 127.0.0.1 loopback interface
        // 224.0.0.1 multicast to all registered parties
        PEOSCSender* sender = [PEOSCSender senderWithHost:@"127.0.0.1" port:7777];
        NSLog(@"sender: %@", sender);
        [sender sendMessage:message handler:^(BOOL success, NSError* error) {
            if (!success) {
                NSLog(@"ERROR - failed to send message %@", message);
                return 1;
            }
        }];

        dispatch_main();
    }
    return 0;
}
