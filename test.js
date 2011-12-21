var $ = require('NodObjC'),
  osc = require('omgosc/omgosc.js'),
  util = require('util');

var frameworkPath = process.argv[2];
$.import(frameworkPath);
