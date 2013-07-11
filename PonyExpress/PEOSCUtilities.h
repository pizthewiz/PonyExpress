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

extern const NTPTimestamp NTPTimestampImmediate;

static inline NTPTimestamp NTPTimestampMake(uint32_t seconds, uint32_t fractionalSeconds) {
    return (NTPTimestamp){seconds, fractionalSeconds};
}

static inline BOOL NTPTimestampEqualToTimestamp(NTPTimestamp timestamp1, NTPTimestamp timestamp2) {
    return timestamp1.seconds == timestamp2.seconds && timestamp1.fractionalSeconds == timestamp2.fractionalSeconds;
}

static inline BOOL NTPTimestampIsImmediate(NTPTimestamp timestamp) {
    return NTPTimestampEqualToTimestamp(timestamp, NTPTimestampImmediate);
}

@interface NSDate (PEAdditions)
+ (instancetype)OSCImmediate; // TODO - needs to be in public header
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
    NSData* subdata = [data subdataWithRange:range];
    NSString* string = [[NSString alloc] initWithData:subdata encoding:NSASCIIStringEncoding];
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

static inline NTPTimestamp readNTPTimestamp(NSData* data, NSUInteger start) {
    SInt32 seconds = readInteger(data, start);
    SInt32 fractionalSeconds = readInteger(data, start+4);
    NTPTimestamp timestamp = NTPTimestampMake(seconds, fractionalSeconds);
    return timestamp;
}

static inline NSDate* readDate(NSData* data, NSUInteger start) {
    NTPTimestamp timestamp = readNTPTimestamp(data, start);
    NSDate* date = [NSDate dateWithNTPTimestamp:timestamp];
    return date;
}

#pragma mark - DATA WRITERS

// TODO - for message and bundle to use

#pragma mark -

// via http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))
