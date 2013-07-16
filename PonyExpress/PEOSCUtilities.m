//
//  PEOSCUtilities.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 09 Jul 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCUtilities.h"
#import "PEOSCUtilities-Internal.h"

#pragma mark INTEGER & FLOAT

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

#pragma mark - STRING

@implementation NSString (PEAdditions)
- (NSString*)oscString {
    // string + 1 null in termination + 0-3 nulls in padding for 4-byte alignment
    NSUInteger numberOfNulls = 4 - (self.length & 3);
    return [self stringByPaddingToLength:self.length+numberOfNulls withString:@"\0" startingAtIndex:0];
}
@end

#pragma mark - BLOB

@implementation NSData (PEAdditions)
- (NSData*)oscBlob {
    // int32 length + 8bit bytes + 0-3 nulls in padding for 4-byte alignment
    NSMutableData* data = [NSMutableData data];
    [data appendInteger:@(self.length)];
    [data appendData:self];

    NSUInteger numberOfPaddingNulls = (4 - (self.length & 3)) & 3;
    char nullBytes[numberOfPaddingNulls];
    memset(nullBytes, 0, numberOfPaddingNulls);
    [data appendBytes:nullBytes length:numberOfPaddingNulls];

    return data;
}
@end

#pragma mark - TIMETAG

// 1970 - 1900 in seconds 2,208,988,800 | First day UNIX
// 1 Jan 1972 : 2,272,060,800 | First day UTC
#define JAN_1970 0x83aa7e80

// network time for 1 January 1970, GMT
const NTPTimestamp NTPTimestamp1970 = {JAN_1970, 0};
// OSC's right now
const NTPTimestamp NTPTimestampImmediate = {0, 1};

static inline NSTimeInterval NTPTimestampDifference(NTPTimestamp start, NTPTimestamp end) {
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

@implementation NSDate (PEAdditions)
+ (instancetype)OSCImmediate {
    static NSDate* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self class] dateWithNTPTimestamp:NTPTimestampImmediate];
        // NB - could swizzle a pure accessor in place
    });
    return sharedInstance;
}
+ (instancetype)dateWithNTPTimestamp:(NTPTimestamp)timestamp {
    return [NSDate dateWithTimeIntervalSince1970:NTPTimestampDifference(NTPTimestamp1970, timestamp)];
}
- (NTPTimestamp)NTPTimestamp {
    double integerValue;
    double fractionalValue = modf([self timeIntervalSince1970], &integerValue);
    fractionalValue *= 4294967296.0;
    return NTPTimestampMake(JAN_1970 + integerValue, fractionalValue);
}
@end

#pragma mark - DATA READERS

@implementation NSData (PEDataReadingExtensions)

- (NSNumber*)readIntegerAtOffset:(NSUInteger)offset {
    SInt32 value = readInteger(self, offset);
    return [NSNumber numberWithInt:value];
}

- (NSNumber*)readFloatAtOffset:(NSUInteger)offset {
    Float32 value = readFloat(self, offset);
    return [NSNumber numberWithFloat:value];
}

- (NSString*)readStringAtOffset:(NSUInteger)offset {
    NSString* string = readString(self, offset, [self length]);
    return string;
}

- (NSData*)readBlobAtOffset:(NSUInteger)offset length:(NSUInteger)length {
    NSData* data = [self subdataWithRange:NSMakeRange(offset, length)];
    return data;
}

- (NSDate*)readTimeTagAtOffset:(NSUInteger)offset {
    NTPTimestamp timestamp = readNTPTimestamp(self, offset);
    NSDate* timeTag = NTPTimestampIsImmediate(timestamp) ? [NSDate OSCImmediate] : [NSDate dateWithNTPTimestamp:timestamp];
    return timeTag;
}

// TODO - make multi-line and byte-gap configurable
- (void)prettyPrint {
    // yokined from CoreOSC:
    //  https://github.com/mirek/CoreOSC/blob/master/CoreOSC/CoreOSC.c
    const char* buffer = [self bytes];
    for (NSUInteger idx = 0; idx < [self length]; idx++) {
        if (idx > 0 && !(idx % 4)) {
            printf(" ");
        }
        if (buffer[idx] > 0x1f) {
            printf("  %c", buffer[idx]);
        } else {
            printf(" __");
        }
    }
    printf("\n");
    for (NSUInteger idx = 0; idx < [self length]; idx++) {
        if (idx > 0 && !(idx % 4)) {
            printf(" ");
        }
        printf(" %02x", (unsigned char)buffer[idx]);
    }
    printf("\n");
}


@end

#pragma mark - DATA WRITERS

@implementation NSMutableData (PEDataWritingExtensions)

- (void)appendInteger:(NSNumber*)number {
    SInt32 swappedValue = [number oscInt];
    [self appendBytes:&swappedValue length:4];
}

- (void)appendFloat:(NSNumber*)number {
    CFSwappedFloat32 swappedValue = [number oscFloat];
    [self appendBytes:&swappedValue length:4];
}

- (void)appendString:(NSString*)string {
    NSString* value = [string oscString];
    [self appendData:[value dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)appendBlob:(NSData*)blob {
    [self appendData:[blob oscBlob]];
}

- (void)appendTimeTag:(NSDate*)date {
    NTPTimestamp timestamp = [date isEqual:[NSDate OSCImmediate]] ? NTPTimestampImmediate : [date NTPTimestamp];
    SInt32 swappedValue = [[NSNumber numberWithInt:timestamp.seconds] oscInt];
    [self appendBytes:&swappedValue length:4];
    swappedValue = [[NSNumber numberWithInt:timestamp.fractionalSeconds] oscInt];
    [self appendBytes:&swappedValue length:4];
}

@end
