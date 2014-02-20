//
//  ViewController.m
//  PonyExpress iOS Example
//
//  Created by Jean-Pierre Mouilleseaux on 29 Dec 2012.
//  Copyright (c) 2012-2014 Chorded Constructions. All rights reserved.
//

#import "ViewController.h"

#define LOCAL_PORT 9000
#define REMOTE_HOST @"localhost"
#define REMOTE_PORT 8999

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // setup receiver
    self.receiver = [PEOSCReceiver receiverWithPort:LOCAL_PORT];
    self.receiver.delegate = self;

    NSError* error;
    [self.receiver beginListening:&error];
    if (error) {
        NSLog(@"ERROR - failed to listen on port %u - %@", LOCAL_PORT, [error localizedDescription]);
    }

    // send a ping
    __block PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/ping" typeTags:@[PEOSCMessageTypeTagTimetag] arguments:@[[NSDate date]]];
    PEOSCSender* sender = [PEOSCSender senderWithHost:REMOTE_HOST port:REMOTE_PORT];
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
    NSLog(@"received message: %@", message);

    // send pong in a bundle
    if ([message.address isEqualToString:@"/ping"]) {
        PEOSCMessage* responseMessage = [PEOSCMessage messageWithAddress:@"/pong" typeTags:@[PEOSCMessageTypeTagTimetag] arguments:@[[NSDate date]]];
        __block PEOSCBundle* bundle = [PEOSCBundle bundleWithElements:@[responseMessage]];
        PEOSCSender* sender = [PEOSCSender senderWithHost:REMOTE_HOST port:REMOTE_PORT];
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
    NSLog(@"received bundle: %@", bundle);

    // sling them to
    [bundle.elements enumerateObjectsUsingBlock:^(PEOSCMessage* m, NSUInteger idx, BOOL* stop) {
        [self didReceiveMessage:m];
    }];
}

@end
