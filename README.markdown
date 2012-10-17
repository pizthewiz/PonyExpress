
# Pony Express
a small foundation framework to facilitate OSC communication on Mac OS X 10.7

### HOW TO BUILD
- clone the repository and submodules `git clone --recursive git://github.com/pizthewiz/PonyExpress.git`
- load up the project in Xcode, select the PonyExpress or OrphanExample application scheme and build

#### SOFT REQUIREMENT
the bundle version is optionally set from the repository state using [Node.js](http://nodejs.org/) and a few node modules. if Node is not installed, the bundle version will remain unset. 

- install Node.js 0.8.12 or later from [binary package](http://nodejs.org/dist/v0.8.12/node-v0.8.12.pkg) or build and install from [source](http://nodejs.org/dist/v0.8.12/node-v0.8.12.tar.gz)
- install node submodules globally `npm install -g jake async NodObjC`
- link global submodules to local repository `npm link jake async NodObjC`

### GENERAL
- OSC 1.1 over UDP with support for most 1.1 data types: Integer, Float, String, Blob, True, False, Null and Impulse
- Integer and Float arguments are defined in NSNumbers, String as an NSString and Blob as NSData
- the hostname can be an IPv4 or IPv6 IP address a symbolic hostname like _localhost_, ZeroConf hostname like _one-eyed-jacks.local._ or domain name like _audrey.horne.dk_
- many tasks remain to be implemented such as OSC bundle, timetag, querying and OSC-over-TCP support, please see the [TODO](https://github.com/pizthewiz/PonyExpress/blob/master/TODO.markdown) for more info

### TESTING
- unit tests: OCUnit / [OCMock](http://ocmock.org/) (included as git submodule)

### THANKS
- Dean McNamee for his great OSC implementation for node.js [omgosc](https://github.com/deanm/omgosc)
- Ray Cutler for his conical OSC implementation in [VVOpenSource](http://code.google.com/p/vvopensource/)
- Mirek Rusin for inspiration and reference with his svelte [CoreOSC](https://github.com/mirek/CoreOSC/) offering
- Robbie Hanson [AsyncSocket](https://github.com/robbiehanson/CocoaAsyncSocket) and contributors for a convenient UDP socket wrapper
- Nathan Rajlich for [NodObjC](https://github.com/TooTallNate/NodObjC)
