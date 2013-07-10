
### GENERAL
- pull address validation code out to a class method and use within -[PEOSCMessage initWithData:]
- go unicast and later add multicast support
- sort out OSC bundle support
- centralize data walking increments from Messages and Bundles
- test interoperability against Lemur, TouchOSC, Max 6, oF and Cinder
- look into simple MIDI tunneling example
- add more in-depth usage info to [README](README.md) for Mac OS X and iOS applications (@rpath and [iOS usage](http://www.blog.montgomerie.net/easy-xcode-static-library-subprojects-and-submodules))
- remove +[PEOSCMessage displayNameForType:]
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
- message creation from data, bad tagTypeString, empty types
- message argument serialization
- message argument deserialization

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
