// Generated by CoffeeScript 1.4.0

exports.task = function(request, response) {
  var fetchUser, players, taskDone, tasks;
  tasks = 3;
  players = [];
  taskDone = function() {
    var player;
    if (--tasks < 1) {
      players.slice(0, 3);
      console.log('players?');
      console.log(players);
      return response.success((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = players.length; _i < _len; _i++) {
          player = players[_i];
          _results.push({
            position: player.position | 0,
            fb_id: player.get('fb_id'),
            username: player.get('username'),
            object_id: player.id,
            score: player.get('score') | 0
          });
        }
        return _results;
      })());
    }
  };
  fetchUser = function(offset) {
    return (new Parse.Query('User')).descending('score').notEqualTo('score', 0).skip(offset).first({
      success: function(user) {
        if (user) {
          user.position = offset + 1;
          players.push(user);
        }
        return taskDone();
      },
      error: function() {
        return taskDone();
      }
    });
  };
  return (new Parse.Query('User')).notEqualTo('score', 0).count({
    success: function(number) {
      var offset, _i, _len, _ref, _results;
      _ref = [0, Math.floor(number / 2), number - 1];
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        offset = _ref[_i];
        _results.push(fetchUser(offset));
      }
      return _results;
    }
  });
};
