/**
 *
 */

var commander = require('commander')
  , http = require('http')
  , winston = require('winston')
  , endpoints = require('./socket-endpoints')
  , io;

/**
 * Arguments
 */
commander
  .version("0.0.1")
  .option("-v, --verbose", "Verbose logging", false)
  .option("-p, --port [port]", "Socket port", "1337")
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
      silent: commander.verbose,
      colorize: true
    })
  ]
});

winston.addColors({
  error: "red",
  warn: "yellow",
  info: "cyan",
  debug: "grey",
});

/**
 * Configure Socket.IO
 */
io = require('socket.io').listen(parseInt(commander.port), {
  logger: {
    debug: logger.debug,
    info: logger.info,
    error: logger.error,
    warn: logger.warn
  },
  transports: ["websocket"]
});

logger.info("socket.io listening on " + commander.port);

/**
 * Bind to Socket.IO
 */
io.sockets.on("connection", function(socket) {
  logger.log("info", "client connected");

  // Handle messages
  socket.on("message", function(raw_data) {
    var data = JSON.parse(raw_data), payload;

    logger.debug("message received: " + raw_data);

    if (!data) {
      logger.error("invalid message data: " + raw_data);
    }

    if (typeof data.type == 'undefined') {
      logger.error("message type is undefined: " + raw_data);
      return;
    }

    if (typeof data.identifier == 'undefined') {
      logger.error("message identifier is undefined: " + raw_data);
      return;
    }

    if (typeof endpoints[data.type] == 'undefined') {
      logger.error("unknown endpoint " + data.type);
      return;
    }

    payload = endpoints[data.type]({
      socket: socket,
      logger: logger,
      identifier: data.identifier,
      type: data.type,
    }, data.payload);

    if (payload) {
      socket.emit("message", {
        type: data.type,
        identifier: data.identifier,
        payload: payload
      });
    }
  });

  socket.on("disconnect", function() {
    logger.info("client disconnected");
  });
});
