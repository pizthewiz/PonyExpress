//
//  PEMessage.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 9/2/11.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEMessage.h"

NSString* const PEMessageTypeTag = @"PEMessageTypeTag";
NSString* const PEMessageArgument = @"PEMessageArgument";

@implementation PEMessage

@synthesize address, typeTags, arguments;

+ (id)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments {
    id message = [[PEMessage alloc] initWithAddress:address typeTags:typeTags arguments:arguments];
    return message;
}

- (id)initWithAddress:(NSString*)add typeTags:(NSArray*)typ arguments:(NSArray*)arg {
    self = [super init];
    if (self) {
        self.address = add;
        self.typeTags = typ;
        self.arguments = arg;
    }
    return self;
}

@end
