var ChartBoost = {
  cacheInterstitial : function(callback) {
    Cordova.exec(callback, function(){}, "ChartBoost", "cacheInterstitial", []);
  },

  showInterstitial : function(callback) {
    Cordova.exec(callback, callback, "ChartBoost", "showInterstitial", []);
  }
};
