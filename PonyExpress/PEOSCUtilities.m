//
//  PEOSCUtilities.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 09 Jul 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCUtilities.h"

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

#pragma mark - TIMETAG

// 1970 - 1900 in seconds 2,208,988,800 | First day UNIX
// 1 Jan 1972 : 2,272,060,800 | First day UTC
#define JAN_1970 0x83aa7e80

// network time for 1 January 1970, GMT
const NTPTimestamp NTPTimestamp1970 = {JAN_1970, 0};
// OSC's right now
const NTPTimestamp NTPTimestampImmediate = {0, 1};

@implementation NSDate (PEAdditions)
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
