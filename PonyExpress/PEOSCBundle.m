//
//  PEOSCBundle.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 24 Mar 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCBundle.h"
#import "PEOSCBundle-Private.h"

@implementation PEOSCBundle

+ (instancetype)bundleWithMessages:(NSArray*)messages {
    id bundle = [[[self class] alloc] initWithMessages:messages];
    return bundle;
}

- (instancetype)initWithMessages:(NSArray*)messages {
    self = [super init];
    if (self) {
        self.messages = messages;
    }
    return self;
}

+ (instancetype)bundleWithData:(NSData*)data {
    id bundle = [[[self class] alloc] initWithData:data];
    return bundle;
}

- (instancetype)initWithData:(NSData*)data {
    self = [super init];
    if (self) {
        // check first 8 bytes for #bundle
        // readDate of message timetag

        // readInteger of message length
        // read message
        // (repeat)
    }
    return self;
}

#pragma mark - PRIVATE

//- (NSData*)_data {
//    return nil;
//}

@end
