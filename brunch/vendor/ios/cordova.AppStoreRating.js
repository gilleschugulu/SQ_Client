var AppStoreRatingError = {
    APPSTORE_RATING_ERROR_UNKNOWN                : 0,
    APPSTORE_RATING_ERROR_NEVER_ASK              : 1,
    APPSTORE_RATING_ERROR_CANCELLED              : 2,
    APPSTORE_RATING_ERROR_SHOULD_NOT_RATE        : 3,
    APPSTORE_RATING_ERROR_COULD_NOT_OPEN_RATINGS : 4
};

var AppStoreRating = {
  openRatingsPage : function(success, error) {
    Cordova.exec(success, error, "AppStoreRating", "openRatingsPage", []);
  },
/*
params = {
  title             : "Awesome App",
  message           : "please rate me !",
  button_cancel     : "whatever...",
  button_rate       : "fuck yeah !",
  button_never_ask  : "forget about it !"  // optional
}
*/
  show : function(accept, cancel, params) {
    Cordova.exec(accept, cancel, "AppStoreRating", "show", [params]);
  },

  incrementCounter : function(callback) {
    Cordova.exec(callback, function(e){}, "AppStoreRating", "incrementCounter", []);
  },

  checkShouldRate : function(success, fail) {
    Cordova.exec(success, fail, "AppStoreRating", "checkShouldRate", []);
  }
};
