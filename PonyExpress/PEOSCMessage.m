//
//  PEOSCMessage.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011-2012 Chorded Constructions. All rights reserved.
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

@interface NSString (PEAdditions)
- (NSString*)oscString;
@end
@implementation NSString (PEAdditions)
- (NSString*)oscString {
    // string + 1 null in termination + 0-3 nulls in padding for 4-byte alignment
    NSUInteger numberOfNulls = 4 - (self.length & 3);
    return [self stringByPaddingToLength:self.length+numberOfNulls withString:@"\0" startingAtIndex:0];
}
@end

@interface NSNumber (PEAdditions)
- (SInt32)oscInt;
- (CFSwappedFloat32)oscFloat;
@end
// OSC uses big-endian numerical values
@implementation NSNumber (PEAdditions)
- (SInt32)oscInt {
    SInt32 value = 0;
    CFNumberGetValue((__bridge CFNumberRef)self, kCFNumberSInt32Type, &value);
    SInt32 swappedValue = CFSwapInt32HostToBig(value);
    return swappedValue;
}
- (CFSwappedFloat32)oscFloat {
    Float32 value = 0;
    CFNumberGetValue((__bridge CFNumberRef)self, kCFNumberFloat32Type, &value);
    CFSwappedFloat32 swappedValue = CFConvertFloat32HostToSwapped(value);
    return swappedValue;
}
@end

@interface NSData (PEAdditions)
- (NSData*)oscBlob;
@end
@implementation NSData (PEAdditions)
- (NSData*)oscBlob {
    // int32 length + 8bit bytes + 0-3 nulls in padding for 4-byte alignment
    SInt32 swappedLength = [[NSNumber numberWithUnsignedInteger:self.length] oscInt];

    NSMutableData* data = [NSMutableData data];
    [data appendBytes:&swappedLength length:4];
    [data appendData:self];

    NSUInteger numberOfPaddingNulls = (4 - (self.length & 3)) & 3;
    char nullBytes[numberOfPaddingNulls];
    memset(nullBytes, 0, numberOfPaddingNulls);
    [data appendBytes:nullBytes length:numberOfPaddingNulls];

    return data;
}
@end


// yoinked and recrafted from Gavin Eadie's ios-ntp http://code.google.com/p/ios-ntp/
// NB - not perfectly symmetrical, this evaluates to NO:
//  NSDate* now = [NSDate date]; [now isEqualToDate:[NSDate dateWithNTPTimestamp:[now NTPTimestamp]];
struct NTPTimestamp {
    uint32_t seconds;
    uint32_t fractionalSeconds;
};
typedef struct NTPTimestamp NTPTimestamp;

static inline NTPTimestamp NTPTimestampMake(uint32_t seconds, uint32_t fractionalSeconds) {
    return (NTPTimestamp){seconds, fractionalSeconds};
}

static NSTimeInterval NTPTimestampDifference(NTPTimestamp start, NTPTimestamp end) {
    int a;
    unsigned int b;
    a = end.seconds - start.seconds;
    if (end.fractionalSeconds >= start.fractionalSeconds) {
        b = end.fractionalSeconds - start.fractionalSeconds;
    } else {
        b = start.fractionalSeconds - end.fractionalSeconds;
        b = ~b;
        a -= 1;
    }

    return a + b / 4294967296.0; // 2^32
}

// 1970 - 1900 in seconds 2,208,988,800 | First day UNIX
// 1 Jan 1972 : 2,272,060,800 | First day UTC
#define JAN_1970 0x83aa7e80
static NTPTimestamp NTPTimestamp1970 = {JAN_1970, 0};    // network time for 1 January 1970, GMT
// static NTPTimestamp NTPTimestampImmediate = {0, 1};

@interface NSDate (PEAdditions)
+ (id)dateWithNTPTimestamp:(NTPTimestamp)timestamp;
- (NTPTimestamp)NTPTimestamp;
@end
@implementation NSDate (PEAdditions)
+ (id)dateWithNTPTimestamp:(NTPTimestamp)timestamp {
    return [NSDate dateWithTimeIntervalSince1970:NTPTimestampDifference(NTPTimestamp1970, timestamp)];
}
- (NTPTimestamp)NTPTimestamp {
    double integerValue;
    double fractionalValue = modf([self timeIntervalSince1970], &integerValue);
    fractionalValue *= 4294967296.0;
    return NTPTimestampMake(JAN_1970 + integerValue, fractionalValue);
}
@end

