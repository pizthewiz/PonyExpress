//
//  PEOSCMessage.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"

NSString* const PEOSCMessageTypeTagInteger = @"PEOSCMessageTypeTagInteger";
NSString* const PEOSCMessageTypeTagFloat = @"PEOSCMessageTypeTagFloat";
NSString* const PEOSCMessageTypeTagString = @"PEOSCMessageTypeTagString";
NSString* const PEOSCMessageTypeTagBlob = @"PEOSCMessageTypeTagBlob";
NSString* const PEOSCMessageTypeTagTrue = @"PEOSCMessageTypeTagTrue";
NSString* const PEOSCMessageTypeTagFalse = @"PEOSCMessageTypeTagFalse";
NSString* const PEOSCMessageTypeTagNull = @"PEOSCMessageTypeTagNull";
NSString* const PEOSCMessageTypeTagImpulse = @"PEOSCMessageTypeTagImpulse";
NSString* const PEOSCMessageTypeTagTimetag = @"PEOSCMessageTypeTagTimetag";

@implementation PEOSCMessage

@synthesize address, typeTags, arguments;

+ (id)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments {
    id message = [[PEOSCMessage alloc] initWithAddress:address typeTags:typeTags arguments:arguments];
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

+ (BOOL)typeRequiresArgument:(NSString*)type {
    BOOL status = YES;
    if ([type isEqualToString:PEOSCMessageTypeTagTrue] || [type isEqualToString:PEOSCMessageTypeTagFalse] || [type isEqualToString:PEOSCMessageTypeTagNull] || [type isEqualToString:PEOSCMessageTypeTagImpulse])
        status = NO;
    return status;
}

#pragma mark -

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ %@ %@", self.address, [self _typeTagString], @"ARGUMENTS"];
}

- (void)enumerateTypesAndArgumentsUsingBlock:(void (^)(id type, id argument, BOOL* stop))block {
    BOOL stop = NO;
    NSUInteger argIndex = 0;
    for (NSString* type in self.typeTags) {
        id argument = [PEOSCMessage typeRequiresArgument:type] ? [self.arguments objectAtIndex:argIndex++] : nil;
        block(type, argument, &stop);
        if (!stop)
            continue;
        break;
    }
}

#pragma mark -

- (BOOL)_isAddressValid {
    // NB - i think # is illegal as well due to blobs and likely ASCII-only as well
    // TODO - beef up via NSRegularExpression
    return self.address && [[self.address substringToIndex:1] isEqualToString:@"/"];
}

- (BOOL)_areTypeTagsValid {
    return [self _typeTagString] != nil;
}

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

        else if ([obj isEqualToString:PEOSCMessageTypeTagInteger])
            [string appendString:@"i"];
        else if ([obj isEqualToString:PEOSCMessageTypeTagFloat])
            [string appendString:@"f"];
        else if ([obj isEqualToString:PEOSCMessageTypeTagString])
            [string appendString:@"s"];
        else if ([obj isEqualToString:PEOSCMessageTypeTagBlob])
            [string appendString:@"b"];
        else if ([obj isEqualToString:PEOSCMessageTypeTagTrue])
            [string appendString:@"T"];
        else if ([obj isEqualToString:PEOSCMessageTypeTagFalse])
            [string appendString:@"F"];
        else if ([obj isEqualToString:PEOSCMessageTypeTagNull])
            [string appendString:@"N"];
        else if ([obj isEqualToString:PEOSCMessageTypeTagImpulse])
            [string appendString:@"I"];
        else if ([obj isEqualToString:PEOSCMessageTypeTagTimetag])
            [string appendString:@"t"];
    }];
    return string;
}

@end
