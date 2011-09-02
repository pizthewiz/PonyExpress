//
//  PEMessage.h
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

extern NSString* const PEMessageTypeTagInteger;
extern NSString* const PEMessageTypeTagFloat;
extern NSString* const PEMessageTypeTagString;
extern NSString* const PEMessageTypeTagBlob;
extern NSString* const PEMessageTypeTagTrue;
extern NSString* const PEMessageTypeTagFalse;
extern NSString* const PEMessageTypeTagNull;
extern NSString* const PEMessageTypeTagImpulse;
extern NSString* const PEMessageTypeTagTimetag;

@interface PEMessage : NSObject
+ (id)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments;
- (id)initWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments;

@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSArray* typeTags;
@property (nonatomic, retain) NSArray* arguments;
@end
