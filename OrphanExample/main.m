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
        PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/some/thing" typeTags:nil arguments:nil];
        NSLog(@"%@", message);
        PEOSCSender* sender = [PEOSCSender senderWithHost:@"localhost" port:9000];
        NSLog(@"%@", sender);        
    }
    return 0;
}
