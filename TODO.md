
### GENERAL
- make debug buffer dump multi-line and byte-gap configurable
- move +[NSDate OSCImmediate] to a public header
- test interoperability against Lemur, TouchOSC, Max 6, oF and Cinder
- look into simple MIDI tunneling example
- add more in-depth usage info to [README](README.md) for Mac OS X and iOS applications (@rpath and [iOS usage](http://www.blog.montgomerie.net/easy-xcode-static-library-subprojects-and-submodules))
- remove +[PEOSCMessage displayNameForType:]
- add CONTRIBUTING.md

### MESSAGE
- store originating host and port
- pull address validation code out to a class method and use within -[PEOSCMessage initWithData:]
- do a better job with NSData allocation and writing in -_data?
- ignore unknown types (is that even possible?)

### BUNDLE
- store originating host abd port
- do a better job with NSData allocation and writing in -_data?
- respect time tag dispatch time
- dispatch contents atomically

### SENDER
- host and port should be readwrite now that collectionless
- document 9k UDP limit and Blob use
- offer connected variant in addition to connectionless?

### RECEIVER
- consider some sort of simple router

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

### MISC
- sample router? ?*[!-]{,}//
- example message snooper

### LATER
- mDNS receiver announcement
- add socket management layer to allow sharing
- add TCP and Serial sender/receiver classes via [SLIP](http://en.wikipedia.org/wiki/Serial_Line_Internet_Protocol)
- allow end points to be discovered through query proposal
