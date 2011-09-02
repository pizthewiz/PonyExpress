//
//  PEMessage.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 9/2/11.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEMessage.h"
#import "PEMessage-Private.h"

NSString* const PEMessageTypeTagInteger = @"PEMessageTypeTagInteger";
NSString* const PEMessageTypeTagFloat = @"PEMessageTypeTagFloat";
NSString* const PEMessageTypeTagString = @"PEMessageTypeTagString";
NSString* const PEMessageTypeTagBlob = @"PEMessageTypeTagBlob";
NSString* const PEMessageTypeTagTrue = @"PEMessageTypeTagTrue";
NSString* const PEMessageTypeTagFalse = @"PEMessageTypeTagFalse";
NSString* const PEMessageTypeTagNull = @"PEMessageTypeTagNull";
NSString* const PEMessageTypeTagImpulse = @"PEMessageTypeTagImpulse";
NSString* const PEMessageTypeTagTimetag = @"PEMessageTypeTagTimetag";

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

#pragma mark -

- (NSString*)_typeTagString {
    return nil;
}

@end
