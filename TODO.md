
### GENERAL
- override -[PEOSCMessage hash] for support of -[PEOSCMessage isEqual], see [mike ash's friday qa article](http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html)
- pull address validation code out to a class method and use within -[PEOSCMessage initWithData:]
- redo static library for iOS in the mannor [descirbed by jamie](http://www.blog.montgomerie.net/easy-xcode-static-library-subprojects-and-submodules) and migrate Example/Tests to it
- go unicast and later add multicast support
- sort out OSC bundle support
- test interoperability against Lemur, TouchOSC, Max 6, oF and Cinder
- figure out how to expose a constant for the 'immediate' NTPTimetag (NSDate category? only relevant for bundles invocation?)
- look into simple MIDI tunneling example
- add more in-depth usage info to [README](README.md) for Mac OS X and iOS applications
- add CONTRIBUTING.md

### MESSAGE
- store host message originated from?
- do a better job with NSData allocation and writing in -_data?
- ignore unknown types (is that even possible?)
- make debug buffer dump multi-line and byte-gap configurable

### SENDER
- host and port could be readwrite with collectionless
- document 9k UDP limit and Blob use
- offer connected variant in addition to connectionless

### RECEIVER
- consider some sort of simple router

### UNIT TESTS
- may need to consider disconnect / stop listening in -tearDown
- test message creation from data, bad tagTypeString, empty types
- test send of type-less message, nil and @[]
- test message argument serialization
- test message argument deserialization
- test sender with bad host (if connection-based again)

### FUNCTIONAL TESTS
- send message
- receive message
- send bad message data
- receive bad message data
- receive message with unknown type in type string
- send data on privileged port, < 1024
- receive data on privileged port, < 1024
- receive data on a port in use

### MISC
- sample router? ?*[!-]{,}//
- example message snooper

### LATER
- mDNS receiver announcement
- consider a PEOSCValue class to wrap boxing
- add socket management layer to allow sharing (only relevant if port reuse is disabled)
- add TCP and Serial sender/receiver classes via [SLIP](http://en.wikipedia.org/wiki/Serial_Line_Internet_Protocol)
- allow end points to be discovered through query proposal