static NSString* readString(NSData* data, NSUInteger start, NSUInteger length) {
    const char* buffer = [data bytes];
    NSUInteger end = start;
    while (end < length && buffer[end] != 0x00) {
        end++;
    }

    NSRange range = NSMakeRange(start, end-start);
    NSString* string = [[NSString alloc] initWithData:[data subdataWithRange:range] encoding:NSASCIIStringEncoding];
    return string;
}

static SInt32 readInteger(NSData* data, NSUInteger start) {
    void* b[4];
    [data getBytes:&b range:NSMakeRange(start, 4)];
    SInt32 value = CFSwapInt32BigToHost(*(uint32_t*)b);
    return value;
}

static Float32 readFloat(NSData* data, NSUInteger start) {
    void* b[4];
    [data getBytes:&b range:NSMakeRange(start, 4)];
    Float32 value = CFConvertFloat32SwappedToHost(*(CFSwappedFloat32*)b);
    return value;
}

static NSDate* readDate(NSData* data, NSUInteger start) {
    SInt32 seconds = readInteger(data, start);
    SInt32 fractionalSeconds = readInteger(data, start+4);

    NTPTimestamp timestamp = NTPTimestampMake(seconds, fractionalSeconds);
    return [NSDate dateWithNTPTimestamp:timestamp];
}

#pragma mark - PEOSCMESSAGE

@implementation PEOSCMessage

+ (id)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments {
    id message = [[[self class] alloc] initWithAddress:address typeTags:typeTags arguments:arguments];
    return message;
}

- (id)initWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments {
    self = [super init];
    if (self) {
        self.address = address;
        self.typeTags = typeTags;
        self.arguments = arguments;
    }
    return self;
}

+ (id)messageWithData:(NSData*)data {
    id message = [[[self class] alloc] initWithData:data];
    return message;
}

- (id)initWithData:(NSData*)data {
    self = [super init];
    if (self) {
        NSUInteger length = [data length];
        NSUInteger start = 0;

        // address
        NSString* addressString = readString(data, start, length);
        // naïve validation
        if (!addressString || [addressString isEqualToString:@""]) {
            CCErrorLog(@"ERROR - invalid empty address, message dropped");
            return nil;
        }
        if ([addressString isEqualToString:@"#bundle"]) {
            CCErrorLog(@"ERROR - OSC bundles not available, message dropped");
            return nil;
        }
        self.address = addressString;


        // type tags
        start += addressString.length + 4 - (addressString.length & 3);
        NSString* typeTagString = readString(data, start, length);

        // NB - this is probably too aggressive
        NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"^,[ifsbTFNIt]*$" options:0 error:NULL];
        NSTextCheckingResult* result = [reg firstMatchInString:typeTagString options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, typeTagString.length)];
        if (!result) {
            // BAIL
            CCErrorLog(@"ERROR - invalid type tag string, message dropped");
            return nil;
        }

        typeTagString = [typeTagString substringFromIndex:1];
        if ([typeTagString isEqualToString:@""]) {
            // address-only messsage
            return self;
        }

        NSMutableArray* list = [NSMutableArray arrayWithCapacity:typeTagString.length];
        for (NSUInteger idx = 0; idx < typeTagString.length; idx++) {
            NSString* code = [typeTagString substringWithRange:NSMakeRange(idx, 1)];
            if (!code) {
                continue;
            }
            [list addObject:[[self class] _typeForCode:code]];
        }
        self.typeTags = list;

        // arguments
        start += typeTagString.length + 4 - (typeTagString.length & 3);
        list = [NSMutableArray array];
        for (NSString* type in self.typeTags) {
            if (![[self class] argumentRequiredByType:type]) {
                continue;
            }

            if ([type isEqualToString:PEOSCMessageTypeTagInteger]) {
                if (start+4 > length) {
                    CCErrorLog(@"ERROR - cannot read int from data, out of range");
                    return nil;
                }
                SInt32 value = readInteger(data, start);
                [list addObject:[NSNumber numberWithInt:value]];
                start += 4;
            } else if ([type isEqualToString:PEOSCMessageTypeTagFloat]) {
                if (start+4 > length) {
                    CCErrorLog(@"ERROR - cannot read float from data, out of range");
                    return nil;
                }
                Float32 value = readFloat(data, start);
                [list addObject:[NSNumber numberWithFloat:value]];
                start += 4;
            } else if ([type isEqualToString:PEOSCMessageTypeTagString]) {
                NSString* string = readString(data, start, length);
                if (!string) {
                    CCErrorLog(@"ERROR - failed to read string");
                    return nil;
                }
                [list addObject:string];
                start += string.length + 4 - (string.length & 3);
            } else if ([type isEqualToString:PEOSCMessageTypeTagBlob]) {
                SInt32 blobLength = readInteger(data, start);
                if (start+blobLength > length) {
                    CCErrorLog(@"ERROR - failed to read data blob, length is out of range");
                    return nil;
                }
                start += 4;
                NSData* d = [data subdataWithRange:NSMakeRange(start, blobLength)];
                if (!d) {
                    CCErrorLog(@"ERROR - failed to read data blob");
                    return nil;
                }
                [list addObject:d];
                start += d.length + 4 - (d.length & 3);
            } else if ([type isEqualToString:PEOSCMessageTypeTagTimetag]) {
                NSDate* date = readDate(data, start);
                [list addObject:date];
                start += 8;
            } else {
                CCDebugLog(@"unrecognized type '%@', bailing", type);
                // BAIL
                return nil;
            }
        }
        self.arguments = list;
    }
    return self;
}

