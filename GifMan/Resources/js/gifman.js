/**
 *
 */

if (typeof GifMan == "undefined") {
	var GifMan = {};
}

if (typeof SCS == "undefined") {
    var SCS = { conv: {} };
}

// Conversation
GifMan.Conversation = function (api) {
    var self = this,
        CHECK_INTERVAL = 100, // Time between checks for changes
        _container;

    // Cleanup
    self._clean = function (html) {
      return $("<p>").text(html).html();
    }

    // Check all messages in the page for changes
    this._checkMessages = function () {
        $(".item:not(.read)", _container).each(function(i, e) {
            self._parseMessage(e);
        });
    };

    // Parse a message and handle any embedding
    this._parseMessage = function (message) {
      if ($(message).hasClass("loading") || $(message).hasClass("loaded")) return;

      var links = $(".body a", message);
      if (links.length > 0) {
        var pending = links.length;

        $(message).addClass("loading");
        $(".body", message).append("<div class=\"gifman-embed\"></div>");

        $(links).each(function(i, e) {
          self._handleLink(e, message, function () {
            pending--;

            if (pending == 0) {
              $(message).removeClass("loading").addClass("loaded");
            }
          });
        });
      };
    };

    // Match a link to a string of HTML for embedding
    this._matchLink = function (link, callback) {
      var parts = link.split("."),
          extention = parts[parts.length - 1].toLowerCase();

      // 1) Check for file extentions
      var image_ext = ["jpg", "jpeg", "gif", "png"];
      if (image_ext.indexOf(extention) != -1) {
        callback("<br /><a href='" + self._clean(link) + "'><img src='" + self._clean(link) + "' width='300px' onerror='this.parentNode.removeChild(this)' /></a>");
        return true;
      }

      // 2) Cloudapp
      var cloudapp_domains = ['sha.gd', 'cl.ly', 'tfld.me', 'cloud.duedil.com'];
      for (var x = 0; x < cloudapp_domains.length; x++) {
        if (link.indexOf(cloudapp_domains[x]) != -1) {
          callback("<br /><a href='" + self._clean(link) + "'><img src='" + self._clean(link) + "/content' width='300px' onerror='this.parentNode.removeChild(this)' /></a>");
          return true;
        }
      }

      // 3) Youtube?
      if (link.indexOf("?v=") != -1) {
        var matches = link.match(/\?v=([a-zA-Z0-9\-_]+)/);
        if (matches.length > 1) {
          callback("<br /><iframe type='text/html' width='300' height='180' src='http://www.youtube.com/embed/" + self._clean(matches[1]) + "' frameborder='0'></iframe>");
          return true;
        }
      }
      else if (link.indexOf("youtu.be/") != -1) {
        var matches = link.match(/youtu\.be\/([a-zA-Z0-9\-_]+)/);
        if (matches.length > 1) {
          callback("<br /><iframe type='text/html' width='300' height='180' src='http://www.youtube.com/embed/" + self._clean(matches[1]) + "' frameborder='0'></iframe>");
          return true;
        }
      }

      // 4) Imgur.com
      if (link.indexOf("imgur.com") != -1) {
        callback("<br /><a href='" + self._clean(link) + "'><img src='" + self._clean(link) + ".jpg' width='300px' onerror='this.parentNode.removeChild(this)' /></a>");
        return true;
      }

      // 5) i.jpg.to
      if (link.indexOf("i.jpg.to") != -1) {
        callback("<br /><a href='" + self._clean(link) + "'><img src='" + self._clean(link) + "' width='300px' onerror='this.parentNode.removeChild(this)' /></a>");
        return true;
      }

      // 6) Twitpic
      if (link.indexOf("twitpic") != -1) {
        $.ajax({
          url: link,
          type: "GET",
          error: function() {
            callback(null);
          },
          success: function(data) {
            var image = $("#media img[alt]", data);
            if (!!image && image.attr("src")) {
              var source = image.attr("src");
              callback("<br /><a href='" + self._clean(link) + "'><img src='" + self._clean(source) + "' width='300px' onerror='this.parentNode.removeChild(this)' /></a>");
            }
            else {
              callback(null);
            }
          }
        });

        return true;
      }

      // 7) jpg.to links
      if (link.indexOf('jpg.to') != -1) {
        $.ajax({
          url: link,
          type: "GET",
          error: function() {
            callback(null);
          },
          success: function(data) {
            var image = $("img", data),
                source = image.attr("src");
            callback("<br /><a href='" + self._clean(link) + "'><img src='" + self._clean(source) + "' width='300px' onerror='this.parentNode.removeChild(this)' /></a>");
          }
        });

        return true;
      }

      return false;
    }

    // Handle a specific link within a message
    this._handleLink = function (link, message, handler) {
      var matched = self._matchLink($(link).attr("href"), function (html) {
        if (html != null) {
          $(".gifman-embed", message).append(html);

          handler();
        }
      });
    };

    // Init Method
    this._init = function () {
        _container = $("#container");

       // Parser
       setInterval(self._checkMessages, CHECK_INTERVAL);

       // Toggle
       $(".gifman-toggle", _container)
          .switcher()
          .on("switch", function() {
              alert("persist!");
          });
    };

    // Fire away!
    this._init();
};

$(function() {
  var conversation = new GifMan.Conversation(SCS.conv);
});
