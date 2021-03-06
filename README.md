
# Pony Express
Pony Express makes it easy to communicate via the [Open Sound Control](http://opensoundcontrol.org/introduction-osc) (OSC) protocol on OS X 10.7+ and iOS 5.0+.

## General
- OSC 1.1 over UDP with support for most 1.1 data types: Integer, Float, String, Blob, True, False, Null, Impulse and Timetag
- OSC messages can be sent to an IPv4 or IPv6 IP address, a symbolic hostname like _localhost_, ZeroConf hostname like _one-eyed-jacks.local._ or a hostname like _audrey.horne.dk_
- Integer and Float arguments are defined in `NSNumbers`, String as an `NSString`, Blob as `NSData` and Timetag as `NSDate`
- Many items remain to be implemented inlcuding but not limited to ZeroConf advertisement, and querying - Please see the [TODO](TODO.md) for more info

## Example

Send a message with a float argument.
```objective-c
PEOSCMessage* message = [PEOSCMessage messageWithAddress:@"/oscillator/3/frequency" typeTags:@[PEOSCMessageTypeTagFloat] arguments:@[@440.0F];
PEOSCSender* sender = [PEOSCSender senderWithHost:@"cray.local." port:31337];
[sender sendMessage:message handler:^(BOOL success, NSError* error) {
    if (success) {
        NSLog(@"message sent!");
    }
}];
```

Receive messages.
```objective-c
- (void)viewDidLoad {
  self.receiver = [PEOSCReceiver receiverWithPort:31337];
  self.receiver.delegate = self;

  NSError* error;
  [self.receiver beginListening:&error];
  if (error) {
    NSLog(@"ERROR - failed to listen on port %u - %@", 31337, [error localizedDescription]);
  }
}

- (void)didReceiveMessage:(PEOSCMessage*)message {
    NSLog(@"received: %@", message);
}
```

## How To Build
- Clone the repository and submodules `git clone --recursive git://github.com/pizthewiz/PonyExpress.git`
- Open the project in Xcode, select the appropriate PonyExpress scheme and build; example applications are avaialble in the `Examples` directory.

#### Soft Requirements
The bundle version is optionally set from the repository state using [Node.js](http://nodejs.org/) and a few modules; if Node.js is not installed, the bundle version will remain unset.

- Install Node.js 0.10.24 (or later) from [binary package](http://nodejs.org/dist/v0.10.24/node-v0.10.24.pkg) or build and install from [source](http://nodejs.org/dist/v0.10.24/node-v0.10.24.tar.gz)
- Install node modules globally `npm install -g jake async`
- Link global modules to local PonyExpress clone `npm link async`

### NOTES
iOS clients should ensure that the target's _Other Linker Flags_ includes `-ObjC` to load custom categories.

## THANKS
- Dean McNamee for his great Node.js OSC implementation [omgosc](https://github.com/deanm/omgosc)
- Ray Cutler for his conical OSC implementation in [VVOpenSource](https://github.com/mrRay/vvopensource)
- Mirek Rusin for inspiration and reference with his svelte [CoreOSC](https://github.com/mirek/CoreOSC/) offering
- Robbie Hanson, [AsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) and contributors for a convenient UDP socket wrapper
- Nathan Rajlich for [NodObjC](https://github.com/TooTallNate/NodObjC)
