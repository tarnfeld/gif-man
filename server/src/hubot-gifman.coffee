SocketIO = require('socket.io-client')

Robot        = require('hubot').Robot
Adapter      = require('hubot').Adapter
TextMessage  = require('hubot').TextMessage
EnterMessage = require('hubot').EnterMessage
LeaveMessage = require('hubot').LeaveMessage

class GifMan extends Adapter

  send: (envelope, strings...) ->
    @socket.emit "message", JSON.stringify({
      "type": "GifMan::hubotReply"
      "identifier": envelope.message.id,
      "payload": {
        "messages": strings
      }
    })

  reply: (envelope, strings...) ->
    @send envelope, strings...

  run: ->
    self = @

    options =
      socket:
        host: "127.0.0.1"
        port: 1337

    if process.env.GIFMAN_SOCKET_HOST?
      options.socket.host = process.env.GIFMAN_SOCKET_HOST

    if process.env.GIFMAN_SOCKET_PORT?
      options.socket.port = process.env.GIFMAN_SOCKET_PORT

    @socket = SocketIO.connect('ws://' + options.socket.host + ':' + options.socket.port)
    @socket.on "connect", =>
      console.log("[GIFMAN] Connected to socket");
      @socket.emit "message", JSON.stringify({
        "type": "GifMan::registerHubot",
        "identifier": "HUBOT_REGISTRATION"
      })

    @socket.on "message", (message) =>
      if message.type == "GifMan::registerHubot"
        console.log("[GIFMAN] Successfully registered hubot")
        self.emit "connected"

      else if message.type == "GifMan::hubotProxy"
        user = @userForId message.payload.username,
               name: message.payload.nickname,
               room: message.payload.chat,
               room_name: message.payload.chat_name

        @receive new TextMessage user, message.payload.message, message.identifier

      else if message.type == "GifMan::hubotJoin"
        user = @userForId message.payload.username,
               name: message.payload.nickname,
               room: message.payload.chat

        @receive new EnterMessage user
        console.log("ENTER", user)

      else if message.type == "GifMan::hubotLeave"
        user = @userForId message.payload.username,
               name: message.payload.nickname,
               room: message.payload.chat

        @receive new LeaveMessage user
        console.log("LEAVE", user)

    @socket.on "disconnect", =>
      console.log("[GIFMAN] Lost the socket");
      process.exit 0

    @socket.on "connect_failed", =>
      console.log("[GIFMAN] Connection to socket failed");


exports.use = (robot) ->
  new GifMan robot
