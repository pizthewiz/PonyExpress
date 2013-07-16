//
//  PEOSCUtilities-Internal.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 15 Jul 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEOSCUtilities.h"

// raw data readers
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
