//
//  PEOSCMessage.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
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
extern NSString* const PEOSCMessageTypeTagBlob; // NSData - UNSUPPORTED
extern NSString* const PEOSCMessageTypeTagTrue;
extern NSString* const PEOSCMessageTypeTagFalse;
extern NSString* const PEOSCMessageTypeTagNull;
extern NSString* const PEOSCMessageTypeTagImpulse;
extern NSString* const PEOSCMessageTypeTagTimetag; // {uint32_t, uint32_t} - UNSUPPORTED

@interface PEOSCMessage : NSObject
+ (id)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments;
- (id)initWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments;

@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSArray* typeTags;
@property (nonatomic, retain) NSArray* arguments;

+ (BOOL)typeRequiresArgument:(NSString*)type;
- (void)enumerateTypesAndArgumentsUsingBlock:(void (^)(id type, id argument, BOOL* stop))block;
@end
