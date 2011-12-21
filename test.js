
var $ = require('NodObjC')
  osc = require('omgosc/omgosc.js');

$.import('Foundation');
var frameworkPath = process.argv[2];
$.import(frameworkPath);


// WORKAROUND - https://github.com/TooTallNate/NodObjC/issues/6 support variadic
function boxArray(array) {
  var boxedArray = $.NSMutableArray('arrayWithCapacity', array.length);
  for (var idx = 0; idx < array.length; idx++) {
    boxedArray('addObject', array[idx]);
  }
  return boxedArray;
}


var pool = $.NSAutoreleasePool('alloc')('init');

var receiver = $.PEOSCReceiver('receiverWithPort', 9999);

var ReceiverDelegate = $.NSObject.extend('ReceiverDelegate');
ReceiverDelegate.addMethod('didReceiveMessage:', 'v@:@', function (self, _cmd, message) {
  console.log('got didReceiveMessage:');
  process.exit(0);
});
ReceiverDelegate.register();
var delegate = ReceiverDelegate('alloc')('init');
receiver('setDelegate', delegate);

var status = receiver('connect');
console.log(status);

var sender = $.PEOSCSender('senderWithHost', $('0.0.0.0'), 'port', 9999);

var types = boxArray([$.PEOSCMessageTypeTagTrue]);
var message = $.PEOSCMessage('messageWithAddress', $('/oscillator/1/active'), 'typeTags', types, 'arguments', null);

status = sender('connect');
console.log(status);
sender('sendMessage', message);


$.NSRunLoop('currentRunLoop')('run');

pool('drain');
