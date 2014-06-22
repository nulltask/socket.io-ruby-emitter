var io = require('socket.io');
var ioc = require('socket.io-client');
var redis = require('socket.io-redis');

var srv = io(8125);
srv.adapter(redis({ host: 'localhost', port: 6380 }));

var cli = ioc('ws://localhost:8125', {forceNew: true});

cli.on('broadcast event', function(payload) {
  console.log(payload);
});

cli.on('nsp broadcast event', function(payload) {
  console.log("BAD");
});

var cliNsp = ioc('ws://localhost:8125/nsp', {forceNew: true});

cliNsp.on('broadcast event', function(payload) {
  console.log(payload);
});

cliNsp.on('nsp broadcast event', function(payload) {
  console.log("GOOD");
});
