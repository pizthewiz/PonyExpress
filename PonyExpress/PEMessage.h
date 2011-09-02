//
//  PEMessage.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const PEMessageTypeTag;
extern NSString* const PEMessageArgument;

@interface PEMessage : NSObject
+ (id)messageWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments;
- (id)initWithAddress:(NSString*)address typeTags:(NSArray*)typeTags arguments:(NSArray*)arguments;

@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSArray* typeTags;
@property (nonatomic, retain) NSArray* arguments;
@end
