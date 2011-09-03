//
//  PEOSCSender.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEOSCSender.h"

@implementation PEOSCSender

@synthesize host, port;

+ (id)senderWithHost:(NSString*)host port:(NSUInteger)port {
    PEOSCSender* sender = [[PEOSCSender alloc] initWithHost:host port:port];
    return sender;
}

- (id)initWithHost:(NSString*)h port:(NSUInteger)p {
    self = [super init];
    if (self) {
        self.host = h;
        self.port = p;
    }
    return self;
}

@end
