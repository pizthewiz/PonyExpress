//
//  PEOSCMessage-Private.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 2 Sept 2011.
//  Copyright (c) 2011 Chorded Constructions. All rights reserved.
//

#import "PEOSCMessage.h"

@interface PEOSCMessage()
- (BOOL)_isAddressValid;
- (BOOL)_areTypeTagsValid;
- (NSString*)_typeTagString;
@end
