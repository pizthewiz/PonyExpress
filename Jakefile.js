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
const HEAD_REVISION_KEY = 'com.chordedconstructions.fleshworld.ProjectHEADRevision';
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