#pragma mark - TYPES

+ (BOOL)argumentRequiredByType:(NSString*)type {
    BOOL status = YES;
    if ([type isEqualToString:PEOSCMessageTypeTagTrue] || [type isEqualToString:PEOSCMessageTypeTagFalse] || [type isEqualToString:PEOSCMessageTypeTagNull] || [type isEqualToString:PEOSCMessageTypeTagImpulse]) {
        status = NO;
    }
    return status;
}

+ (NSString*)displayNameForType:(NSString*)type {
    NSString* name = nil;
    // TODO - move to strings file
    if ([type isEqualToString:PEOSCMessageTypeTagInteger])
        name = @"Integer";
    else if ([type isEqualToString:PEOSCMessageTypeTagFloat])
        name = @"Float";
    else if ([type isEqualToString:PEOSCMessageTypeTagString])
        name = @"String";
    else if ([type isEqualToString:PEOSCMessageTypeTagBlob])
        name = @"Blob";
    else if ([type isEqualToString:PEOSCMessageTypeTagTrue])
        name = @"True";
    else if ([type isEqualToString:PEOSCMessageTypeTagFalse])
        name = @"False";
    else if ([type isEqualToString:PEOSCMessageTypeTagNull])
        name = @"Null";
    else if ([type isEqualToString:PEOSCMessageTypeTagImpulse])
        name = @"Impulse";
    else if ([type isEqualToString:PEOSCMessageTypeTagTimetag])
        name = @"Timetag";
    return name;
}

+ (NSString*)_codeForType:(NSString*)type {
    NSString* code = nil;
    if ([type isEqualToString:PEOSCMessageTypeTagInteger])
        code = @"i";
    else if ([type isEqualToString:PEOSCMessageTypeTagFloat])
        code = @"f";
    else if ([type isEqualToString:PEOSCMessageTypeTagString])
        code = @"s";
    else if ([type isEqualToString:PEOSCMessageTypeTagBlob])
        code = @"b";
    else if ([type isEqualToString:PEOSCMessageTypeTagTrue])
        code = @"T";
    else if ([type isEqualToString:PEOSCMessageTypeTagFalse])
        code = @"F";
    else if ([type isEqualToString:PEOSCMessageTypeTagNull])
        code = @"N";
    else if ([type isEqualToString:PEOSCMessageTypeTagImpulse])
        code = @"I";
    else if ([type isEqualToString:PEOSCMessageTypeTagTimetag])
        code = @"t";
    else
        CCDebugLog(@"unrecognized type %@", type);
    return code;
}

