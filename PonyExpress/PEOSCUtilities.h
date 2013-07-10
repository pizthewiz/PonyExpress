//
//  PEOSCUtilities.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 09 Jul 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark OSC VALUE CATEGORIES

// NB - OSC uses big-endian numerical values
@interface NSNumber (PEAdditions)
- (SInt32)oscInt;
- (CFSwappedFloat32)oscFloat;
@end

@interface NSString (PEAdditions)
- (NSString*)oscString;
@end

@interface NSData (PEAdditions)
- (NSData*)oscBlob;
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

// TODO - move to PEOSCUtilities.m?
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

extern const NTPTimestamp NTPTimestamp1970;
extern const NTPTimestamp NTPTimestampImmediate;

@interface NSDate (PEAdditions)
+ (instancetype)dateWithNTPTimestamp:(NTPTimestamp)timestamp;
- (NTPTimestamp)NTPTimestamp;
@end

#pragma mark - DATA READERS

static inline NSString* readString(NSData* data, NSUInteger start, NSUInteger length) {
    const char* buffer = [data bytes];
    NSUInteger end = start;
    while (end < length && buffer[end] != 0x00) {
        end++;
    }

    NSRange range = NSMakeRange(start, end-start);
    NSString* string = [[NSString alloc] initWithData:[data subdataWithRange:range] encoding:NSASCIIStringEncoding];
    return string;
}

static inline SInt32 readInteger(NSData* data, NSUInteger start) {
    void* b[4];
    [data getBytes:&b range:NSMakeRange(start, 4)];
    SInt32 value = CFSwapInt32BigToHost(*(uint32_t*)b);
    return value;
}

static inline Float32 readFloat(NSData* data, NSUInteger start) {
    void* b[4];
    [data getBytes:&b range:NSMakeRange(start, 4)];
    Float32 value = CFConvertFloat32SwappedToHost(*(CFSwappedFloat32*)b);
    return value;
}

static inline NSDate* readDate(NSData* data, NSUInteger start) {
    SInt32 seconds = readInteger(data, start);
    SInt32 fractionalSeconds = readInteger(data, start+4);

    NTPTimestamp timestamp = NTPTimestampMake(seconds, fractionalSeconds);
    return [NSDate dateWithNTPTimestamp:timestamp];
}
