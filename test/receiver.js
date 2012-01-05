
var $ = require('NodObjC'),
// NB - cannot use until GCD'd socket is in place
//  osc = require('omgosc/omgosc.js'),
  should = require('should'),
  util = require('util');


var frameworkPath = process.env['PONYEXPRESS_FRAMEWORK'] || process.argv[2];
$.import(frameworkPath);

// WORKAROUND - https://github.com/TooTallNate/NodObjC/issues/6 support variadic
function boxArray(array) {
  var boxedArray = $.NSMutableArray('arrayWithCapacity', array.length);
  for (var idx = 0; idx < array.length; idx++) {
    boxedArray('addObject', array[idx]);
  }
  return boxedArray;
}
// other helpers
function unboxString(string) { return string('UTF8String'); }
function unboxStrinyInteger(number) { return parseInt(number, 10); }
function unboxStrinyFloat(number) { return parseFloat(number, 10); }



describe('Receiver', function () {
  var pool = null;
  beforeEach(function () {
    pool = $.NSAutoreleasePool('alloc')('init');
  });
  afterEach(function () {
    pool('drain');
  });

  it('should receive message with proper contents', function (done) {
    var ReceiverDelegate = $.NSObject.extend('ReceiverDelegate');
    ReceiverDelegate.addMethod('didReceiveMessage:', 'v@:@', function (self, _cmd, message) {
      should.exist(message);
      unboxString(message('address')).should.eql('/track/1/gain');
      unboxStrinyInteger(message('typeTags')('count')).should.eql(1);
      message('typeTags')('objectAtIndex', 0).should.eql($.PEOSCMessageTypeTagFloat);
      unboxStrinyInteger(message('arguments')('count')).should.eql(1);
      unboxStrinyFloat(message('arguments')('objectAtIndex', 0)).should.eql(0.333);
      done();
    });
    ReceiverDelegate.register();
    var delegate = ReceiverDelegate('alloc')('init');
    delegate.should.be.ok;

    var receiver = $.PEOSCReceiver('receiverWithPort', 9999);
    receiver.should.be.ok;
    receiver('setDelegate', delegate);
    var status = receiver('connect');
    status.should.be.ok;

    var sender = $.PEOSCSender('senderWithHost', $('0.0.0.0'), 'port', 9999);
    sender.should.be.ok;
    status = sender('connect');
    status.should.be.ok;

    var types = boxArray([$.PEOSCMessageTypeTagFloat]);
    var args = boxArray([$.NSNumber('numberWithFloat', 0.333)]);
    var message = $.PEOSCMessage('messageWithAddress', $('/track/1/gain'), 'typeTags', types, 'arguments', args);
    sender('sendMessage', message);

    // give it a 2 second leash
    var stopDate = $.NSDate('alloc')('initWithTimeIntervalSinceNow', 2);
    $.NSRunLoop('currentRunLoop')('runUntilDate', stopDate);
  });

});
