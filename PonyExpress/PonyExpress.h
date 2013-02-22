//
//  PonyExpress.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 02 Sept 2011.
//  Copyright (c) 2011-2013 Chorded Constructions. All rights reserved.
//

#if TARGET_OS_IPHONE
    #import "PEOSCMessage.h"
    #import "PEOSCSender.h"
    #import "PEOSCReceiver.h"
#else
    #import <PonyExpress/PEOSCMessage.h>
    #import <PonyExpress/PEOSCSender.h>
    #import <PonyExpress/PEOSCReceiver.h>
#endif
