//
//  PEOSCMessage.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 02 Sept 2011.
//  Copyright (c) 2011-2013 Chorded Constructions. All rights reserved.
//

#import "PEOSCMessage.h"
#import "PEOSCMessage-Private.h"
#import "PEOSCUtilities.h"
#import "PEOSCUtilities-Internal.h"
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

@implementation PEOSCMessage

+ (instancetype)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments {
    id message = [[[self class] alloc] initWithAddress:address typeTags:typeTags arguments:arguments];
    return message;
}

- (instancetype)initWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments {
    self = [super init];
    if (self) {
        self.address = address;
        self.typeTags = typeTags;
        self.arguments = arguments;
    }
    return self;
}

+ (instancetype)messageWithData:(NSData*)data {
    id message = [[[self class] alloc] initWithData:data];
    return message;
}

- (instancetype)initWithData:(NSData*)data {
    self = [super init];
    if (self) {
        NSUInteger length = [data length];
        NSUInteger start = 0;

        // address
        NSString* addressString = [data readStringAtOffset:start];
        // TODO - replace naïve validation with +[PEOSCMessage addressIsValid:]
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
        NSString* typeTagString = [data readStringAtOffset:start];

        // NB - this is probably too aggressive
        static NSString* const PEOSCTypeTagRegExPattern = @"^,[ifsbTFNIt]*$";
        NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:PEOSCTypeTagRegExPattern options:0 error:NULL];
        NSTextCheckingResult* result = [reg firstMatchInString:typeTagString options:0 range:NSMakeRange(0, typeTagString.length)];
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
                NSNumber* value = [data readIntegerAtOffset:start];
                [list addObject:value];
                start += 4;
            } else if ([type isEqualToString:PEOSCMessageTypeTagFloat]) {
                if (start+4 > length) {
                    CCErrorLog(@"ERROR - cannot read float from data, out of range");
                    return nil;
                }
                NSNumber* value = [data readFloatAtOffset:start];
                [list addObject:value];
                start += 4;
            } else if ([type isEqualToString:PEOSCMessageTypeTagString]) {
                NSString* string = [data readStringAtOffset:start];
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
                NSData* d = [data readBlobAtOffset:start length:blobLength];
                if (!d) {
                    CCErrorLog(@"ERROR - failed to read data blob");
                    return nil;
                }
                [list addObject:d];
                start += d.length + 4 - (d.length & 3);
            } else if ([type isEqualToString:PEOSCMessageTypeTagTimetag]) {
                NSDate* date = [data readTimeTagAtOffset:start];
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
    if ([type isEqualToString:PEOSCMessageTypeTagInteger]) {
        name = @"Integer";
    } else if ([type isEqualToString:PEOSCMessageTypeTagFloat]) {
        name = @"Float";
    } else if ([type isEqualToString:PEOSCMessageTypeTagString]) {
        name = @"String";
    } else if ([type isEqualToString:PEOSCMessageTypeTagBlob]) {
        name = @"Blob";
    } else if ([type isEqualToString:PEOSCMessageTypeTagTrue]) {
        name = @"True";
    } else if ([type isEqualToString:PEOSCMessageTypeTagFalse]) {
        name = @"False";
    } else if ([type isEqualToString:PEOSCMessageTypeTagNull]) {
        name = @"Null";
    } else if ([type isEqualToString:PEOSCMessageTypeTagImpulse]) {
        name = @"Impulse";
    } else if ([type isEqualToString:PEOSCMessageTypeTagTimetag]) {
        name = @"Timetag";
    }
    return name;
}

+ (NSString*)_codeForType:(NSString*)type {
    NSString* code = nil;
    if ([type isEqualToString:PEOSCMessageTypeTagInteger]) {
        code = @"i";
    } else if ([type isEqualToString:PEOSCMessageTypeTagFloat]) {
        code = @"f";
    } else if ([type isEqualToString:PEOSCMessageTypeTagString]) {
        code = @"s";
    } else if ([type isEqualToString:PEOSCMessageTypeTagBlob]) {
        code = @"b";
    } else if ([type isEqualToString:PEOSCMessageTypeTagTrue]) {
        code = @"T";
    } else if ([type isEqualToString:PEOSCMessageTypeTagFalse]) {
        code = @"F";
    } else if ([type isEqualToString:PEOSCMessageTypeTagNull]) {
        code = @"N";
    } else if ([type isEqualToString:PEOSCMessageTypeTagImpulse]) {
        code = @"I";
    } else if ([type isEqualToString:PEOSCMessageTypeTagTimetag]) {
        code = @"t";
    } else {
        CCDebugLog(@"unrecognized type %@", type);
    }
    return code;
}

