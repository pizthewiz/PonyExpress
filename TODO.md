
### GENERAL
- make debug buffer dump multi-line and byte-gap configurable
- move +[NSDate OSCImmediate] to a public header
- add more in-depth usage info to [README](README.md) for Mac OS X and iOS applications (@rpath and [iOS usage](http://www.blog.montgomerie.net/easy-xcode-static-library-subprojects-and-submodules))
- remove +[PEOSCMessage displayNameForType:]
- add a CONTRIBUTING.md

### MESSAGE
- pull address validation code out to a class method and use within -[PEOSCMessage initWithData:]
- double check that blob length doesn't overflow int32
- do a better job with NSData allocation and writing in -_data?
- ignore unknown types (is that even possible?)

### BUNDLE
- double check that bundle element length doesn't overflow int32
- do a better job with NSData allocation and writing in -_data?
- respect time tag dispatch time
- dispatch contents atomically

### SENDER
- host and port should be readwrite now that collectionless
- offer connected variant in addition to connectionless?

### ROUTER
- create a simple router like [omgosc-router](https://github.com/pizthewiz/omgosc-router)
- investigate mr ray's [OSCQueryProposal](https://github.com/mrRay/OSCQueryProposal)

### UNIT TESTS
- message creation from data, bad tagTypeString, empty types
- message argument serialization
- message argument deserialization

### FUNCTIONAL TESTS
- send message/bundle
- receive message/bundle
- send bad message/bundle data
- receive bad message/bundle data
- receive message with unknown type in type string
- send data on privileged port, < 1024
- receive data on privileged port, < 1024
- receive data on a port in use

### EXAMPLES
- update iOS and OS X examples to be a simple PingPong
- message snooper
- MIDI tunneler

### LATER
- mDNS receiver announcement
- add socket management layer to allow sharing
- add TCP and Serial sender/receiver classes via [SLIP](http://en.wikipedia.org/wiki/Serial_Line_Internet_Protocol)
