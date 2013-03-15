var PermaKeyboard = {
  show : function(options) {
    Cordova.exec(function(){}, function(){}, "PermaKeyboard", "show", [options]);
  },

  getText : function(callback) {
    Cordova.exec(callback, function(){}, "PermaKeyboard", "getText", []);
  },

  setText : function(text) {
    Cordova.exec(function(){}, function(){}, "PermaKeyboard", "setText", [text]);
  },

  empty : function() {
    Cordova.exec(function(){}, function(){}, "PermaKeyboard", "empty", []);
  },

  setEnabled : function(enabled) {
    Cordova.exec(function(){}, function(){}, "PermaKeyboard", "setEnabled", [enabled]);
  },

  hide : function() {
    Cordova.exec(function(){}, function(){}, "PermaKeyboard", "hide", []);
  }
};
