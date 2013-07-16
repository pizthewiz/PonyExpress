//
//  PEOSCBundle.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 24 Mar 2013.
//  Copyright (c) 2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCBundle.h"
#import "PEOSCBundle-Private.h"
#import "PEOSCUtilities.h"
#import "PEOSCUtilities-Internal.h"
#import "PEOSCMessage-Private.h"
#import "PonyExpress-Internal.h"

@implementation PEOSCBundle

+ (instancetype)bundleWithElements:(NSArray*)elements timeTag:(NSDate*)timeTag {
    id bundle = [[[self class] alloc] initWithElements:elements timeTag:timeTag];
    return bundle;
}

- (instancetype)initWithElements:(NSArray*)elements timeTag:(NSDate*)timeTag {
    self = [super init];
    if (self) {
        self.elements = elements;
        self.timeTag = timeTag;
    }
    return self;
}

+ (instancetype)bundleWithData:(NSData*)data {
    id bundle = [[[self class] alloc] initWithData:data];
    return bundle;
}

- (instancetype)initWithData:(NSData*)data {
    self = [super init];
    if (self) {
        NSUInteger length = [data length];
        NSUInteger start = 0;

        // check for bundle marker
        if (![PEOSCBundle _dataIsLikelyBundle:data]) {
            CCErrorLog(@"ERROR - missing bundle marker, bundle dropped");
            return nil;
        }
        start += 8;

        // read timetag
        self.timeTag = [data readTimeTagAtOffset:start];
        start += 8;

        // grab elements
        NSMutableArray* elements = [NSMutableArray array];
        while (start != length) {
            // read element length
            SInt32 value = readInteger(data, start);
            if (start+value > length) {
                CCErrorLog(@"ERROR - element length out of bundle data range, bundle dropped");
                return nil;
            }
            start += 4;

            // divine element type
            NSData* subdata = [data subdataWithRange:NSMakeRange(start, value)];
            if ([PEOSCBundle _dataIsLikelyBundle:subdata]) {
                PEOSCBundle* bundle = [PEOSCBundle bundleWithData:subdata];
                if (bundle) {
                    [elements addObject:bundle];
                }
            } else {
                PEOSCMessage* message = [PEOSCMessage messageWithData:subdata];
                if (message) {
                    [elements addObject:message];
                }
            }
            start += value;
        }
        self.elements = elements;
    }
    return self;
}

#pragma mark -

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PEOSCBundle class]]) {
        return NO;
    }
    return [object hash] == [self hash];
}

- (NSUInteger)hash {
    return NSUINTROTATE([self.elements hash], NSUINT_BIT / 2) ^ [self.timeTag hash];
}

#pragma mark - PRIVATE

+ (BOOL)_dataIsLikelyBundle:(NSData*)data {
    if ([data length] < 8) {
        return NO;
    }
    // check first 8 bytes for #bundle marker
    NSString* string = readString(data, 0, 8);
    return [string isEqualToString:@"#bundle"];
}

- (BOOL)_isValid {
    return [self _areElementsValid];
}

- (BOOL)_areElementsValid {
    __block BOOL status = YES;
    [self.elements enumerateObjectsUsingBlock:^(id element, NSUInteger idx, BOOL* stop) {
        if (!([element isKindOfClass:[PEOSCMessage class]] || [element isKindOfClass:[PEOSCBundle class]])) {
            status = NO;
            *stop = YES;
        } else if (!([element respondsToSelector:@selector(_isValid)] || [element performSelector:@selector(_isValid)])) {
            status = NO;
            *stop = YES;
        }
    }];
    return status;
}

- (NSData*)_data {
    // validate
    if (![self _areElementsValid]) {
        CCErrorLog(@"ERROR - invalid elements: %@", self.elements);
        return nil;
    }

    __block NSMutableData* data = [NSMutableData data];

    // #bundle
    [data appendString:@"#bundle"];

    // timeTag
    [data appendTimeTag:(!self.timeTag ? [NSDate OSCImmediate] : self.timeTag)];

    // elements
    [self.elements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if ([obj respondsToSelector:@selector(_data)]) {
            NSData* elementData = [obj performSelector:@selector(_data)];
            // length
            [data appendInteger:@([elementData length])];

            // data
            [data appendData:elementData];
        }
    }];

#ifdef LOGGING
    // only dump the buffer when less than 4k
    if (data.length < 4 * 1024) {
        [data prettyPrint];
    }
#endif

    return data;
}

@end
