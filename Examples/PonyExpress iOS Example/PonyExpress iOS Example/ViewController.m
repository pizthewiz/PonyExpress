//
//  ViewController.m
//  PonyExpress iOS Example
//
//  Created by Jean-Pierre Mouilleseaux on 29 Dec 2012.
//  Copyright (c) 2012 Chorded Constructions. All rights reserved.
//

#import "ViewController.h"

#define PORT_IN 9000
#define PORT_OUT 8999

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // setup receiver
    self.receiver = [PEOSCReceiver receiverWithPort:PORT_IN];
    self.receiver.delegate = self;

    NSError* error;
    [self.receiver beginListening:&error];
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)didReceiveMessage:(PEOSCMessage*)message {
    NSLog(@"received: %@", message);

    // send pong in a bundle bundle
    if ([message.address isEqualToString:@"/ping"]) {
        PEOSCMessage* responseMessage = [PEOSCMessage messageWithAddress:@"/pong" typeTags:@[PEOSCMessageTypeTagTimetag] arguments:@[[NSDate date]]];
        __block PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[responseMessage] timeTag:nil];
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
