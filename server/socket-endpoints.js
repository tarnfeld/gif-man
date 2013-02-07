/**
 *
 */

module.exports = {

  // Ping endpoint, sends back a payload of { pong: true } when called
  'GifMan::ping': function (context, payload) {
    context.logger.info("received ping");

    return {
      pong: true
    };
  },
}
