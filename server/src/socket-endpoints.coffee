
_hubotSocket = null;
_hubotCallbacks = {};
_hubotRooms = {};

module.exports  =

  # Ping endpoint, sends back a payload of { pong: true } when called
  'GifMan::ping': (context, payload, callback) ->
    context.logger.info("received ping");
    callback({
      pong: true
    });

  # Register a socket client as hubot
  'GifMan::registerHubot': (context, payload, callback) ->

    if (!_hubotSocket || _hubotSocket.disconnected)
      _hubotSocket = context.socket;
      context.logger.info("Hello hubot!");

      callback({
        assigned: true
      });
    else
      context.logger.info("Sorry hubot, you're not wanted here");

      callback({
        assigned: false
      });

  # Pass a message through to hubot, and retain the callback for the reply
  'GifMan::hubotProxy': (context, payload, callback) ->
    context.logger.info("Forward to hubot!");

    if (!_hubotSocket)
      context.logger.error("Failed to proxy hubot message, hubot could not be found");

      return {
        sent: false
      };

    _hubotCallbacks[context.identifier] = callback;

    _hubotSocket.emit("message", {
      "identifier": context.identifier,
      "type": context.type,
      "payload": payload
    });

  # Handle a reply from hubot and send it back to the retained client
  'GifMan::hubotReply': (context, payload, callback) ->
    context.logger.info("Hubot replied!");

    if (_hubotCallbacks.hasOwnProperty(context.identifier))
      _hubotCallbacks[context.identifier](payload);

  # //
  # // 'GifMan::hubotJoin': function (context, payload, callback) {
  # //   if (typeof _hubotRooms[payload.chat] == "undefined") {
  # //     _hubotRooms[payload.chat] = {};
  # //   }

  # //   // Keep a local cache of the rooms for spray replies
  # //   _hubotRooms[payload.chat][payload.username] = context.socket;

  # //   // Pass the message to hubot
  # //   if (_hubotSocket && !_hubotSocket.disconnected) {
  # //     _hubotSocket.emit("message", {
  # //       "identifier": context.identifier,
  # //       "type": context.type,
  # //       "payload": payload
  # //     });
  # //   }

  # //   callback(null);
  # // },

  # //
  # // 'GifMan::hubotLeave': function (context, payload, callback) {

  # //   for (var i=0; i < _hubotRooms.length; i++) {
  # //     for
  # //   }
  # // }
