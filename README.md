
# Pony Express
Pony Express is a small Foundation framework to simplify communication via the [Open Sound Control](http://opensoundcontrol.org/introduction-osc) (OSC) protocol for Mac OS X 10.7 and later.

## General
- OSC 1.1 over UDP with support for most 1.1 data types: Integer, Float, String, Blob, True, False, Null and Impulse
- OSC messages can be sent to an IPv4 or IPv6 IP address, a symbolic hostname like _localhost_, ZeroConf hostname like _one-eyed-jacks.local._ or a hostname like _audrey.horne.dk_
- Integer and Float arguments are defined in NSNumbers, String as an NSString and Blob as NSData
- Pony Express makes use of [Automatic Reference Counting](http://clang.llvm.org/docs/AutomaticReferenceCounting.html) (ARC)
- many items remain to be implemented inlcuding but not limited to OSC bundles, timetag, ZeroConf advertising, and querying. please see the [TODO](https://github.com/pizthewiz/PonyExpress/blob/master/TODO.markdown) for more info

## Example
A simple message with a single float argument is sent to a receiver (setup not shown here).

``` objective-c
PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/oscillator/3/frequency" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@440.0F];
PEOSCSender* sender = [PEOSCSender senderWithHost:@"cray.local." port:31337];
[sender connectWithCompletionHandler:^(BOOL success, NSError* error) {
    if (success) {
        [sender sendMessage:message];
    }
}];
```

## How To Build
- clone the repository and submodules `git clone --recursive git://github.com/pizthewiz/PonyExpress.git`
- load up the project in Xcode, select the PonyExpress or OrphanExample scheme and build

#### Soft Requirements
NSArray, NSDictionary and NSNumber [literals](http://clang.llvm.org/docs/ObjectiveCLiterals.html) and object subscripting are used throughout the Pony Express classes, and is available in Apple LLVM Compiler 4.0+, shipped as part of Xcode 4.4 or later. 

the bundle version is optionally set from the repository state using [Node.js](http://nodejs.org/) and a few modules; if Node.js is not installed, the bundle version will remain unset.

- install Node.js 0.8.12 (or later) from [binary package](http://nodejs.org/dist/v0.8.12/node-v0.8.12.pkg) or build and install from [source](http://nodejs.org/dist/v0.8.12/node-v0.8.12.tar.gz)
- install node modules globally `npm install -g jake async NodObjC`
- link global modules to local PonyExpress clone `npm link jake async NodObjC`

## THANKS
- Dean McNamee for his great OSC implementation for node.js [omgosc](https://github.com/deanm/omgosc)
- Ray Cutler for his conical OSC implementation in [VVOpenSource](http://code.google.com/p/vvopensource/)
- Mirek Rusin for inspiration and reference with his svelte [CoreOSC](https://github.com/mirek/CoreOSC/) offering
- Robbie Hanson [AsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) and contributors for a convenient UDP socket wrapper
- Nathan Rajlich for [NodObjC](https://github.com/TooTallNate/NodObjC)
