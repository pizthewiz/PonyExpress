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

@interface SenderDelegate : NSObject <PEOSCSenderDelegate>
@end
@implementation SenderDelegate
- (void)didSendMessage:(PEOSCMessage*)message {
    NSLog(@"delegate sent: %@", message);
}
- (void)didNotSendMessage:(PEOSCMessage*)message dueToError:(NSError*)error {
    NSLog(@"delegate FAILED to send: %@ due to - %@", message, [error localizedDescription]);
}
@end

int main (int argc, const char* argv[]) {
    @autoreleasepool {
        NSArray* typeTags = @[PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagBlob, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse];
        NSArray* arguments = @[@(13), [NSNumber numberWithFloat:100./3.], @"STRING", [@"One Eyed Jacks" dataUsingEncoding:NSASCIIStringEncoding]];
        PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/oscillator/4/frequency" typeTags:typeTags arguments:arguments];
        NSLog(@"message to send: %@", message);

        PEOSCReceiver* receiver = [PEOSCReceiver receiverWithPort:7777];
        receiver.delegate = [[ReceiverDelegate alloc] init];
        NSLog(@"receiver: %@", receiver);
        BOOL status = [receiver beginListening];
        if (!status) {
            NSLog(@"ERROR - receiver failed to begin listneing: %@", receiver);
            return 1;
        }

        PEOSCSender* sender = [PEOSCSender senderWithHost:@"0.0.0.0" port:7777];
        sender.delegate = [[SenderDelegate alloc] init];
        NSLog(@"sender: %@", sender);
        [sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
            [sender sendMessage:message];
        }];

        dispatch_main();
    }
    return 0;
}