+ (NSString*)_typeForCode:(NSString*)code {
    NSString* type = nil;
    if ([code isEqualToString:@"i"])
        type = PEOSCMessageTypeTagInteger;
    else if ([code isEqualToString:@"f"])
        type = PEOSCMessageTypeTagFloat;
    else if ([code isEqualToString:@"s"])
        type = PEOSCMessageTypeTagString;
    else if ([code isEqualToString:@"b"])
        type = PEOSCMessageTypeTagBlob;
    else if ([code isEqualToString:@"T"])
        type = PEOSCMessageTypeTagTrue;
    else if ([code isEqualToString:@"F"])
        type = PEOSCMessageTypeTagFalse;
    else if ([code isEqualToString:@"N"])
        type = PEOSCMessageTypeTagNull;
    else if ([code isEqualToString:@"I"])
        type = PEOSCMessageTypeTagImpulse;
    else if ([code isEqualToString:@"t"])
        type = PEOSCMessageTypeTagTimetag;
    else
        CCDebugLog(@"unrecognized code %@", code);
    return type;
}

#pragma mark -

- (NSString*)description {
    NSMutableString* argDescription = [NSMutableString string];
    [self.arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        BOOL isFirstOrLastArg = idx == 0 || idx+1 > self.arguments.count;
        NSString* description = nil;
        if ([obj isKindOfClass:[NSData class]] && [(NSData*)obj length] > 4 * 1024) {
            description = @"<BINARY DATA TOO LARGE TO PRINT>";
        } else {
            description = [obj description];
        }

        [argDescription appendString:[NSString stringWithFormat:@"%@%@", (isFirstOrLastArg ? @"" : @", "), description]];
    }];
    NSString* typeTagString = self.typeTags.count ? [self _typeTagString] : @"(–)";
    return [NSString stringWithFormat:@"<%@: %@ %@ [%@]>", NSStringFromClass([self class]), self.address, typeTagString, argDescription];
}

- (void)enumerateTypesAndArgumentsUsingBlock:(void (^)(id type, id argument, BOOL* stop))block {
    BOOL stop = NO;
    NSUInteger argIndex = 0;
    for (NSString* type in self.typeTags) {
        id argument = [PEOSCMessage argumentRequiredByType:type] ? self.arguments[argIndex++] : nil;
        block(type, argument, &stop);
        if (stop) {
            break;
        }
    }
}

#pragma mark - PRIVATE

- (BOOL)_isAddressValid {
    BOOL status = YES;

    // check for leading / and lack of spaces
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:@"^/(\\S*)$" options:NSRegularExpressionCaseInsensitive error:NULL];
    NSUInteger matches = [reg numberOfMatchesInString:self.address options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, self.address.length)];
    status = matches == 1;

    // check more involved stuff
    if (status) {
        NSArray* components = [self.address componentsSeparatedByString:@"/"];
        for (NSString* component in components) {
            NSUInteger length = component.length;
            unichar buffer[length + 1];
            [component getCharacters:buffer range:NSMakeRange(0, length)];

            NSUInteger curleyBraceStack = 0;
            NSUInteger bracketStack = 0;
            for (NSUInteger idx = 0; idx < length; idx++) {
                unichar c = buffer[idx];
                if (c == '{') {
                    // disallow nested lists or ranges
                    if (curleyBraceStack != 0 || bracketStack != 0) {
                        status = NO;
                        goto bail;
                    }
                    curleyBraceStack++;
                } else if (c == '}') {
                    if (curleyBraceStack < 1) {
                        status = NO;
                        goto bail;
                    }
                    curleyBraceStack--;
                } else if (c == ',') {
                    // disallow comma except within list
                    if (curleyBraceStack < 1) {
                        status = NO;
                        goto bail;
                    }
                }

                else if (c == '[') {
                    // disallow nested lists or ranges
                    if (curleyBraceStack != 0 || bracketStack != 0) {
                        status = NO;
                        goto bail;
                    }
                    bracketStack++;
                } else if (c == ']') {
                    if (bracketStack < 1) {
                        status = NO;
                        goto bail;
                    }
                    bracketStack--;
                } else if (c == '-') {
                    // disallow dash except in range
                    if (bracketStack < 1) {
                        status = NO;
                        goto bail;
                    }
                }
            }

            // check for balance
            if (curleyBraceStack != 0 || bracketStack != 0) {
                status = NO;
                goto bail;
            }
        }
    }

