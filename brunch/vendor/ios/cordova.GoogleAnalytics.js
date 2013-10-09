var GoogleAnalytics = {
  /*
    accountIds : array of ids
    ['UA-XXXXXX-Y', 'UA-ZZZZZZ-X']
  */
  startTrackerWithAccountIDs: function(accountIds) {
    Cordova.exec(function() {}, function() {}, 'GoogleAnalytics', "startTrackerWithAccountID", [{accountIds:accountIds}]);
  },

  trackEvent: function(category,action,label,value) {
    var options = {
      category: category,
      action  : action,
      label   : label,
      value   : value
    };
    Cordova.exec(function() {}, function() {}, 'GoogleAnalytics', "trackEvent", [options]);
  },

  trackPageview: function(pageUri) {
    Cordova.exec(function() {}, function() {}, 'GoogleAnalytics', "trackPageview", [{pageUri:pageUri}]);
  },

  /*
  data = {
    transaction = {
      id          : 'XXXX', // transaction id REQUIRED
      affiliation : (paypal,allopass,in-app,etc)
      revenue     : 42.0, // total (tax incl)
      tax         : 12.2, // total tax
      shipping    : 11.1, // total shipping cost
      currency    : 'EUR' // https://developers.google.com/analytics/devguides/platform/features/currencies
    },
    items : [
      {
        id        : 'XXX', // transaction id ! REQUIRED
        sku       : 'XXX',
        name      : 'XXX', // REQUIRED
        category  : 'XXX',
        price     : 4.20,
        quantity  : 10,
        currency  : 'EUR'
      }
    ]
  }
  */
  trackTransaction: function(data) {
    Cordova.exec(function() {}, function() {}, 'GoogleAnalytics', "trackTransaction", [data]);
  }
};