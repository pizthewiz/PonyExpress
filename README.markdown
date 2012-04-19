
# Pony Express
a small foundation framework to facilitate OSC communication on Mac OS X 10.7

### HOW TO BUILD
- clone the repository and submodules `git clone --recursive git://github.com/pizthewiz/PonyExpress.git`
- [MacRuby](http://www.macruby.org/) is used to automate versioning of builds based on the current git revision, install it
- load up the project in Xcode, select the PonyExpress or OrphanExample application scheme and build

### GENERAL
- OSC 1.1 over UDP with support for most 1.1 data types: Integer, Float, String, Blob, True, False, Null and Impulse
- Integer and Float arguments are defined in NSNumbers, String as an NSString and Blob as NSData
- the hostname can be an IPv4 or IPv6 IP address a symbolic hostname like _localhost_, ZeroConf hostname like _one-eyed-jacks.local._ or domain name like _audrey.horne.dk_
- many tasks remain to be implemented such as OSC bundle, timetag, querying and OSC-over-TCP support, please see the [TODO](https://github.com/pizthewiz/PonyExpress/blob/master/TODO) for more info

### TESTING
- unit tests: OCUnit / OCMock

### THANKS
- Dean McNamee for his great OSC implementation for node.js [omgosc](https://github.com/deanm/omgosc)
- Ray Cutler for his conical OSC implementation in [VVOpenSource](http://code.google.com/p/vvopensource/)
- Mirek Rusin for inspiration and reference with his svelte [CoreOSC](https://github.com/mirek/CoreOSC/) offering
- Robbie Hanson [AsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) and contributors for a convenient UDP socket wrapper
- Nathan Rajlich for [NodObjC](https://github.com/TooTallNate/NodObjC) which is a fantastic means for functional testing
