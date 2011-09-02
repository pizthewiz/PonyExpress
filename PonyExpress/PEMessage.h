//
//  PEMessage.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEMessage : NSObject
+ (id)messageWithAddress:(NSString*)address dataDictionary:(NSDictionary*)dictionary;
- (id)initWithAddress:(NSString*)address dataDictionary:(NSDictionary*)dictionary;

@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSDictionary* dataDictionary;
@end
