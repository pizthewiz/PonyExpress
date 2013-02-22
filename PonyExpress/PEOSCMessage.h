//
//  PEOSCMessage.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 02 Sept 2011.
//  Copyright (c) 2011-2013 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

// OSC 1.1 required types:
//  i  Integer: two's compliment int32
//  f  Float: IEEE float32
//  s  NULL-terminated ASCII string
//  b  Blob: byte array
//  T  True: data-less
//  F  False: data-less
//  N  Null: data-less
//  I  Impluse: bang, data-less
//  t  Timetag: OSC Timetag in NTP format

extern NSString* const PEOSCMessageTypeTagInteger; // NSNumber
extern NSString* const PEOSCMessageTypeTagFloat; // NSNumber
extern NSString* const PEOSCMessageTypeTagString; // NSString (ASCII)
extern NSString* const PEOSCMessageTypeTagBlob; // NSData
extern NSString* const PEOSCMessageTypeTagTrue; // ARG-LESS
extern NSString* const PEOSCMessageTypeTagFalse; // ARG-LESS
extern NSString* const PEOSCMessageTypeTagNull; // ARG-LESS
extern NSString* const PEOSCMessageTypeTagImpulse; // ARG-LESS
extern NSString* const PEOSCMessageTypeTagTimetag; // NSDate

@interface PEOSCMessage : NSObject
// arg-less types should not be represented with a value in the arguments array
+ (instancetype)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments;
- (instancetype)initWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments;

@property (nonatomic, strong) NSString* address;
@property (nonatomic, strong) NSArray* typeTags;
@property (nonatomic, strong) NSArray* arguments;

+ (BOOL)argumentRequiredByType:(NSString*)type;
+ (NSString*)displayNameForType:(NSString*)type;

// arg-less types provide a nil argument
- (void)enumerateTypesAndArgumentsUsingBlock:(void (^)(id type, id argument, BOOL* stop))block;
@end
