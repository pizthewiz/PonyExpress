
# Pony Express
Pony Express makes it easy to communicate via the [Open Sound Control](http://opensoundcontrol.org/introduction-osc) (OSC) protocol on OS X 10.7+ and iOS 5.0+.

## General
- OSC 1.1 over UDP with support for most 1.1 data types: Integer, Float, String, Blob, True, False, Null, Impulse and Timetag
- OSC messages can be sent to an IPv4 or IPv6 IP address, a symbolic hostname like _localhost_, ZeroConf hostname like _one-eyed-jacks.local._ or a hostname like _audrey.horne.dk_
- Integer and Float arguments are defined in `NSNumbers`, String as an `NSString`, Blob as `NSData` and Timetag as `NSDate`
- Pony Express makes use of [Automatic Reference Counting](http://clang.llvm.org/docs/AutomaticReferenceCounting.html) (ARC)
- Many items remain to be implemented inlcuding but not limited to ZeroConf advertisement, and querying - Please see the [TODO](https://github.com/pizthewiz/PonyExpress/blob/master/TODO.md) for more info

## Example
Simple message send with a float argument to a receiver (setup not shown here).

``` objective-c
PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/oscillator/3/frequency" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@440.0F];
PEOSCSender* sender = [PEOSCSender senderWithHost:@"cray.local." port:31337];
[sender sendMessage:message handler:^(BOOL success, NSError* error) {
    if (success) {
        NSLog(@"message sent!");
    }
}];
```

## How To Build
- Clone the repository and submodules `git clone --recursive git://github.com/pizthewiz/PonyExpress.git`
- Open the project in Xcode, select the appropriate PonyExpress scheme and build; example applications are avaialble in the `Examples` directory.

#### Soft Requirements
NSArray, NSDictionary and NSNumber [literals](http://clang.llvm.org/docs/ObjectiveCLiterals.html), object subscripting and [instancetype](http://clang.llvm.org/docs/LanguageExtensions.html#objc_instancetype) are used throughout the Pony Express, and is available in Apple LLVM Compiler 4.0+, shipped as part of Xcode 4.4 or later.

The bundle version is optionally set from the repository state using [Node.js](http://nodejs.org/) and a few modules; if Node.js is not installed, the bundle version will remain unset.

- Install Node.js 0.10.13 (or later) from [binary package](http://nodejs.org/dist/v0.10.13/node-v0.10.13.pkg) or build and install from [source](http://nodejs.org/dist/v0.10.13/node-v0.10.13.tar.gz)
- Install node modules globally `npm install -g jake async NodObjC`
- Link global modules to local PonyExpress clone `npm link async NodObjC`

### NOTES
iOS clients should ensure that the target's _Other Linker Flags_ includes `-all_load` to load custom categories.

## THANKS
- Dean McNamee for his great Node.js OSC implementation [omgosc](https://github.com/deanm/omgosc)
- Ray Cutler for his conical OSC implementation in [VVOpenSource](https://github.com/mrRay/vvopensource)
- Mirek Rusin for inspiration and reference with his svelte [CoreOSC](https://github.com/mirek/CoreOSC/) offering
- Robbie Hanson, [AsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) and contributors for a convenient UDP socket wrapper
- Nathan Rajlich for [NodObjC](https://github.com/TooTallNate/NodObjC)