+ (NSString*)_typeForCode:(NSString*)code {
    NSString* type = nil;
    if ([code isEqualToString:@"i"]) {
        type = PEOSCMessageTypeTagInteger;
    } else if ([code isEqualToString:@"f"]) {
        type = PEOSCMessageTypeTagFloat;
    } else if ([code isEqualToString:@"s"]) {
        type = PEOSCMessageTypeTagString;
    } else if ([code isEqualToString:@"b"]) {
        type = PEOSCMessageTypeTagBlob;
    } else if ([code isEqualToString:@"T"]) {
        type = PEOSCMessageTypeTagTrue;
    } else if ([code isEqualToString:@"F"]) {
        type = PEOSCMessageTypeTagFalse;
    } else if ([code isEqualToString:@"N"]) {
        type = PEOSCMessageTypeTagNull;
    } else if ([code isEqualToString:@"I"]) {
        type = PEOSCMessageTypeTagImpulse;
    } else if ([code isEqualToString:@"t"]) {
        type = PEOSCMessageTypeTagTimetag;
    } else {
        CCDebugLog(@"unrecognized code %@", code);
    }
    return type;
}

#pragma mark -

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[PEOSCMessage class]]) {
        return NO;
    }
    return [object hash] == [self hash];
}

- (NSUInteger)hash {
    return NSUINTROTATE(NSUINTROTATE([self.address hash], NSUINT_BIT / 2) ^ [self.typeTags hash], NSUINT_BIT / 2) ^ [self.arguments hash];
}

- (NSString*)description {
    NSMutableArray* descriptions = [NSMutableArray array];
    [self.arguments enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if ([obj isKindOfClass:[NSData class]] && [(NSData*)obj length] > 4 * 1024) {
            [descriptions addObject:@"<BINARY DATA TOO LARGE TO PRINT>"];
        } else {
            [descriptions addObject:[obj description]];
        }
    }];
    NSString* typeTagString = self.typeTags.count ? [self _typeTagString] : @"(–)";
    return [NSString stringWithFormat:@"<%@: %@ %@ [%@]>", NSStringFromClass([self class]), self.address, typeTagString, [descriptions componentsJoinedByString:@", "]];
}

#pragma mark -

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

- (BOOL)_isValid {
    return [self _isAddressValid] && [self _areTypeTagsValid] && [self _areArgumentsValidGivenTypeTags];
}

- (BOOL)_isAddressValid {
    if (!self.address) {
        return NO;
    }

    BOOL status = YES;

    // check for leading / and lack of spaces
    static NSString* const PEOSCAddressRegExPattern = @"^/(\\S*)$";
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:PEOSCAddressRegExPattern options:NSRegularExpressionCaseInsensitive error:NULL];
    NSUInteger matches = [reg numberOfMatchesInString:self.address options:0 range:NSMakeRange(0, self.address.length)];
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
                } else if (c == '[') {
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
    if (self.arguments.count != numberOfArguments) {
        return NO;
    }

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

    __block NSMutableData* data = [NSMutableData data];

    // address
    [data appendString:self.address];

    // type tag string
    [data appendString:[self _typeTagString]];

    [self enumerateTypesAndArgumentsUsingBlock:^(id type, id argument, BOOL* stop) {
        if (![[self class] argumentRequiredByType:type]) {
            return;
        }

        // TODO - check argument class?
        if ([type isEqualToString:PEOSCMessageTypeTagInteger]) {
            [data appendInteger:argument];
        } else if ([type isEqualToString:PEOSCMessageTypeTagFloat]) {
            [data appendFloat:argument];
        } else if ([type isEqualToString:PEOSCMessageTypeTagString]) {
            [data appendString:argument];
        } else if ([type isEqualToString:PEOSCMessageTypeTagBlob]) {
            [data appendBlob:argument];
        } else if ([type isEqualToString:PEOSCMessageTypeTagTimetag]) {
            [data appendTimeTag:argument];
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
