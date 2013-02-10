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
GifMan.Conversation = function (api, kvStore) {
    var self = this,
        CHECK_INTERVAL = 100, // Time between checks for changes
        _container;

    // Cleanup
    self._clean = function (html) {
      return $("<p>").text(html).html();
    }

    // Check all messages in the page for changes
    self._checkMessages = function () {
        $(".item:not(.read), .item.force-load", _container).each(function(i, e) { self._parseMessage(e); });
    };

    // Parse a message and handle any embedding
    self._parseMessage = function (message) {
      if ($(message).hasClass("loading") || $(message).hasClass("loaded") || $(message).hasClass("force-hidden")) return;

      if (!kvStore.get("embed_enabled") && !$(message).hasClass("force-load")) {
        $(message).addClass("loaded");
        return;
      }

      var links = $(".body a", message);
      if (links.length > 0) {
        var pending = links.length;

        $(message).addClass("loading");
        $(".body", message).append("<div class=\"gifman-embed\"></div>");

        $(links).each(function(i, e) {
          self._handleLink(e, message, function () {
            pending--;

            if (pending == 0) {
              $(message).removeClass("loading").addClass("loaded").removeClass("force-load");
            }
          });
        });
      };
    };

    // Match a link to a string of HTML for embedding
    self._matchLink = function (link, callback) {
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
    self._handleLink = function (link, message, handler) {
      var matched = self._matchLink($(link).attr("href"), function (html) {
        if (html != null) {
          $(".gifman-embed", message).append(html);

          handler();
        }
      });

      if (!matched) {
        handler();
      }
    };

    // Enable
    self._enableEmbed = function () {
      kvStore.set(true, "embed_enabled");
    };

    self._disableEmbed = function () {
      kvStore.set(false, "embed_enabled");
    }

    // Init Method
    self._init = function () {
      _container = $("#container");

      // Parser
      setInterval(self._checkMessages, CHECK_INTERVAL);

      // Toggle
      $(".gifman-toggle", _container)
        .switcher()
        .on("switch", function() {
          if ($(this).data("switcher").isOn()) {
            self._enableEmbed();
          }
          else {
            self._disableEmbed();
          }
        });

      // Keep the toggle up to date
      var _current = kvStore.get("embed_enabled");
      $(".gifman-toggle", _container).data("switcher").update(!!_current, false);

      setInterval(function() {
        if ((v = kvStore.get("embed_enabled")) != _current) {
          _current = v;

          if (_current) {
            $(".gifman-toggle", _container).removeClass("off").addClass("on");
          }
          else {
            $(".gifman-toggle", _container).removeClass("on").addClass("off");
          }
        }

      }, 2000);
    };

    // Fire away!
    this._init();
};

// Helpers
GifMan.Helpers = {

  // Linkify
  linkify: function (text) {
    return text.replace(
      /((https?\:\/\/)|(www\.))(\S+)(\w{2,4})(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?/gi,
      function(url){
        var full_url = url;
        if (!full_url.match('^https?:\/\/')) {
          full_url = 'http://' + full_url;
        }
        return '<a href="' + full_url + '">' + url + '</a>';
    }
    );
  },

  // Format a string
  format: function (text) {
    return text.replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2');

    // WIP
    return text
            .replace(/\s/g, '&nbsp;')
            .replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1<br />$2');
  }
}

// Notification API
GifMan.API = {
  hideContentInMessage: function (message_id) {
    $(".gifman-embed", $("#" + message_id)).remove();
    $("#" + message_id).removeClass("loaded").removeClass("loading").removeClass("force-load").addClass("force-hidden");
  },
  loadContentInMessage: function (message_id) {
    $("#" + message_id).removeClass("loading").removeClass("loaded").addClass("force-load").removeClass("force-hidden");
  },
  messageHasVisibleContent: function (message_id) {
    return $("#" + message_id).hasClass("loaded");
  },
  hasContent: function(message_id) {
    return $("#" + message_id).find(".body a").length > 0;
  },
  addHubotMessage: function(message_id, messages) {
    var div = $("<div class=\"item message out hubot\"><div class=\"container\"><div class=\"head\"><span class=\"sender\">Hubot</span><span class=\"time\"></span><button class=\"delete\" title=\"Remove Message\"></button></div><div class=\"body\"></div></div></div>"),
        d = new Date();

    $(".time", div).text(d.getHours() + ':' + d.getMinutes());

    $.each(messages, function(i, message) {
      $(".body", div).append($("<p>").html(GifMan.Helpers.format(GifMan.Helpers.linkify(message))));
    })

    if ($("#typing").length > 0) {
      $("#conversation #typing").before(div);
    } else {
      $("#conversation").append(div);
    }

    if (scroll && (document.body.scrollTop+window.innerHeight >= document.body.offsetHeight-106)) {
      window.scrollTo(0, $("#conversation").outerHeight());
    }
  }
};

$(function() {
  var conversation = new GifMan.Conversation(SCS.conv, window.GifManKVStore);
});
