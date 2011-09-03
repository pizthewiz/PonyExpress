//
//  PEOSCSender.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEOSCSender : NSObject
+ (id)senderWithHost:(NSString*)host port:(NSUInteger)port;
- (id)initWithHost:(NSString*)host port:(NSUInteger)port;

@property (nonatomic, retain) NSString* host;
@property (nonatomic) NSUInteger port;
@end
