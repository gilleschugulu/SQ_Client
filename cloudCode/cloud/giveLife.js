// Generated by CoffeeScript 1.6.2
exports.task = function(request, response) {
  var friend, query, user;

  user = Parse.User.current();
  friend = request.params.friendsId;
  query = new Parse.Query('User').equalTo('fb_id', friend.toString());
  return query.find({
    success: function(results) {
      Parse.Cloud.useMasterKey();
      results[0].set('health', results[0].get('health') + 1).save();
      if (!user.get('life_given')) {
        user.set('life_given', [results[0].get('fb_id')]).save();
      } else {
        console.log('titi');
        user.set('life_given', user.get('life_given').concat(results[0].get('fb_id'))).save();
      }
      return response.success(results[0]);
    },
    error: function(results) {
      return response.error(results);
    }
  });
};
