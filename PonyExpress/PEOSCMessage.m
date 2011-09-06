//
//  PEOSCMessage.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "PonyExpress-Internal.h"

NSString* const PEOSCMessageTypeTagInteger = @"PEOSCMessageTypeTagInteger";
NSString* const PEOSCMessageTypeTagFloat = @"PEOSCMessageTypeTagFloat";
NSString* const PEOSCMessageTypeTagString = @"PEOSCMessageTypeTagString";
NSString* const PEOSCMessageTypeTagBlob = @"PEOSCMessageTypeTagBlob";
NSString* const PEOSCMessageTypeTagTrue = @"PEOSCMessageTypeTagTrue";
NSString* const PEOSCMessageTypeTagFalse = @"PEOSCMessageTypeTagFalse";
NSString* const PEOSCMessageTypeTagNull = @"PEOSCMessageTypeTagNull";
NSString* const PEOSCMessageTypeTagImpulse = @"PEOSCMessageTypeTagImpulse";
NSString* const PEOSCMessageTypeTagTimetag = @"PEOSCMessageTypeTagTimetag";

#pragma mark OSC VALUE CATEGORIES

@interface NSString(PEAdditions)
- (NSString*)oscString;
@end
@implementation NSString(PEAdditions)
- (NSString*)oscString {
    NSUInteger numberOfNulls = 4 - (self.length & 3);
    return [self stringByPaddingToLength:self.length+numberOfNulls withString:@"\0" startingAtIndex:0];
}
@end

@interface NSNumber(PEAdditions)
- (SInt32)oscInt;
- (CFSwappedFloat32)oscFloat;
@end
// OSC uses big-endian numerical values
@implementation NSNumber(PEAdditions)
- (SInt32)oscInt {
    SInt32 value = 0;
    CFNumberGetValue((CFNumberRef)self, kCFNumberSInt32Type, &value);
    SInt32 swappedValue = CFSwapInt32HostToBig(value);
    return swappedValue;
}
- (CFSwappedFloat32)oscFloat {
    Float32 value = 0;
    CFNumberGetValue((CFNumberRef)self, kCFNumberFloat32Type, &value);
    CFSwappedFloat32 swappedValue = CFConvertFloat32HostToSwapped(value);
    return swappedValue;
}
@end

//@interface NSData(PEAdditions)
//- (NSData*)oscBlob;
//@end
//@implementation NSData(PEAdditions)
//- (NSData*)oscBlob {
//    // int32 length + 8bit bytes with 0-3 nulls in termination
//    NSUInteger numberOfNulls = 4 - (self.length & 3);
//    NSUInteger totalLength = 4 + self.length + numberOfNulls;
//    SInt32 swappedTotalLength = [[NSNumber numberWithInt:totalLength] oscInt];
//
////    [argumentData appendBytes:&swappedValue length:4];
//
//    return nil;
//}
//@end

#pragma mark - PEOSCMESSAGE

@implementation PEOSCMessage

@synthesize address, typeTags, arguments;

+ (id)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments {
    id message = [[PEOSCMessage alloc] initWithAddress:address typeTags:typeTags arguments:arguments];
    return [message autorelease];
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
    NSMutableString* argDescription = [NSMutableString string];
    [self.arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == 0 || idx+1 > self.arguments.count)
            [argDescription appendString:[NSString stringWithFormat:@"%@", [obj description]]];
        else
            [argDescription appendString:[NSString stringWithFormat:@", %@", [obj description]]];            
    }];
    return [NSString stringWithFormat:@"<%@: %@ %@ [%@]>", NSStringFromClass([self class]), self.address, [self _typeTagString], argDescription];
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

#pragma mark - PRIVATE

- (BOOL)_isAddressValid {
    // TODO - beef up via NSRegularExpression -- check for balanced [] and {}
    return self.address && [[self.address substringToIndex:1] isEqualToString:@"/"];
}

- (BOOL)_areTypeTagsValid {
    return [self _typeTagString] != nil;
}

