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

+ (id)senderWithHost:(NSString*)host port:(UInt16)port {
    PEOSCSender* sender = [[PEOSCSender alloc] initWithHost:host port:port];
    return sender;
}

- (id)initWithHost:(NSString*)hos port:(UInt16)por {
    self = [super init];
    if (self) {
        self.host = hos;
        self.port = por;
    }
    return self;
}

#pragma mark -

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %@:%d>", NSStringFromClass([self class]), self.host, self.port];
}

@end
