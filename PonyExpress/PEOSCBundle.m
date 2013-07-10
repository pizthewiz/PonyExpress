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

        // check first 8 bytes for #bundle
        if (![PEOSCBundle _dataIsLikelyBundle:data]) {
            CCErrorLog(@"ERROR - missing starting marker, bundle dropped");
            return nil;
        }
        start += 8;

        // read timetag
        NSDate* timeTag = readDate(data, start);
        if (!timeTag) {
            CCErrorLog(@"ERROR - missing timetag, bundle dropped");
            return nil;
        }
        self.timeTag = timeTag;
        start += 8;

        // make messages
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

#pragma mark - PRIVATE

+ (BOOL)_dataIsLikelyBundle:(NSData*)data {
    if ([data length] < 8) {
        return NO;
    }
    // check first 8 bytes for #bundle
    NSString* string = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 8)] encoding:NSASCIIStringEncoding];
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
    return nil;
}

@end