- (BOOL)_areArgumentsValidGivenTypeTags {
    // check proper number of arguments
    NSUInteger numberOfArguments = 0;
    for (NSString* type in self.typeTags) {
        if (![PEOSCMessage typeRequiresArgument:type])
            continue;
        numberOfArguments++;
    }
    if (self.arguments.count != numberOfArguments)
        return NO;

    __block BOOL status = YES;
    [self enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL *stop) {
        if ([PEOSCMessage typeRequiresArgument:type]) {
            if (([type isEqualToString:PEOSCMessageTypeTagInteger] || [type isEqualToString:PEOSCMessageTypeTagFloat]) && ![argument isKindOfClass:[NSNumber class]]) {
                CCDebugLog(@"Integer and Float arguments should be represented via NSNumber");
                status = NO;
                *stop = YES;
            } else if ([type isEqualToString:PEOSCMessageTypeTagString] && ![argument isKindOfClass:[NSString class]]) {
                CCDebugLog(@"String arguments should be represented via NSString");
                status = NO;
                *stop = YES;
            } else if ([type isEqualToString:PEOSCMessageTypeTagBlob] && ![argument isKindOfClass:[NSData class]]) {
                CCDebugLog(@"Blob arguments should be represented via NSData");
                status = NO;
                *stop = YES;
            }
//            else if ([type isEqualToString:PEOSCMessageTypeTagTimetag] && ???) {
//                status = NO;
//                *stop = YES;
//            }
        }
    }];
    return status;
}

- (NSString*)_typeTagString {
    if (!self.typeTags.count)
        return nil;

    __block NSMutableString* string = [NSMutableString stringWithString:@","];
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

- (void)_printDataBuffer:(NSData*)data {
    // yokined from CoreOSC
    //  https://github.com/mirek/CoreOSC/blob/master/CoreOSC/CoreOSC.c
    const char* buffer = [data bytes];
    for (NSUInteger idx = 0; idx < data.length; idx++) {
        if (buffer[idx] > 0x1f)
            printf("  %c", buffer[idx]);
        else
            printf(" __");
    }
    printf("\n");
    for (NSUInteger idx = 0; idx < data.length; idx++)
        printf(" %02x", (unsigned char)buffer[idx]);
    printf("\n");
}

- (NSData*)_data {
    // validate
    if (![self _isAddressValid]) {
        CCErrorLog(@"ERROR - invalid address: %@", self.address);
        return nil;
    }
    if (![self _areTypeTagsValid]) {
        CCErrorLog(@"ERROR - invalid type tags: %@", self.typeTags);
        return nil;
    }
    if (![self _areArgumentsValidGivenTypeTags]) {
        CCErrorLog(@"ERROR - invalid arguments: %@", self.arguments);
        return nil;
    }

    NSData* addressData = [[self.address oscString] dataUsingEncoding:NSASCIIStringEncoding];
    NSData* typeTagData = [[[self _typeTagString] oscString] dataUsingEncoding:NSASCIIStringEncoding];
    __block NSMutableData* argumentData = [[NSMutableData alloc] init];

    // TODO - it would be nice to have a value class that can serialize then create a message from address and values
    [self enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL *stop) {
        if (![[self class] typeRequiresArgument:type])
            return;
        if ([type isEqualToString:PEOSCMessageTypeTagInteger]) {
            SInt32 swappedValue = [argument oscInt];
            [argumentData appendBytes:&swappedValue length:4];
        } else if ([type isEqualToString:PEOSCMessageTypeTagFloat]) {
            CFSwappedFloat32 swappedValue = [argument oscFloat];
            [argumentData appendBytes:&swappedValue length:4];
        } else if ([type isEqualToString:PEOSCMessageTypeTagString]) {
            [argumentData appendData:[[argument oscString] dataUsingEncoding:NSASCIIStringEncoding]];
        } else if ([type isEqualToString:PEOSCMessageTypeTagBlob]) {
//            [argumentData appendData:[argumentData oscBlob]];
            CCWarningLog(@"WARNING - cannot serialize Blob type, not yet supported");
        } else if ([type isEqualToString:PEOSCMessageTypeTagTimetag]) {
            CCWarningLog(@"WARNING - cannot serialize Timetag type, not yet supported");
        }
    }];

//    NSMutableData* data = [NSMutableData dataWithLength:(addressData.length + typeTagData.length + argumentData.length)];
    NSMutableData* data = [NSMutableData data];
    [data appendData:addressData];
    [data appendData:typeTagData];
    [data appendData:argumentData];
    [argumentData release];

//    CCDebugLog(@"%@", data);
    [self _printDataBuffer:data];
    return data;
}

@end
