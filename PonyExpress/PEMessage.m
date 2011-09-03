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
    if (!self.typeTags.count)
        return nil;

    __block NSMutableString* string = [[NSMutableString alloc] initWithString:@","];
    [self.typeTags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        // catch interlopers
        if (![obj isKindOfClass:[NSString class]]) {
            string = nil;
            *stop = YES;
        }

        else if ([obj isEqualToString:PEMessageTypeTagInteger])
            [string appendString:@"i"];
        else if ([obj isEqualToString:PEMessageTypeTagFloat])
            [string appendString:@"f"];
        else if ([obj isEqualToString:PEMessageTypeTagString])
            [string appendString:@"s"];
        else if ([obj isEqualToString:PEMessageTypeTagBlob])
            [string appendString:@"b"];
        else if ([obj isEqualToString:PEMessageTypeTagTrue])
            [string appendString:@"T"];
        else if ([obj isEqualToString:PEMessageTypeTagFalse])
            [string appendString:@"F"];
        else if ([obj isEqualToString:PEMessageTypeTagNull])
            [string appendString:@"N"];
        else if ([obj isEqualToString:PEMessageTypeTagImpulse])
            [string appendString:@"I"];
        else if ([obj isEqualToString:PEMessageTypeTagTimetag])
            [string appendString:@"t"];
    }];
    return string;
}

@end
