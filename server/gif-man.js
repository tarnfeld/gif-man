/*
 *
 */

var commander = require('commander')
  , http = require('http')
  , winston = require('winston')
  , io;

/**
 * Arguments
 */
commander
  .version("0.0.1")
  .option("v, --verbose [verbose]", "Verbose logging", false)
  .option("p, --port [port]", "Socket port", "1337")
  .parse(process.argv);


/**
 * Logging
 */
logger = new (winston.Logger)({
  transports: [
    new (winston.transports.Console)({
      level: "verbose",
      timestamp: true,
      json: false,
      silent: !commander.verbose
    })
  ]
});

winston.addColors({
  info: "blue",
  debug: "yellow",
  error: "red"
});

/**
 * Configure Socket.IO
 */
io = require('socket.io').listen(parseInt(commander.port));
io.configure(function() {
  io.set("transports", ["websocket"]);
});

/**
 * Bind to Socket.IO
 */
io.sockets.on("connection", function(socket) {
  logger.info("Client connected");

  // Simple ping/pong response
  socket.on("message", function(data) {

    data = JSON.parse(data);

    if (typeof data.type == 'undefined') {
      console.log("Undefined type!");
      return;
    }

    if (typeof data.identifier == 'undefined') {
      console.log("Undefined identifier!");
      return;
    }

    if (data.type == 'GifMan::ping') {
      socket.emit("message", {
        type: data.type,
        identifier: data.identifier,
        payload: {
          pong: true
        }
      });
    }
  });

  socket.on("disconnect", function() {
    logger.info("Client disconnected");
  });
});
