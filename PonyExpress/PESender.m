//
//  PESender.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PESender.h"

@implementation PESender

@synthesize host, port;

+ (id)senderWithHost:(NSString*)host port:(NSUInteger)port {
    PESender* sender = [[PESender alloc] initWithHost:host port:port];
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
