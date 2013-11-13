var GameCanterError = {
  UNKNOWN               : 0,
  COULD_NOT_AUTHENTICATE: 1,
  COULD_NOT_REPORT_SCORE: 2,
  MISSING_LEADERBOARDID : 3,
  MISSING_SCORE         : 4,
  NOT_AVAILABLE         : 5,
  NOT_AUTHENTICATED     : 6
};

/*
all fail() callbacks report GameCenterError code
fail(error) {
  error.code === GameCenterError.SOME_ERROR
}
*/
var GameCenter = {
  localUserAlias : null,

  reportScore : function(score, leaderboard, success, fail) {
    Cordova.exec(success, fail, "GameCenter", "reportScore", [{points:score, leaderboard:leaderboard}]);
  },

  // success(alias) is called when the user is successfully authenticated, it gets his local alias
  authenticateLocalUser : function(success, fail) {
    var self=this
    var setLocalUserAlias = function(alias) {
      self.localUserAlias = alias;
      if (success)
        success(alias);
    }
    Cordova.exec(setLocalUserAlias, fail, "GameCenter", "authenticateLocalUser", []);
  },

  // leaderboard string : optionnal
  // done() is called just after dismissing the modal view
  showLeaderboard : function(leaderboard, done) {
    Cordova.exec(done, function(){}, "GameCenter", "showLeaderboard", [leaderboard]);
  },

  // success(friendNicknames)
  requestFriendList : function(success, fail) {
    Cordova.exec(success, fail, "GameCenter", "requestFriendList", []);
  }
};
