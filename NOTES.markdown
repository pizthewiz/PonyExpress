
[1.0 spec](http://opensoundcontrol.org/spec-1_0)
[1.1 spec](http://opensoundcontrol.org/spec-1_1)

### MESSAGE
- address
- typeTags
- arguments
- self serialization

### SENDER
- use CFNetwork and a CFRunLoop
- ifsbTFNI types
- allow multiple tags/parameters, specify via NSArray of NSDictionaries?
- advertise via mDNS

### RECEIVER
- …

### MISC
the Timetag type is an NTP timestamp, via [NetAssociation.h](http://code.google.com/p/ios-ntp/source/browse/trunk/Classes/NetAssociation.h):

    /*┌──────────────────────────────────────────────────────────────────────────────────────────────────┐
      │  NTP Timestamp Structure                                                                         │
      │                                                                                                  │
      │   1                   2                   3                                                      │
      │   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1                                │
      │  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               │
      │  |                           Seconds                             |                               │
      │  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               │
      │  |                  Seconds Fraction (0-padded)                  | <-- 4294967296 = 1 second     │
      │  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+                               │
      └──────────────────────────────────────────────────────────────────────────────────────────────────┘*/
    struct ntpTimestamp {
            uint32_t    fullSeconds;
            uint32_t    partSeconds;
    };
