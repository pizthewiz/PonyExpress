
### OSC specs
- [1.0 spec](http://opensoundcontrol.org/spec-1_0)
- [1.1 spec](http://opensoundcontrol.org/spec-1_1)

### Bundles
- the timetag should be consulted on when to execute the OSC methods (need some sort of timer)
- a timetag of 63 zeros followed by a one has the special meaning 'immediate'
- messages within a bundle should be atomically executed, should halt handling of other incoming stuff
