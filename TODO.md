
### GENERAL
- figure out how to expose 'immediate' NTPTimetag (NSDate category? only relevant for bundles invocation?)
- take stance on port reuse, either reuse and demo multicast or don't and don't
- investigate static library option for iOS (may not be necessary)
- sort out bundles
- look into simple MIDI tunneling example

### MESSAGE
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
