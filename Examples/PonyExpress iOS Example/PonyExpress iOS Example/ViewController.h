//
//  ViewController.h
//  PonyExpress iOS Example
//
//  Created by Jean-Pierre Mouilleseaux on 29 Dec 2012.
//  Copyright (c) 2012 Chorded Constructions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PonyExpress.h"

@interface ViewController : UIViewController <PEOSCReceiverDelegate>
@property (nonatomic, strong) PEOSCReceiver* receiver;
@end
