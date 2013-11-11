/*jshint node:true */

// set bundle version directly from the git repository state
// for example:
//  CFBundleVersion: 47
//  CFBundleShortVersionString: 0.8.3
//  com.chordedconstructions.fleshworld.ProjectHEADRevision: 6c1eab18bd5c8964cc1ebebe90622216cd62fb86

var util = require('util'),
  fs = require('fs'),
  path = require('path'),
  exec = require('child_process').exec,
  async = require('async');

const BUNDLE_VERSION_NUMBER_KEY = 'CFBundleVersion';
const BUNDLE_VERSION_STRING_KEY = 'CFBundleShortVersionString';
const HEAD_REVISION_KEY = 'com.chordedconstructions.ProjectHEADRevision';
const BUILD_VERSION_CONFIG_PATH = 'Configurations/BuildVersion.xcconfig';

// helpers
function buildNumber(callback) {
  exec("git log --pretty=format:'' | wc -l", function (err, stdout, stderr) {
    var s = parseInt(stdout.trim(), 10) || 0;
    callback(err, s);
  });
}
function buildString(callback) {
  exec("git describe --dirty", function (err, stdout, stderr) {
    // describe only works after a tag is present
    var matches = stdout.trim().match(/^v+(.*)/);
    var s = matches ? matches[1] : '0.0.0';
    if (err && err.code == 128) {
      err = null;
    }
    callback(err, s);
  });
}
function headRevision(callback) {
  exec("git rev-parse HEAD", function (err, stdout, stderr) {
    var s = stdout.trim();
    callback(err, s);
  });
}

desc('update build number and string in BuildVersion.xcconfig from git repo values');
task('updateVersion', [], function () {
  async.series([buildNumber, buildString], function (err, results) {
    if (err) {
      console.log('ERROR - failed to fetch build number and string from git repo - ' + err);
      process.exit(code=1);
    }

    var number = results.shift().toString();
    var string = results.shift();

    var sourceRoot = process.env['SRC_ROOT'] || __dirname;
    var configPath = path.join(sourceRoot, BUILD_VERSION_CONFIG_PATH);

    var content = "//\n// 💀 AUTO-GENERATED, DO NOT BOTHER EDITING 💀\n//\n\nBUILD_VERSION_NUMBER=" + number + "\nBUILD_VERSION_STRING=" + string + "\n";
    fs.writeFile(configPath, content, function (err) {
      if (err) {
        console.log('ERROR - failed to write build number config file - ' + err);
        process.exit(code=1);
      }
    }); 
  });
});

desc('update Info.plist key-value pairs');
task('updatePlist', [], function (keys, values, d, p) {
  var buildDirectory = process.env['BUILT_PRODUCTS_DIR'] || d;
  var infoPlistPath = process.env['INFOPLIST_PATH'] || p; // relative to buildDirectory
  var productPlistPath = path.join(buildDirectory, infoPlistPath);
  if (!fs.existsSync(productPlistPath)) {
    console.log('ERROR - plist not found at path: ' + productPlistPath);
    process.exit(code=1);
  }

  keys = Array.isArray(keys) ? keys : [keys];
  values = Array.isArray(values) ? values : [values];
  if (keys.length != values.length) {
    console.log('ERROR - unbalanced keys and values');
    process.exit(code=1);
  }

  // defer load of NodObjC and import of Foundation
  $ = require('NodObjC');
  $.import('Foundation');

  var pool = $.NSAutoreleasePool('alloc')('init');
  {
    var info = $.NSMutableDictionary('dictionaryWithContentsOfFile', $(productPlistPath));

    while (keys.length > 0) {
      var key = keys.shift();
      var value = values.shift();

      if (value === 'YES' || value === 'NO') {
        // workaround https://github.com/TooTallNate/NodObjC/issues/31
//        var val = $.NSNumber('numberWithBool', value === 'YES');
        var string = $.NSString('stringWithString', $(value));
        var val = $.NSNumber('numberWithBool', string('boolValue'));
        info('setObject', val, 'forKey', $(key));
      } else {
        info('setObject', $(value), 'forKey', $(key));
      }

      console.log("updated '" + key + "' to " + value);
    }

    var error = $.NSError.createPointer();
    var data = $.NSPropertyListSerialization('dataWithPropertyList', info, 'format', $.NSPropertyListXMLFormat_v1_0, 'options', 0, 'error', error.ref());
    if (error.code) {
      console.log('ERROR - failed to serialize plist');
      process.exit(code=1);
    }
    var status = data('writeToFile', $(productPlistPath), 'atomically', true);
    if (!status) {
      console.log('ERROR - failed to write updated plist to disk');
      process.exit(code=1);
    }
  }
  pool('drain');
});
