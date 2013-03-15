var AdColonyError = {
  UNKNOWN           : 0,
  COULD_NOT_REWARD  : 1,
  COULD_NOT_LOAD    : 2,
  ADS_NOT_READY     : 3,
  NO_VIDEO_FILL     : 4,
  UNKNOWN_ZONE      : 5,
  ZONE_UNAVAILABLE  : 6,
  REWARD_UNAVAILABLE: 7
};

var AdColony = {
  zones : null,
  /*
    zones = {
      SOME_ZONE : "zoneId"
    }
  */
  init : function(zones) {
    this.zones = zones;
    var someZones = [];
    for (k in zones) {
      v = zones[k];
      if (someZones.indexOf(v) === -1)
        someZones.push(v);
    }
    Cordova.exec(function(){}, function(){}, "AdColony", "init", [{zones:someZones}]);
  },

  /*
  params = {
    zone      : "42",
    prepopup  : true|false,
    postpopup : true|false,
    custom    : "somedata"
  }
  */
  playVideo: function(params, success, error) {
    Cordova.exec(success, error, "AdColony", "playVideo", [params]);
  }
};