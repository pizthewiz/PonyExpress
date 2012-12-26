//
//  PonyExpressTestHelper.h
//  PonyExpress
//
//  Created by Jean-Pierre Mouilleseaux on 21 Apr 2012.
//  Copyright (c) 2012 Chorded Constructions. All rights reserved.
//

// via http://mikeash.com/pyblog/friday-qa-2011-07-22-writing-unit-tests.html
static BOOL WaitFor(BOOL (^block)(void));
static BOOL WaitFor(BOOL (^block)(void)) {
    NSTimeInterval start = [[NSProcessInfo processInfo] systemUptime];
    while(!block() && [[NSProcessInfo processInfo] systemUptime] - start <= 10)
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate: [NSDate date]];
    return block();
}
