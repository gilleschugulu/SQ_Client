var XitiAnalytics = {
  page : function(page, extra, level2) {
    Cordova.exec(function(){}, function(){}, "XitiAnalytics", 'page', [{page:page, extra:extra, level2:level2}]);
  },

  click : function(click, type, level2) {
    Cordova.exec(function(){}, function(){}, "XitiAnalytics", 'click', [{click:click, type:type, level2:level2}]);
  },

  transaction : function(data) {
    Cordova.exec(function(){}, function(){}, "XitiAnalytics", 'transaction', [data]);
  }
};
