/**
 *
 */

_hubotSocket = null;

module.exports = {

  // Ping endpoint, sends back a payload of { pong: true } when called
  'GifMan::ping': function (context, payload) {
    context.logger.info("received ping");

    return {
      pong: true
    };
  },

  // Hubot
  _hubotSocket: null,

  'GifMan::registerHubot': function(context, payload) {

    if (!_hubotSocket || _hubotSocket.disconnected) {
      _hubotSocket = context.socket;
      context.logger.info("Hello hubot!");

      return {
        assigned: true
      };
    }
    else {
      context.logger.info("Sorry hubot, you're not wanted here");

      return {
        assigned: false
      };
    }

    return {};
  },

  'GifMan::hubotProxy': function(context, payload) {
    context.logger.info("Forward to hubot!");

    if (!_hubotSocket) {
      context.logger.error("Failed to proxy hubot message, hubot could not be found");

      return {
        sent: false
      };
    }

    _hubotSocket.emit("message", {
      "identifier": context.identifier,
      "type": context.type,
      "payload": payload
    });

    return {
      sent: true
    };
  }
}
