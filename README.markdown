
# Pony Express
a small foundation framework to facilitate OSC communication on Mac OS X 10.7

### GENERAL
- OSC 1.1 over UDP with support for most 1.1 data types: Integer, Float, String, Blob, True, False, Null and Impulse
- Integer and Float arguments are defined in NSNumbers, String as an NSString and Blob as NSData
- the hostname can be an IPv4 or IPv6 IP address a symbolic hostname like _localhost_, ZeroConf hostname like _one-eyed-jacks.local._ or domain name like _audrey.horne.dk_

### THANKS
- Dean McNamee for his great OSC implementation for node.js [omgosc](https://github.com/deanm/omgosc)
- Ray Cutler for his conical OSC implementation in [VVOpenSource](http://code.google.com/p/vvopensource/)
- Mirek Rusin for inspiration and reference with his svelte [CoreOSC](https://github.com/mirek/CoreOSC/) offering
- The [AsyncSocket](http://code.google.com/p/cocoaasyncsocket/) crew for a convenient UDP socket wrapper
