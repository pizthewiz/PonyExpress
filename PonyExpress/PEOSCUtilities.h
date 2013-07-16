//
//  PEOSCUtilities.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 09 Jul 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface NSData (PEDataReadingExtensions)
- (NSNumber*)readIntegerAtOffset:(NSUInteger)offset;
- (NSNumber*)readFloatAtOffset:(NSUInteger)offset;
- (NSString*)readStringAtOffset:(NSUInteger)offset;
- (NSData*)readBlobAtOffset:(NSUInteger)offset length:(NSUInteger)length;
- (NSDate*)readTimeTagAtOffset:(NSUInteger)offset;
@end

#pragma mark - DATA WRITERS

@interface NSMutableData (PEDataWritingExtensions)
- (void)appendInteger:(NSNumber*)number;
- (void)appendFloat:(NSNumber*)number;
- (void)appendString:(NSString*)string;
- (void)appendBlob:(NSData*)blob;
- (void)appendTimeTag:(NSDate*)date;
@end

#pragma mark -

// via http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))
