var PushNotifications = {
  /*
  callback = function(int){} where int = 0 or 1
  */
  checkIsRegistered : function(callback) {
    Cordova.exec(callback, function(){}, "PushNotifications", "checkIsRegistered", []);
  },

  /*
  success = function({token : "token", aps_environment : "env"}) {}
  */
  register : function(success, fail) {
    Cordova.exec(success, fail, "PushNotifications", "register", []);
  },

  /*
    ex:
    options = {
      buttonCancel: "No, thank you",
      buttonOK    : "OK"
    }
  */
  configure: function(options) {
    Cordova.exec(function(){}, function(){}, "PushNotifications", "configure", [options]);
  },

  block : function() {
    Cordova.exec(function(){}, function(){}, "PushNotifications", "block", []);
  },

  unblock : function() {
    Cordova.exec(function(){}, function(){}, "PushNotifications", "unblock", []);
  }
};