bail:
    return status;
}

- (BOOL)_areTypeTagsValid {
    __block BOOL status = YES;
    [self.typeTags enumerateObjectsUsingBlock:^(id type, NSUInteger idx, BOOL* stop) {
        if (![type isKindOfClass:[NSString class]] || ! [[self class] _codeForType:type]) {
            status = NO;
            *stop = YES;
        }
    }];
    return status;
}

- (BOOL)_areArgumentsValidGivenTypeTags {
    // check proper number of arguments
    NSUInteger numberOfArguments = 0;
    for (NSString* type in self.typeTags) {
        if (![PEOSCMessage argumentRequiredByType:type])
            continue;
        numberOfArguments++;
    }
    if (self.arguments.count != numberOfArguments)
        return NO;

    __block BOOL status = YES;
    [self enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL* stop) {
        if ([PEOSCMessage argumentRequiredByType:type]) {
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
            } else if ([type isEqualToString:PEOSCMessageTypeTagTimetag] && ![argument isKindOfClass:[NSDate class]]) {
                CCDebugLog(@"Timetag arguments should be represented via NSDate");
                status = NO;
                *stop = YES;
            }
        }
    }];
    return status;
}

- (NSString*)_typeTagString {
    __block NSMutableString* string = [NSMutableString stringWithString:@","];
    [self.typeTags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        // catch interlopers
        if (![obj isKindOfClass:[NSString class]]) {
            string = nil;
            *stop = YES;
        } else {
            NSString* code = [[self class] _codeForType:obj];
            if (!code) {
                string = nil;
                *stop = YES;
            }
            [string appendString:code];
        }
    }];
    return string;
}

- (void)_printDataBuffer:(NSData*)data {
    // yokined from CoreOSC:
    //  https://github.com/mirek/CoreOSC/blob/master/CoreOSC/CoreOSC.c
    const char* buffer = [data bytes];
    for (NSUInteger idx = 0; idx < data.length; idx++) {
        if (idx > 0 && !(idx % 4))
            printf(" ");
        if (buffer[idx] > 0x1f)
            printf("  %c", buffer[idx]);
        else
            printf(" __");
    }
    printf("\n");
    for (NSUInteger idx = 0; idx < data.length; idx++) {
        if (idx > 0 && !(idx % 4))
            printf(" ");
        printf(" %02x", (unsigned char)buffer[idx]);        
    }
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

    // TODO - it would be nice to have a value class that can serialize then create a message from address and values
    __block NSMutableData* argumentData = [NSMutableData data];
    [self enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL* stop) {
        if (![[self class] argumentRequiredByType:type]) {
            return;
        }

        if ([type isEqualToString:PEOSCMessageTypeTagInteger]) {
            SInt32 swappedValue = [argument oscInt];
            [argumentData appendBytes:&swappedValue length:4];
        } else if ([type isEqualToString:PEOSCMessageTypeTagFloat]) {
            CFSwappedFloat32 swappedValue = [argument oscFloat];
            [argumentData appendBytes:&swappedValue length:4];
        } else if ([type isEqualToString:PEOSCMessageTypeTagString]) {
            [argumentData appendData:[[argument oscString] dataUsingEncoding:NSASCIIStringEncoding]];
        } else if ([type isEqualToString:PEOSCMessageTypeTagBlob]) {
            [argumentData appendData:[argument oscBlob]];
        } else if ([type isEqualToString:PEOSCMessageTypeTagTimetag]) {
            NTPTimestamp timestamp = [argument NTPTimestamp];
            SInt32 swappedValue = [[NSNumber numberWithInt:timestamp.seconds] oscInt];
            [argumentData appendBytes:&swappedValue length:4];
            swappedValue = [[NSNumber numberWithInt:timestamp.fractionalSeconds] oscInt];
            [argumentData appendBytes:&swappedValue length:4];
        }
    }];

    NSMutableData* data = [NSMutableData data];
    [data appendData:addressData];
    [data appendData:typeTagData];
    [data appendData:argumentData];

#ifdef LOGGING
    // only dump the buffer when less than 4k
    if (data.length < 4 * 1024)
        [self _printDataBuffer:data];
#endif

    return data;
}

@end
