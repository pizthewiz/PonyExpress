//
//  main.m
//  OrphanExample
//
//  Created by Jean-Pierre Mouilleseaux on 3 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PonyExpress/PonyExpress.h>

int main (int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray* typeTags = [NSArray arrayWithObjects:PEOSCMessageTypeTagInteger, PEOSCMessageTypeTagFloat, PEOSCMessageTypeTagString, PEOSCMessageTypeTagTrue, PEOSCMessageTypeTagFalse, PEOSCMessageTypeTagNull, PEOSCMessageTypeTagImpulse, nil];
        NSArray* arguments = [NSArray arrayWithObjects:[NSNumber numberWithInt:13], [NSNumber numberWithFloat:(100./3.)], @"STRING", nil];
        PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/some/thing" typeTags:typeTags arguments:arguments];
        NSLog(@"%@", message);
        PEOSCSender* sender = [PEOSCSender senderWithHost:@"localhost" port:9000];
        NSLog(@"%@", sender);
    }
    return 0;
}
