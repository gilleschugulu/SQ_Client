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
    orderId     : 'XXXX',
    affiliation : (paypal,allopass,in-app,etc)
    items : [
      {
        SKU       : 'XXX',
        name      : 'XXX',
        category  : 'XXX',
        price     : 420, // integer => (4.20 * 100)
        quantity  : 10
      }
    ]
  }
  */
  trackTransaction: function(data) {
    Cordova.exec(function() {}, function() {}, 'GoogleAnalytics', "trackTransaction", [data]);
  }
};