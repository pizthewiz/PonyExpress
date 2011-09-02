//
//  PEMessage.m
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 9/2/11.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEMessage.h"

@implementation PEMessage

@synthesize address, dataDictionary;

+ (id)messageWithAddress:(NSString*)address dataDictionary:(NSDictionary*)dictionary {
    id message = [[PEMessage alloc] initWithAddress:address dataDictionary:dictionary];
    return message;
}

- (id)initWithAddress:(NSString*)a dataDictionary:(NSDictionary*)d {
    self = [super init];
    if (self) {
        self.address = a;
        self.dataDictionary = d;
    }
    return self;
}

@end
