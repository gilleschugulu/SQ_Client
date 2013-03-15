var SocialError = {
  SOCIAL_ERROR_UNKNOWN                   : 0,
  SOCIAL_ERROR_CANT_MESSAGE              : 1,
  SOCIAL_ERROR_MESSAGE_TOO_LONG          : 2,
  SOCIAL_ERROR_URL_TOO_LONG              : 3,
  SOCIAL_ERROR_IMAGE_TOO_LONG            : 4,
  SOCIAL_ERROR_MESSAGE_CANCELLED         : 5,
  SOCIAL_ERROR_SERVICE_UNKNOWN           : 6,
  SOCIAL_ERROR_COULD_NOT_CREATE_COMPOSER : 7
};

var Social = {
  availableServices : {},

  /**
  serviceName : string : twitter|facebook|sinaweibo
  */
  isServiceAvailable: function(serviceName) {
    return !!serviceName && this.availableServices[serviceName] == '1';
  },

/**
  serviceNames:
  "facebook"
  "twitter"
  "sinaweibo"
*/
  updateAvailableServices: function(success, fail) {
    var self = this;
    var can = function(params) {
      self.availableServices = params;
      if (typeof success !== "undefined")
        success(params);
    }
    Cordova.exec(can, fail, "Social", "availableServices", []);
  },

  /**
  options: {
    text        : "",
    serviceName : "facebook",
    imageUrl    : "http://image.jpg",
    url         : "http://google.com"
  }
  */
  composeMessage : function(options, success, fail) {
    Cordova.exec(success, fail, "Social", "composeMessage", [options]);
  }
};
